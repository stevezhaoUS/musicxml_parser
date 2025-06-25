// Assuming necessary using statements for MusicXML models, exceptions, and helpers
using System.Xml.Linq;
using System.Linq;
using MusicXMLParser.Models; // For Part, Measure, KeySignature, TimeSignature etc.
using MusicXMLParser.Exceptions; // For MusicXmlStructureException, MusicXmlValidationException
using MusicXMLParser.Utils; // For WarningSystem and XmlHelper

namespace MusicXMLParser.Parser
{
    public class PartParser
    {
        private readonly MeasureParser _measureParser;
        public WarningSystem WarningSystem { get; }

        public PartParser(MeasureParser? measureParser = null, WarningSystem? warningSystem = null)
        {
            WarningSystem = warningSystem ?? new WarningSystem();
            _measureParser = measureParser ?? new MeasureParser(warningSystem: WarningSystem);
        }

        public Part Parse(XElement element, XElement? partListElement)
        {
            var line = XmlHelper.GetLineNumber(element);
            var id = element.Attribute("id")?.Value;

            if (string.IsNullOrEmpty(id))
            {
                throw new MusicXmlStructureException(
                    message: "Part element is missing required \"id\" attribute",
                    requiredElement: "id",
                    parentElement: "part",
                    line: line,
                    context: null // No specific context beyond element info
                );
            }

            string name = null;
            if (partListElement != null)
            {
                var scorePartElement = partListElement.Elements("score-part")
                                             .FirstOrDefault(sp => sp.Attribute("id")?.Value == id);

                if (scorePartElement == null)
                {
                    // This is a validation issue: a part in the score refers to an ID not in part-list
                    // Depending on strictness, this could be a warning or an exception.
                    // The Dart version throws MusicXmlValidationException.
                    throw new MusicXmlValidationException(
                        message: $"Part ID {id} not found in part-list",
                        line: line,
                        context: new System.Collections.Generic.Dictionary<string, object> { { "partId", id } }
                    );
                }
                name = XmlHelper.FindOptionalTextElement(scorePartElement, "part-name");
            }

            var partBuilder = new PartBuilder(id).SetName(name); // Removed line argument

            int? activeDivisions = null;
            KeySignature activeKeySignature = null;
            TimeSignature activeTimeSignature = null;
            // In C#, List<Clef> would need to be managed similarly if it's inherited across measures.
            // For now, focusing on the attributes explicitly handled in the Dart version's loop.
            // List<Clef> activeClefs = null;


            foreach (var measureElement in element.Elements("measure"))
            {
                var measure = _measureParser.Parse(
                    measureElement,
                    id,
                    inheritedDivisions: activeDivisions,
                    inheritedKeySignature: activeKeySignature,
                    inheritedTimeSignature: activeTimeSignature
                    // inheritedClefs: activeClefs // Pass if clefs are managed this way
                );
                partBuilder.AddMeasure(measure);

                // Update active attributes for the *next* measure
                var attributesInMeasure = measureElement.Elements("attributes").FirstOrDefault();
                if (attributesInMeasure != null)
                {
                    var divisionsElement = attributesInMeasure.Elements("divisions").FirstOrDefault();
                    if (divisionsElement != null)
                    {
                        if (int.TryParse(divisionsElement.Value.Trim(), out int newDivisions) && newDivisions > 0)
                        {
                            activeDivisions = newDivisions;
                        }
                    }
                }

                // The measure object itself contains the key/time/clefs that applied to it.
                if (measure.KeySignature != null)
                {
                    activeKeySignature = measure.KeySignature;
                }
                if (measure.TimeSignature != null)
                {
                    activeTimeSignature = measure.TimeSignature;
                }
                // if (measure.Clefs != null && measure.Clefs.Any()) // Assuming Clefs is a List<Clef>
                // {
                // activeClefs = measure.Clefs;
                // }
            }
            return partBuilder.Build();
        }
    }
}
