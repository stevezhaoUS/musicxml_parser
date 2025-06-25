// Assuming the necessary using statements for MusicXML models, exceptions, and helpers
using System.Xml.Linq;
using System.Collections.Generic;
using System.Linq;
using MusicXMLParser.Models; // For Measure, Note, KeySignature, TimeSignature, Clef, Barline, Ending, Direction, PrintObject etc.
using MusicXMLParser.Exceptions; // For MusicXmlValidationException, MusicXmlStructureException
using MusicXMLParser.Parser; // For other parsers like NoteParser, AttributesParser, BeamParser, PageLayoutParser, SystemLayoutParser, StaffLayoutParser
using MusicXMLParser.Utils; // For WarningSystem

namespace MusicXMLParser.Parser
{
    public class MeasureParser
    {
        private readonly NoteParser _noteParser;
        private readonly AttributesParser _attributesParser;
        private readonly PageLayoutParser _pageLayoutParser;
        private readonly SystemLayoutParser _systemLayoutParser;
        private readonly StaffLayoutParser _staffLayoutParser;
        public WarningSystem WarningSystem { get; }

        public MeasureParser(
            NoteParser? noteParser = null,
            AttributesParser? attributesParser = null,
            PageLayoutParser? pageLayoutParser = null,
            SystemLayoutParser? systemLayoutParser = null,
            StaffLayoutParser? staffLayoutParser = null,
            WarningSystem? warningSystem = null)
        {
            WarningSystem = warningSystem ?? new WarningSystem();
            _noteParser = noteParser ?? new NoteParser(WarningSystem); // Assuming NoteParser has a similar constructor
            _attributesParser = attributesParser ?? new AttributesParser(); // Assuming AttributesParser has a parameterless constructor or similar logic
            _pageLayoutParser = pageLayoutParser ?? new PageLayoutParser(); // Assuming PageLayoutParser has a parameterless constructor
            _systemLayoutParser = systemLayoutParser ?? new SystemLayoutParser(); // Assuming SystemLayoutParser has a parameterless constructor
            _staffLayoutParser = staffLayoutParser ?? new StaffLayoutParser(); // Assuming StaffLayoutParser has a parameterless constructor
        }

        public Measure Parse(
            XElement element,
            string partId,
            int? inheritedDivisions = null,
            KeySignature? inheritedKeySignature = null,
            TimeSignature? inheritedTimeSignature = null,
            List<Clef>? inheritedClefs = null)
        {
            var line = XmlHelper.GetLineNumber(element);
            var implicitAttr = XmlHelper.GetAttributeValue(element, "implicit");
            var numberAttr = XmlHelper.GetAttributeValue(element, "number");

            if (string.IsNullOrEmpty(numberAttr))
            {
                throw new MusicXmlValidationException(
                    message: "Measure number is required",
                    line: line,
                    context: new Dictionary<string, object> { { "part", partId } }
                );
            }

            if (!int.TryParse(numberAttr, out int measureNum) || measureNum < 0)
            {
                throw new MusicXmlValidationException(
                    message: $"Invalid measure number: {numberAttr}",
                    line: line,
                    context: new Dictionary<string, object> { { "part", partId }, { "measure", numberAttr } }
                );
            }

            var isPickup = (numberAttr == "0" && implicitAttr == "yes");
            if (measureNum == 0 && !isPickup)
            {
                throw new MusicXmlValidationException(
                    message: $"Invalid measure number: {numberAttr}",
                    line: line,
                    context: new Dictionary<string, object> { { "part", partId }, { "measure", numberAttr } }
                );
            }

            var widthAttr = XmlHelper.GetAttributeValue(element, "width");
            double? width = !string.IsNullOrEmpty(widthAttr) && double.TryParse(widthAttr, out double w) ? w : (double?)null;

            var measureBuilder = new MeasureBuilder(numberAttr, line, new Dictionary<string, object> { { "part", partId } })
                .SetIsPickup(isPickup)
                .SetWidth(width)
                .SetKeySignature(inheritedKeySignature)
                .SetTimeSignature(inheritedTimeSignature)
                .SetClefs(inheritedClefs ?? new List<Clef>());

            int? currentDivisions = inheritedDivisions;
            var individualBeams = new List<Beam>();

            foreach (var child in element.Elements())
            {
                switch (child.Name.LocalName)
                {
                    case "attributes":
                        var attributesData = _attributesParser.Parse(child, partId, numberAttr, currentDivisions);
                        currentDivisions = (int?)attributesData["divisions"] ?? currentDivisions;
                        if (attributesData["keySignature"] != null)
                        {
                            measureBuilder.SetKeySignature((KeySignature)attributesData["keySignature"]);
                        }
                        if (attributesData["timeSignature"] != null)
                        {
                            measureBuilder.SetTimeSignature((TimeSignature)attributesData["timeSignature"]);
                        }
                        if (attributesData["clefs"] != null)
                        {
                            measureBuilder.SetClefs((List<Clef>)attributesData["clefs"]);
                        }
                        break;
                    case "note":
                        var note = _noteParser.Parse(child, currentDivisions, partId, numberAttr);
                        if (note != null)
                        {
                            var noteIndex = measureBuilder.DebugGetNotesCount();
                            measureBuilder.AddNote(note);
                            individualBeams.AddRange(BeamParser.Parse(child, noteIndex, numberAttr));
                        }
                        break;
                    case "backup":
                        ParseBackupOrForward(child, "backup", partId, numberAttr);
                        break;
                    case "forward":
                        ParseBackupOrForward(child, "forward", partId, numberAttr);
                        break;
                    case "barline":
                        measureBuilder.AddBarline(ParseBarline(child));
                        break;
                    case "ending":
                        var ending = ParseEnding(child, partId, numberAttr);
                        if (ending != null)
                        {
                            measureBuilder.SetEnding(ending);
                        }
                        break;
                    case "direction":
                        var direction = ParseDirection(child, partId, numberAttr);
                        if (direction != null)
                        {
                            measureBuilder.AddDirection(direction);
                        }
                        break;
                    case "print":
                        measureBuilder.SetPrintObject(ParsePrint(child));
                        break;
                }
            }

            measureBuilder.SetBeams(BeamParser.MergeBeams(individualBeams, numberAttr));
            return measureBuilder.Build();
        }

        private void ParseBackupOrForward(XElement element, string type, string partId, string measureNumber)
        {
            var durationElement = element.Elements("duration").FirstOrDefault();
            if (durationElement == null)
            {
                throw new MusicXmlStructureException(
                    message: $"<{type}> element missing required <duration> child.",
                    parentElement: type,
                    line: XmlHelper.GetLineNumber(element),
                    context: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber } }
                );
            }
            var duration = XmlHelper.GetElementTextAsInt(durationElement);
            if (duration == null || duration < 0)
            {
                throw new MusicXmlStructureException(
                    message: $"Invalid or missing duration value for <{type}>.",
                    parentElement: type,
                    line: XmlHelper.GetLineNumber(durationElement),
                    context: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber }, { "parsedDuration", duration } }
                );
            }
            WarningSystem.AddWarning(
                $"Encountered <{type}> with duration {duration}. Full timeline impact not yet implemented.",
                category: "partial_processing",
                rule: $"{type}_partially_processed",
                context: new Dictionary<string, object>
                {
                    { "element", type }, { "part", partId }, { "measure", measureNumber },
                    { "duration", duration }, { "line", XmlHelper.GetLineNumber(element) }
                }
            );
        }

        private Barline ParseBarline(XElement barlineElement)
        {
            string location = XmlHelper.GetAttributeValue(barlineElement, "location");
            XElement barStyleElement = barlineElement.Elements("bar-style").FirstOrDefault();
            string barStyle = barStyleElement?.Value.Trim();
            XElement repeatElement = barlineElement.Elements("repeat").FirstOrDefault();
            string repeatDirection = null;
            int? repeatTimes = null;
            if (repeatElement != null)
            {
                repeatDirection = XmlHelper.GetAttributeValue(repeatElement, "direction");
                string timesStr = XmlHelper.GetAttributeValue(repeatElement, "times");
                if (!string.IsNullOrEmpty(timesStr) && int.TryParse(timesStr, out int t))
                {
                    repeatTimes = t;
                }
            }
            return new Barline(location, barStyle, repeatDirection, repeatTimes);
        }

        private Ending ParseEnding(XElement endingElement, string partId, string measureNumber)
        {
            string endingNumber = XmlHelper.GetAttributeValue(endingElement, "number");
            if (string.IsNullOrEmpty(endingNumber))
            {
                endingNumber = endingElement.Value.Trim();
            }
            string type = XmlHelper.GetAttributeValue(endingElement, "type");
            string printObjectAttr = XmlHelper.GetAttributeValue(endingElement, "print-object");

            if (!string.IsNullOrEmpty(endingNumber) && !string.IsNullOrEmpty(type))
            {
                return new Ending(endingNumber, type, printObjectAttr ?? "yes");
            }
            else
            {
                WarningSystem.AddWarning(
                    $"Incomplete <ending> element in measure {measureNumber}. Missing \"number\" or \"type\" attribute, or number text content.",
                    category: WarningCategories.Structure, // Assuming WarningCategories is an enum or static class
                    line: XmlHelper.GetLineNumber(endingElement),
                    context: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber } }
                );
                return null;
            }
        }

        private Direction ParseDirection(XElement directionElement, string partId, string measureNumber)
        {
            var directionTypeElements = new List<IDirectionTypeElement>(); // Assuming IDirectionTypeElement interface
            Offset parsedOffset = null;
            Staff parsedStaff = null;
            Sound parsedSound = null;

            foreach (var directionTypeElementXml in directionElement.Elements("direction-type"))
            {
                foreach (var childElement in directionTypeElementXml.Elements())
                {
                    switch (childElement.Name.LocalName)
                    {
                        case "words":
                            var text = childElement.Value.Trim();
                            directionTypeElements.Add(new WordsDirection(
                                text,
                                XmlHelper.GetAttributeValue(childElement, "color"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "default-x"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "default-y"),
                                XmlHelper.GetAttributeValue(childElement, "dir"),
                                XmlHelper.GetAttributeValue(childElement, "enclosure"),
                                XmlHelper.GetAttributeValue(childElement, "font-family"),
                                XmlHelper.GetAttributeValue(childElement, "font-size"),
                                XmlHelper.GetAttributeValue(childElement, "font-style"),
                                XmlHelper.GetAttributeValue(childElement, "font-weight"),
                                XmlHelper.GetAttributeValue(childElement, "halign"),
                                XmlHelper.GetAttributeValue(childElement, "id"),
                                XmlHelper.GetAttributeValue(childElement, "justify"),
                                XmlHelper.GetAttributeValue(childElement, "letter-spacing"),
                                XmlHelper.GetAttributeValue(childElement, "line-height"),
                                XmlHelper.GetAttributeValueAsInt(childElement, "line-through"),
                                XmlHelper.GetAttributeValueAsInt(childElement, "overline"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "relative-x"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "relative-y"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "rotation"),
                                XmlHelper.GetAttributeValueAsInt(childElement, "underline"),
                                XmlHelper.GetAttributeValue(childElement, "valign"),
                                XmlHelper.GetAttributeValue(childElement, "xml:lang"),
                                XmlHelper.GetAttributeValue(childElement, "xml:space")
                            ));
                            if (string.IsNullOrEmpty(text))
                            {
                                WarningSystem.AddWarning("Empty <words> element found in direction.",
                                    category: WarningCategories.Structure,
                                    line: XmlHelper.GetLineNumber(childElement),
                                    context: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber } });
                            }
                            break;
                        case "segno":
                            directionTypeElements.Add(new Segno(
                                XmlHelper.GetAttributeValue(childElement, "color"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "default-x"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "default-y"),
                                XmlHelper.GetAttributeValue(childElement, "font-family"),
                                XmlHelper.GetAttributeValue(childElement, "font-size"),
                                XmlHelper.GetAttributeValue(childElement, "font-style"),
                                XmlHelper.GetAttributeValue(childElement, "font-weight"),
                                XmlHelper.GetAttributeValue(childElement, "halign"),
                                XmlHelper.GetAttributeValue(childElement, "id"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "relative-x"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "relative-y"),
                                XmlHelper.GetAttributeValue(childElement, "smufl"),
                                XmlHelper.GetAttributeValue(childElement, "valign")
                            ));
                            break;
                        case "coda":
                             directionTypeElements.Add(new Coda(
                                XmlHelper.GetAttributeValue(childElement, "color"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "default-x"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "default-y"),
                                XmlHelper.GetAttributeValue(childElement, "font-family"),
                                XmlHelper.GetAttributeValue(childElement, "font-size"),
                                XmlHelper.GetAttributeValue(childElement, "font-style"),
                                XmlHelper.GetAttributeValue(childElement, "font-weight"),
                                XmlHelper.GetAttributeValue(childElement, "halign"),
                                XmlHelper.GetAttributeValue(childElement, "id"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "relative-x"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "relative-y"),
                                XmlHelper.GetAttributeValue(childElement, "smufl"),
                                XmlHelper.GetAttributeValue(childElement, "valign")
                            ));
                            break;
                        case "dynamics":
                            var dynamicValues = new List<string>();
                            foreach (var dynamicChild in childElement.Elements())
                            {
                                if (dynamicChild.Name.LocalName == "other-dynamics")
                                {
                                    var dynamicText = dynamicChild.Value.Trim();
                                    if (!string.IsNullOrEmpty(dynamicText))
                                    {
                                        dynamicValues.Add(dynamicText);
                                    }
                                }
                                else
                                {
                                    dynamicValues.Add(dynamicChild.Name.LocalName);
                                }
                            }
                            directionTypeElements.Add(new Dynamics(
                                dynamicValues,
                                XmlHelper.GetAttributeValue(childElement, "color"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "default-x"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "default-y"),
                                XmlHelper.GetAttributeValue(childElement, "enclosure"),
                                XmlHelper.GetAttributeValue(childElement, "font-family"),
                                XmlHelper.GetAttributeValue(childElement, "font-size"),
                                XmlHelper.GetAttributeValue(childElement, "font-style"),
                                XmlHelper.GetAttributeValue(childElement, "font-weight"),
                                XmlHelper.GetAttributeValue(childElement, "halign"),
                                XmlHelper.GetAttributeValue(childElement, "id"),
                                XmlHelper.GetAttributeValueAsInt(childElement, "line-through"),
                                XmlHelper.GetAttributeValueAsInt(childElement, "overline"),
                                XmlHelper.GetAttributeValue(childElement, "placement"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "relative-x"),
                                XmlHelper.GetAttributeValueAsDouble(childElement, "relative-y"),
                                XmlHelper.GetAttributeValueAsInt(childElement, "underline"),
                                XmlHelper.GetAttributeValue(childElement, "valign")
                            ));
                            break;
                    }
                }
            }

            var offsetElement = directionElement.Elements("offset").FirstOrDefault();
            if (offsetElement != null)
            {
                var value = XmlHelper.GetElementTextAsDouble(offsetElement);
                if (value.HasValue)
                {
                    parsedOffset = new Offset(
                        value.Value,
                        XmlHelper.GetAttributeValue(offsetElement, "sound") == "yes"
                    );
                }
            }

            var staffElement = directionElement.Elements("staff").FirstOrDefault();
            if (staffElement != null)
            {
                var value = XmlHelper.GetElementTextAsInt(staffElement);
                if (value.HasValue)
                {
                    parsedStaff = new Staff(value.Value);
                }
            }

            var soundElement = directionElement.Elements("sound").FirstOrDefault();
            if (soundElement != null)
            {
                var timeOnlyValue = XmlHelper.GetAttributeValue(soundElement, "time-only");
                parsedSound = new Sound(
                    XmlHelper.GetAttributeValueAsDouble(soundElement, "tempo"),
                    XmlHelper.GetAttributeValueAsDouble(soundElement, "dynamics"),
                    XmlHelper.GetAttributeValue(soundElement, "dacapo") == "yes",
                    XmlHelper.GetAttributeValue(soundElement, "segno"),
                    XmlHelper.GetAttributeValue(soundElement, "coda"),
                    XmlHelper.GetAttributeValue(soundElement, "fine"),
                    string.IsNullOrEmpty(timeOnlyValue) ? (bool?)null : timeOnlyValue == "yes",
                    XmlHelper.GetAttributeValue(soundElement, "pizzicato") == "yes",
                    XmlHelper.GetAttributeValueAsDouble(soundElement, "pan"),
                    XmlHelper.GetAttributeValueAsDouble(soundElement, "elevation")
                );
            }

            if (!directionTypeElements.Any())
            {
                WarningSystem.AddWarning(
                    "Direction element without any <direction-type> children. Skipping this direction.",
                    category: WarningCategories.Structure,
                    elementName: directionElement.Name.LocalName, // Corrected parameter name
                    line: XmlHelper.GetLineNumber(directionElement),
                    context: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber } }
                );
                return null;
            }

            return new Direction(
                directionTypeElements,
                parsedOffset,
                parsedStaff,
                parsedSound,
                XmlHelper.GetAttributeValue(directionElement, "placement"),
                XmlHelper.GetAttributeValue(directionElement, "directive"),
                XmlHelper.GetAttributeValue(directionElement, "system"),
                XmlHelper.GetAttributeValue(directionElement, "id")
            );
        }

        private PrintObject ParsePrint(XElement printElement)
        {
            var newPageAttr = XmlHelper.GetAttributeValue(printElement, "new-page");
            var newSystemAttr = XmlHelper.GetAttributeValue(printElement, "new-system");
            var blankPageStr = XmlHelper.GetAttributeValue(printElement, "blank-page");
            var pageNumberStr = XmlHelper.GetAttributeValue(printElement, "page-number");

            var newPage = newPageAttr == "yes";
            var newSystem = newSystemAttr == "yes";
            int? blankPage = !string.IsNullOrEmpty(blankPageStr) && int.TryParse(blankPageStr, out int bp) ? bp : (int?)null;

            PageLayout localPageLayout = null;
            var pageLayoutElement = printElement.Elements("page-layout").FirstOrDefault();
            if (pageLayoutElement != null)
            {
                localPageLayout = _pageLayoutParser.Parse(pageLayoutElement);
            }

            SystemLayout localSystemLayout = null;
            var systemLayoutElement = printElement.Elements("system-layout").FirstOrDefault();
            if (systemLayoutElement != null)
            {
                localSystemLayout = _systemLayoutParser.Parse(systemLayoutElement);
            }

            var localStaffLayouts = new List<StaffLayout>();
            foreach (var staffLayoutElement in printElement.Elements("staff-layout"))
            {
                localStaffLayouts.Add(_staffLayoutParser.Parse(staffLayoutElement));
            }

            MeasureLayout measureLayout = null;
            var measureLayoutElement = printElement.Elements("measure-layout").FirstOrDefault();
            if (measureLayoutElement != null)
            {
                var measureDistanceElement = measureLayoutElement.Elements("measure-distance").FirstOrDefault();
                measureLayout = new MeasureLayout(
                    measureDistanceElement != null ? XmlHelper.GetElementTextAsDouble(measureDistanceElement) : null
                );
            }


            MeasureNumbering measureNumbering = null;
            var measureNumberingElement = printElement.Elements("measure-numbering").FirstOrDefault();
            if (measureNumberingElement != null)
            {
                measureNumbering = new MeasureNumbering(
                    MeasureNumbering.ParseValue(measureNumberingElement.Value.Trim()),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "color"),
                    XmlHelper.GetAttributeValueAsDouble(measureNumberingElement, "default-x"),
                    XmlHelper.GetAttributeValueAsDouble(measureNumberingElement, "default-y"),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "font-family"),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "font-size"),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "font-style"),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "font-weight"),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "halign"),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "multiple-rest-always") == "yes",
                    XmlHelper.GetAttributeValue(measureNumberingElement, "multiple-rest-range") == "yes",
                    XmlHelper.GetAttributeValueAsDouble(measureNumberingElement, "relative-x"),
                    XmlHelper.GetAttributeValueAsDouble(measureNumberingElement, "relative-y"),
                    XmlHelper.GetAttributeValueAsInt(measureNumberingElement, "staff"),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "system"),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "valign")
                );
            }

            return new PrintObject(
                newPage,
                newSystem,
                blankPage,
                pageNumberStr,
                localPageLayout,
                localSystemLayout,
                localStaffLayouts,
                measureLayout,
                measureNumbering
            );
        }
    }
}
