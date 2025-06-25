// Assuming necessary using statements for MusicXML models and helpers
using System.Xml.Linq;
using System.Linq;
using MusicXMLParser.Models; // For Scaling
using MusicXMLParser.Utils; // For XmlHelper
using MusicXMLParser.Exceptions; // For MusicXmlStructureException if strict parsing is needed

namespace MusicXMLParser.Parser
{
    /// <summary>
    /// Parser for <scaling> elements.
    /// </summary>
    public class ScalingParser
    {
        public Scaling Parse(XElement element)
        {
            var millimeters = XmlHelper.GetElementTextAsDouble(element.Elements("millimeters").FirstOrDefault());
            var tenths = XmlHelper.GetElementTextAsDouble(element.Elements("tenths").FirstOrDefault());

            if (!millimeters.HasValue)
            {
                throw new MusicXmlStructureException(
                    message: "<scaling> element missing required <millimeters> child or value.",
                    requiredElement: "millimeters",
                    parentElement: "scaling",
                    line: XmlHelper.GetLineNumber(element.Elements("millimeters").FirstOrDefault() ?? element),
                    context: null
                );
            }
            if (!tenths.HasValue)
            {
                 throw new MusicXmlStructureException(
                    message: "<scaling> element missing required <tenths> child or value.",
                    requiredElement: "tenths",
                    parentElement: "scaling",
                    line: XmlHelper.GetLineNumber(element.Elements("tenths").FirstOrDefault() ?? element),
                    context: null
                );
            }

            // Assuming the Scaling model constructor expects non-nullable doubles.
            return new Scaling(millimeters: millimeters.Value, tenths: tenths.Value);
        }
    }
}
