// Assuming necessary using statements for MusicXML models and helpers
using System.Xml.Linq;
using System.Linq;
using MusicXMLParser.Models; // For StaffLayout
using MusicXMLParser.Utils; // For XmlHelper
using MusicXMLParser.Exceptions; // If needed for validation

namespace MusicXMLParser.Parser
{
    /// <summary>
    /// Parser for <staff-layout> elements.
    /// </summary>
    public class StaffLayoutParser
    {
        public StaffLayout Parse(XElement element)
        {
            var numberStr = element.Attribute("number")?.Value;
            // Default to 1 if attribute is missing or invalid, as per typical MusicXML processor behavior
            // or throw validation exception if strictness is required.
            // The Dart code defaults to 1.
            int staffNumber = 1;
            if (!string.IsNullOrEmpty(numberStr))
            {
                if (int.TryParse(numberStr, out int parsedNumber))
                {
                    staffNumber = parsedNumber;
                }
                // Optionally, add a warning or exception if parsing fails but attribute exists
            }

            var staffDistance = XmlHelper.GetElementTextAsDouble(element.Elements("staff-distance").FirstOrDefault());

            // Assuming StaffLayout constructor can handle nullable staffDistance if it's optional in the model.
            // If staffDistance is required by the model and can't be null,
            // you might need to throw MusicXmlStructureException if it's missing.
            // The Dart model seems to allow null for staffDistance.
            return new StaffLayout(
                staffNumber: staffNumber,
                staffDistance: staffDistance
            );
        }
    }
}
