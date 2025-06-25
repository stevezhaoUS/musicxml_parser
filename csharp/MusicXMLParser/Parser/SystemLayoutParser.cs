// Assuming necessary using statements for MusicXML models and helpers
using System.Xml.Linq;
using System.Linq;
using MusicXMLParser.Models; // For SystemLayout, SystemMargins, SystemDividers
using MusicXMLParser.Utils; // For XmlHelper

namespace MusicXMLParser.Parser
{
    /// <summary>
    /// Parser for <system-layout> elements.
    /// </summary>
    public class SystemLayoutParser
    {
        public SystemLayout Parse(XElement element)
        {
            SystemMargins margins = null;
            var marginsElement = element.Elements("system-margins").FirstOrDefault();
            if (marginsElement != null)
            {
                margins = new SystemMargins(
                    leftMargin: MusicXMLParser.Utils.XmlHelper.GetElementTextAsDouble(marginsElement.Elements("left-margin").FirstOrDefault()),
                    rightMargin: MusicXMLParser.Utils.XmlHelper.GetElementTextAsDouble(marginsElement.Elements("right-margin").FirstOrDefault())
                );
            }

            SystemDividers dividers = null;
            var dividersElement = element.Elements("system-dividers").FirstOrDefault();
            if (dividersElement != null)
            {
                // Assuming GetElementTextAsBool returns bool? to handle missing elements.
                // If it returns bool and defaults to false for missing, that's also fine.
                // The SystemDividers model should clarify if these are nullable or default to false.
                // Based on Dart's XmlHelper.getElementTextAsBool, it likely returns bool and defaults to false.
                dividers = new SystemDividers(
                    leftDivider: XmlHelper.GetElementTextAsBool(dividersElement.Elements("left-divider").FirstOrDefault()),
                    rightDivider: XmlHelper.GetElementTextAsBool(dividersElement.Elements("right-divider").FirstOrDefault())
                );
            }

            var systemDistance = XmlHelper.GetElementTextAsDouble(element.Elements("system-distance").FirstOrDefault());
            var topSystemDistance = XmlHelper.GetElementTextAsDouble(element.Elements("top-system-distance").FirstOrDefault());

            // Assuming SystemLayout constructor handles nullable properties appropriately.
            return new SystemLayout(
                systemMargins: margins,
                systemDistance: systemDistance,
                topSystemDistance: topSystemDistance,
                systemDividers: dividers
            );
        }
    }
}
