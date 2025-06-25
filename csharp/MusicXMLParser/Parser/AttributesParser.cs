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
                    if (divisionsValue <= 0)
                    {
                        throw new MusicXmlValidationException(
                            message: $"Divisions value must be positive, got {divisionsValue}",
                            rule: "divisions_positive_validation",
                            line: MusicXMLParser.Utils.XmlHelper.GetLineNumber(divisionsElement),
                            context: new Dictionary<string, object>
                            {
                                { "part", partId },
                                { "measure", measureNumber },
                                { "divisions", divisionsValue }
                            }
                        );
                    }
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
            // Assuming KeySignature.FromXElement exists and works similarly to the Dart version
            return KeySignature.FromXElement(element, partId, measureNumber);
        }

        private TimeSignature ParseTimeSignature(
            XElement element,
            string partId,
            string measureNumber)
        {
            // Assuming TimeSignature.FromXElement exists and works similarly to the Dart version
            return TimeSignature.FromXElement(element, partId, measureNumber);
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
            if (string.IsNullOrEmpty(sign))
            {
                throw new MusicXmlValidationException(
                    message: "Clef <sign> element cannot be empty.",
                    rule: "clef_sign_not_empty",
                    line: XmlHelper.GetLineNumber(signElement),
                    context: context
                );
            }

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

            if (new[] { "G", "F", "C" }.Contains(sign) && line == null)
            {
                throw new MusicXmlValidationException(
                    message: $"Clef sign \"{sign}\" requires a <line> element.",
                    rule: "clef_line_required_for_sign",
                    line: XmlHelper.GetLineNumber(element),
                    context: new Dictionary<string, object>(context) { { "sign", sign } }
                );
            }

            return new Clef(sign, line, octaveChange, number);
        }
    }
}
