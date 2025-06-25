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

                // Using object initializer syntax as PageMargins relies on public setters
                margins.Add(new PageMargins
                {
                    Type = type,
                    LeftMargin = left,
                    RightMargin = right,
                    TopMargin = top,
                    BottomMargin = bottom
                });
            }

            // Using object initializer syntax as PageLayout relies on public setters
            return new PageLayout
            {
                PageHeight = pageHeight,
                PageWidth = pageWidth,
                // Ensure PageMargins is always initialized, even if empty, to avoid null reference on the list itself.
                PageMargins = margins.Any() ? margins : new List<PageMargins>()
            };
        }
    }
}
