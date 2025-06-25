// Assuming necessary using statements for MusicXML models and helpers
using System.Xml.Linq;
using System.Collections.Generic;
using System.Linq;
using MusicXMLParser.Models; // For PageLayout, PageMargins
using MusicXMLParser.Utils; // For XmlHelper

namespace MusicXMLParser.Parser
{
    /// <summary>
    /// Parser for <page-layout> elements.
    /// </summary>
    public class PageLayoutParser
    {
        public PageLayout Parse(XElement element)
        {
            var pageHeight = XmlHelper.GetElementTextAsDouble(element.Elements("page-height").FirstOrDefault());
            var pageWidth = XmlHelper.GetElementTextAsDouble(element.Elements("page-width").FirstOrDefault());
            var margins = new List<PageMargins>();

            foreach (var marginElement in element.Elements("page-margins"))
            {
                var type = marginElement.Attribute("type")?.Value;
                var left = XmlHelper.GetElementTextAsDouble(marginElement.Elements("left-margin").FirstOrDefault());
                var right = XmlHelper.GetElementTextAsDouble(marginElement.Elements("right-margin").FirstOrDefault());
                var top = XmlHelper.GetElementTextAsDouble(marginElement.Elements("top-margin").FirstOrDefault());
                var bottom = XmlHelper.GetElementTextAsDouble(marginElement.Elements("bottom-margin").FirstOrDefault());

                // Assuming PageMargins constructor handles nulls appropriately or they are validated before this point.
                // For now, let's assume the model PageMargins can handle nullable doubles if that's the design.
                // If not, checks for null and default values or exceptions would be needed here.
                margins.Add(new PageMargins(
                    type: type,
                    leftMargin: left,
                    rightMargin: right,
                    topMargin: top,
                    bottomMargin: bottom
                ));
            }

            return new PageLayout(
                pageHeight: pageHeight,
                pageWidth: pageWidth,
                pageMargins: margins.Any() ? margins : null // Return null if no margins found, or an empty list, based on model design
            );
        }
    }
}
