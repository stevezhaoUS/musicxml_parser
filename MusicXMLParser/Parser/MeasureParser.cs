// Assuming the necessary using statements for MusicXML models, exceptions, and helpers
using System.Xml.Linq;
using System.Collections.Generic;
using System.Linq;
using MusicXMLParser.Models; // For Measure, Note, KeySignature, TimeSignature, Clef, Barline, Ending, Direction, PrintObject etc.
using MusicXMLParser.Models.DirectionTypeElements; // Added for IDirectionTypeElement and its implementations
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
        
        // 缓存常用的上下文字典以减少内存分配
        private readonly Dictionary<string, object> _sharedContext = new();

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
                    context: CreateContext(partId)
                );
            }

            if (!int.TryParse(numberAttr, out int measureNum) || measureNum < 0)
            {
                throw new MusicXmlValidationException(
                    message: $"Invalid measure number: {numberAttr}",
                    line: line,
                    context: CreateContext(partId, "measure", numberAttr)
                );
            }

            var isPickup = (numberAttr == "0" && implicitAttr == "yes");
            if (measureNum == 0 && !isPickup)
            {
                throw new MusicXmlValidationException(
                    message: $"Invalid measure number: {numberAttr}",
                    line: line,
                    context: CreateContext(partId, "measure", numberAttr)
                );
            }

            var widthAttr = XmlHelper.GetAttributeValue(element, "width");
            double? width = !string.IsNullOrEmpty(widthAttr) && double.TryParse(widthAttr, out double w) ? w : (double?)null;

            var measureBuilder = new MeasureBuilder(numberAttr, line, CreateContext(partId))
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
                        if (attributesData.TryGetValue("divisions", out var divisionsObj) && divisionsObj is int divisionsValue)
                        {
                            currentDivisions = divisionsValue;
                        }
                        if (attributesData.TryGetValue("keySignature", out var keySignatureObj) && keySignatureObj is KeySignature keySignature)
                        {
                            measureBuilder.SetKeySignature(keySignature);
                        }
                        if (attributesData.TryGetValue("timeSignature", out var timeSignatureObj) && timeSignatureObj is TimeSignature timeSignature)
                        {
                            measureBuilder.SetTimeSignature(timeSignature);
                        }
                        if (attributesData.TryGetValue("clefs", out var clefsObj) && clefsObj is List<Clef> clefs)
                        {
                            measureBuilder.SetClefs(clefs);
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

        // 优化的上下文创建方法，减少内存分配
        private Dictionary<string, object> CreateContext(string partId, string? additionalKey = null, object? additionalValue = null)
        {
            _sharedContext.Clear();
            _sharedContext["part"] = partId;
            
            if (additionalKey != null && additionalValue != null)
            {
                _sharedContext[additionalKey] = additionalValue;
            }
            
            return new Dictionary<string, object>(_sharedContext);
        }

        private void ParseBackupOrForward(XElement element, string type, string partId, string measureNumber)
        {
            var durationElement = element.Element("duration");
            if (durationElement == null)
            {
                throw new MusicXmlStructureException(
                    message: $"<{type}> element missing required <duration> child.",
                    parentElement: type,
                    line: XmlHelper.GetLineNumber(element),
                    context: CreateContext(partId, "measure", measureNumber)
                );
            }
            var duration = XmlHelper.GetElementTextAsInt(durationElement);
            if (duration == null || duration < 0)
            {
                throw new MusicXmlStructureException(
                    message: $"Invalid or missing duration value for <{type}>.",
                    parentElement: type,
                    line: XmlHelper.GetLineNumber(durationElement),
                    context: CreateContext(partId, "parsedDuration", duration)
                );
            }
            WarningSystem.AddWarning(
                message: $"Encountered <{type}> with duration {duration}. Full timeline impact not yet implemented.",
                category: WarningCategories.Generic,
                rule: $"{type}_partially_processed",
                line: XmlHelper.GetLineNumber(element),
                elementName: type,
                context: CreateContext(partId, "duration", duration)
            );
        }

        private Barline ParseBarline(XElement barlineElement)
        {
            string location = XmlHelper.GetAttributeValue(barlineElement, "location") ?? "";
            XElement barStyleElement = barlineElement.Element("bar-style");
            string barStyle = barStyleElement?.Value.Trim() ?? "";
            XElement repeatElement = barlineElement.Element("repeat");
            string? repeatDirection = null;
            int? repeatTimes = null;
            if (repeatElement != null)
            {
                repeatDirection = XmlHelper.GetAttributeValue(repeatElement, "direction");
                string timesStr = XmlHelper.GetAttributeValue(repeatElement, "times");
                repeatTimes = !string.IsNullOrEmpty(timesStr) && int.TryParse(timesStr, out int times) ? times : (int?)null;
            }
            return new Barline(location, barStyle, repeatDirection ?? "", repeatTimes);
        }

        private Ending? ParseEnding(XElement endingElement, string partId, string measureNumber)
        {
            var numberAttr = XmlHelper.GetAttributeValue(endingElement, "number");
            var typeAttr = XmlHelper.GetAttributeValue(endingElement, "type");
            var printObjectAttr = XmlHelper.GetAttributeValue(endingElement, "print-object");

            // 使用优化的方法获取元素文本
            var numberText = XmlHelper.GetElementText(endingElement, "ending-number");
            var typeText = XmlHelper.GetElementText(endingElement, "ending-type");

            // 优先使用属性值，如果没有则使用元素文本
            var number = !string.IsNullOrEmpty(numberAttr) ? numberAttr : numberText;
            var type = !string.IsNullOrEmpty(typeAttr) ? typeAttr : typeText;

            bool? printObject = null;
            if (!string.IsNullOrEmpty(printObjectAttr))
            {
                printObject = printObjectAttr == "yes";
            }

            if (!string.IsNullOrEmpty(number) || !string.IsNullOrEmpty(type))
            {
                string printObjectStr = printObject == true ? "yes" : (printObject == false ? "no" : "yes");
                return new Ending(number ?? "", type ?? "", printObjectStr);
            }

            return null;
        }

        private Direction? ParseDirection(XElement directionElement, string partId, string measureNumber)
        {
            var directionTypes = new List<IDirectionTypeElement>();

            foreach (var childElement in directionElement.Elements())
            {
                switch (childElement.Name.LocalName)
                {
                    case "words":
                        var text = childElement.Value.Trim();
                        if (!string.IsNullOrEmpty(text))
                        {
                            directionTypes.Add(new WordsDirection(
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
                        }
                        else
                        {
                            WarningSystem.AddWarning(
                                message: "Empty <words> element found in direction.",
                                category: WarningCategories.Structure,
                                elementName: "words",
                                line: XmlHelper.GetLineNumber(childElement),
                                context: CreateContext(partId, "measure", measureNumber));
                        }
                        break;
                    case "segno":
                        directionTypes.Add(new Segno(
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
                        directionTypes.Add(new Coda(
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
                        var dynamicsValues = new List<string>();
                        foreach (var dynamicsChild in childElement.Elements())
                        {
                            var dynamicsText = dynamicsChild.Value.Trim();
                            if (!string.IsNullOrEmpty(dynamicsText))
                            {
                                dynamicsValues.Add(dynamicsText);
                            }
                        }
                        directionTypes.Add(new Dynamics(
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
                            XmlHelper.GetAttributeValue(childElement, "valign"),
                            dynamicsValues
                        ));
                        break;
                }
            }

            if (directionTypes.Count == 0)
            {
                return null;
            }

            // 使用优化的方法获取属性值
            var offset = ParseOffset(directionElement);
            var staff = ParseStaff(directionElement);
            var sound = ParseSound(directionElement);

            return new Direction(
                directionTypes,
                offset,
                staff,
                sound,
                XmlHelper.GetAttributeValue(directionElement, "placement"),
                XmlHelper.GetAttributeValue(directionElement, "directive"),
                XmlHelper.GetAttributeValue(directionElement, "system"),
                XmlHelper.GetAttributeValue(directionElement, "id")
            );
        }

        private Offset? ParseOffset(XElement element)
        {
            var offsetElement = element.Element("offset");
            if (offsetElement == null) return null;

            var offsetValue = XmlHelper.GetElementTextAsDouble(offsetElement);
            if (!offsetValue.HasValue) return null;

            return new Offset(offsetValue.Value);
        }

        private Staff? ParseStaff(XElement element)
        {
            var staffElement = element.Element("staff");
            if (staffElement == null) return null;

            var staffValue = XmlHelper.GetElementTextAsInt(staffElement);
            if (!staffValue.HasValue) return null;

            return new Staff(staffValue.Value);
        }

        private Sound? ParseSound(XElement element)
        {
            var soundElement = element.Element("sound");
            if (soundElement == null) return null;

            var tempo = XmlHelper.GetAttributeValueAsDouble(soundElement, "tempo");
            var dynamics = XmlHelper.GetAttributeValueAsDouble(soundElement, "dynamics");
            var dacapo = XmlHelper.GetAttributeValueAsBool(soundElement, "dacapo");
            var segno = XmlHelper.GetAttributeValue(soundElement, "segno");
            var coda = XmlHelper.GetAttributeValue(soundElement, "coda");
            var fine = XmlHelper.GetAttributeValue(soundElement, "fine");
            var timeOnly = XmlHelper.GetAttributeValueAsBool(soundElement, "time-only");
            var pizzicato = XmlHelper.GetAttributeValueAsBool(soundElement, "pizzicato");
            var pan = XmlHelper.GetAttributeValueAsDouble(soundElement, "pan");
            var elevation = XmlHelper.GetAttributeValueAsDouble(soundElement, "elevation");

            return new Sound(
                tempo,
                dynamics,
                dacapo,
                segno,
                coda,
                fine,
                timeOnly,
                pizzicato,
                pan,
                elevation
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

            PageLayout? localPageLayout = null;
            var pageLayoutElement = printElement.Element("page-layout");
            if (pageLayoutElement != null)
            {
                localPageLayout = _pageLayoutParser.Parse(pageLayoutElement);
            }

            SystemLayout? localSystemLayout = null;
            var systemLayoutElement = printElement.Element("system-layout");
            if (systemLayoutElement != null)
            {
                localSystemLayout = _systemLayoutParser.Parse(systemLayoutElement);
            }

            var localStaffLayouts = new List<StaffLayout>();
            foreach (var staffLayoutElement in printElement.Elements("staff-layout"))
            {
                localStaffLayouts.Add(_staffLayoutParser.Parse(staffLayoutElement));
            }

            MeasureLayoutInfo? measureLayout = null;
            var measureLayoutElement = printElement.Element("measure-layout");
            if (measureLayoutElement != null)
            {
                var measureDistance = XmlHelper.GetElementTextAsDouble(measureLayoutElement);
                measureLayout = new MeasureLayoutInfo(measureDistance);
            }

            MeasureNumbering? measureNumbering = null;
            var measureNumberingElement = printElement.Element("measure-numbering");
            if (measureNumberingElement != null)
            {
                var value = measureNumberingElement.Value.Trim();
                var measureNumberingValue = value switch
                {
                    "none" => MeasureNumberingValue.None,
                    "measure" => MeasureNumberingValue.Measure,
                    "system" => MeasureNumberingValue.System,
                    _ => MeasureNumberingValue.None
                };

                measureNumbering = new MeasureNumbering(
                    measureNumberingValue,
                    XmlHelper.GetAttributeValue(measureNumberingElement, "color"),
                    XmlHelper.GetAttributeValueAsDouble(measureNumberingElement, "default-x"),
                    XmlHelper.GetAttributeValueAsDouble(measureNumberingElement, "default-y"),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "font-family"),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "font-size"),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "font-style"),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "font-weight"),
                    XmlHelper.GetAttributeValue(measureNumberingElement, "halign"),
                    XmlHelper.GetAttributeValueAsBool(measureNumberingElement, "multiple-rest-always") ?? false,
                    XmlHelper.GetAttributeValueAsBool(measureNumberingElement, "multiple-rest-range") ?? false,
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
