// Assuming the necessary using statements for MusicXML models and exceptions
// e.g., using MusicXMLParser.Models; using MusicXMLParser.Exceptions;
using System.Xml;
using System.Xml.Linq;
using System.Collections.Generic;
using System.Linq; // Required for FirstOrDefault and other LINQ methods
using MusicXMLParser.Models; // Assuming this is where Clef, KeySignature, TimeSignature are
using MusicXMLParser.Exceptions; // Assuming this is where the custom exceptions are
using MusicXMLParser.Utils; // For XmlHelper

namespace MusicXMLParser.Parser
{
    public class AttributesParser
    {
        public AttributesParser() { }

        public Dictionary<string, object> Parse(
            XElement element,
            string partId,
            string measureNumber,
            int? currentDivisions)
        {
            int? divisions = currentDivisions;
            KeySignature keySignature = null;
            TimeSignature timeSignature = null;
            List<Clef> clefs = new List<Clef>();

            // Parse divisions
            var divisionsElement = element.Elements("divisions").FirstOrDefault();
            if (divisionsElement != null)
            {
                string divisionsText = divisionsElement.Value.Trim();
                if (int.TryParse(divisionsText, out int divisionsValue))
                {
                    // Validation for divisionsValue <= 0 removed as per deferring validation.
                    divisions = divisionsValue;
                }
                else
                {
                    throw new MusicXmlParseException(
                        message: $"Invalid divisions value \"{divisionsText}\"",
                        elementName: "divisions",
                        line: MusicXMLParser.Utils.XmlHelper.GetLineNumber(divisionsElement),
                        context: new Dictionary<string, object>
                        {
                            { "part", partId },
                            { "measure", measureNumber }
                        }
                    );
                }
            }

            // Parse key signature
            var keyElement = element.Elements("key").FirstOrDefault();
            if (keyElement != null)
            {
                keySignature = ParseKeySignature(keyElement, partId, measureNumber);
            }

            // Parse time signature
            var timeElement = element.Elements("time").FirstOrDefault();
            if (timeElement != null)
            {
                timeSignature = ParseTimeSignature(timeElement, partId, measureNumber);
            }

            // Parse clef elements
            foreach (var clefElement in element.Elements("clef"))
            {
                clefs.Add(ParseClef(clefElement, partId, measureNumber));
            }

            var parsedAttributes = new Dictionary<string, object>
            {
                { "divisions", divisions },
                { "keySignature", keySignature },
                { "timeSignature", timeSignature }
            };
            if (clefs.Any())
            {
                parsedAttributes["clefs"] = clefs;
            }
            return parsedAttributes;
        }

        private KeySignature ParseKeySignature(
            XElement element,
            string partId,
            string measureNumber)
        {
            var line = XmlHelper.GetLineNumber(element);
            var context = new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber } };

            var fifthsElement = element.Elements("fifths").FirstOrDefault();
            if (fifthsElement == null)
            {
                throw new MusicXmlStructureException(
                    "Required <fifths> element not found in <key>",
                    requiredElement: "fifths",
                    parentElement: "key",
                    line: line,
                    context: context
                );
            }
            var fifthsText = fifthsElement.Value.Trim();
            if (!int.TryParse(fifthsText, out var fifths))
            {
                throw new MusicXmlParseException(
                    $"Invalid key signature fifths value: \"{fifthsText}\". Must be an integer.",
                    elementName: "fifths",
                    line: XmlHelper.GetLineNumber(fifthsElement),
                    context: new Dictionary<string, object>(context) { { "parsedFifths", fifthsText } }
                );
            }

            var modeElement = element.Elements("mode").FirstOrDefault();
            var mode = modeElement?.Value.Trim();
            if (string.IsNullOrEmpty(mode)) // Treat empty mode string as null
            {
                mode = null;
            }

            return new KeySignature(fifths, mode);
        }

        private TimeSignature ParseTimeSignature(
            XElement element,
            string partId,
            string measureNumber)
        {
            var elementLineNumber = XmlHelper.GetLineNumber(element);
            var context = new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber } };

            var beatsElement = element.Elements("beats").FirstOrDefault();
            if (beatsElement == null)
            {
                throw new MusicXmlStructureException(
                    "Required <beats> element not found in <time>",
                    requiredElement: "beats",
                    parentElement: "time",
                    line: elementLineNumber,
                    context: context
                );
            }
            var beatsText = beatsElement.Value.Trim();
            if (!int.TryParse(beatsText, System.Globalization.NumberStyles.Integer, System.Globalization.CultureInfo.InvariantCulture, out int beats))
            {
                // For now, throw a structure/parse exception. Warning and returning null could be an alternative.
                throw new MusicXmlParseException(
                    $"Invalid time signature beats (numerator) value: \"{beatsText}\". Must be an integer.",
                    elementName: "beats",
                    line: XmlHelper.GetLineNumber(beatsElement),
                    context: new Dictionary<string, object>(context) { { "parsedBeats", beatsText } }
                );
            }

            var beatTypeElement = element.Elements("beat-type").FirstOrDefault();
            if (beatTypeElement == null)
            {
                throw new MusicXmlStructureException(
                    "Required <beat-type> element not found in <time>",
                    requiredElement: "beat-type",
                    parentElement: "time",
                    line: elementLineNumber,
                    context: context
                );
            }
            var beatTypeText = beatTypeElement.Value.Trim();
            if (!int.TryParse(beatTypeText, System.Globalization.NumberStyles.Integer, System.Globalization.CultureInfo.InvariantCulture, out int beatType))
            {
                // For now, throw a structure/parse exception.
                throw new MusicXmlParseException(
                    $"Invalid time signature beat-type (denominator) value: \"{beatTypeText}\". Must be an integer.",
                    elementName: "beat-type",
                    line: XmlHelper.GetLineNumber(beatTypeElement),
                    context: new Dictionary<string, object>(context) { { "parsedBeatType", beatTypeText } }
                );
            }

            return new TimeSignature(beats, beatType);
        }

        private Clef ParseClef(
            XElement element,
            string partId,
            string measureNumber)
        {
            var context = new Dictionary<string, object>
            {
                { "part", partId },
                { "measure", measureNumber },
                { "line", MusicXMLParser.Utils.XmlHelper.GetLineNumber(element) }
            };

            var signElement = element.Elements("sign").FirstOrDefault();
            if (signElement == null)
            {
                throw new MusicXmlStructureException(
                    message: "Clef element missing required <sign> child.",
                    parentElement: "clef",
                    line: XmlHelper.GetLineNumber(element),
                    context: context
                );
            }
            string sign = signElement.Value.Trim();
            // Validation for string.IsNullOrEmpty(sign) removed as per deferring validation.
            // If sign is empty, it will be passed as such to the Clef constructor.

            int? line = null;
            var lineElement = element.Elements("line").FirstOrDefault();
            if (lineElement != null)
            {
                string lineText = lineElement.Value.Trim();
                if (int.TryParse(lineText, out int lineValue))
                {
                    line = lineValue;
                }
                else
                {
                    throw new MusicXmlParseException(
                        message: $"Invalid clef line value \"{lineText}\"",
                        elementName: "line",
                        line: XmlHelper.GetLineNumber(lineElement),
                        context: context
                    );
                }
            }

            int? octaveChange = null;
            var octaveChangeElement = element.Elements("clef-octave-change").FirstOrDefault();
            if (octaveChangeElement != null)
            {
                string octaveChangeText = octaveChangeElement.Value.Trim();
                if (int.TryParse(octaveChangeText, out int octaveChangeValue))
                {
                    octaveChange = octaveChangeValue;
                }
                else
                {
                    throw new MusicXmlParseException(
                        message: $"Invalid clef-octave-change value \"{octaveChangeText}\"",
                        elementName: "clef-octave-change",
                        line: XmlHelper.GetLineNumber(octaveChangeElement),
                        context: context
                    );
                }
            }

            string numberStr = XmlHelper.GetAttributeValue(element, "number");
            int? number = null;
            if (numberStr != null)
            {
                if (int.TryParse(numberStr, out int numberValue))
                {
                    number = numberValue;
                }
                else
                {
                    throw new MusicXmlParseException(
                        message: $"Invalid clef number attribute \"{numberStr}\"",
                        elementName: "clef", // Or attributeName: "number" if you want to be more specific
                        line: XmlHelper.GetLineNumber(element),
                        context: context
                    );
                }
            }

            // Validation for G,F,C clefs requiring a line element removed.
            // This will be handled by a later validation pass or by consuming logic if critical.

            return new Clef(sign, line, octaveChange, number);
        }
    }
}
