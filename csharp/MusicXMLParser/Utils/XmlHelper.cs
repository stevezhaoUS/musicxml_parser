using System.Xml; // Required for IXmlLineInfo
using System.Xml.Linq;

namespace MusicXMLParser.Utils
{
    /// <summary>
    /// Utility class providing helper methods for parsing MusicXML documents using System.Xml.Linq.
    /// </summary>
    public static class XmlHelper
    {
        /// <summary>
        /// Gets the line number of an XML <see cref="XElement"/> by looking for a non-standard 'line' attribute.
        /// This mimics the behavior of a similar helper in the original Dart parser.
        /// </summary>
        /// <param name="element">The XML element.</param>
        /// <returns>The line number if the 'line' attribute is found and is a valid integer; otherwise, null.</returns>
        public static int? GetLineNumberFromAttribute(XElement? element)
        {
            if (element == null)
            {
                return null;
            }

            var lineAttribute = element.Attribute("line");
            if (lineAttribute != null)
            {
                if (int.TryParse(lineAttribute.Value, out int lineNum))
                {
                    return lineNum;
                }
            }
            return null; // Return null if attribute not found or not a valid int
        }

        /// <summary>
        /// Gets the line number of an XML <see cref="XElement"/> using the standard <see cref="IXmlLineInfo"/> interface.
        /// Note: The XML document must have been loaded with LoadOptions.SetLineInfo for this to work.
        /// </summary>
        /// <param name="element">The XML element.</param>
        /// <returns>The line number if available; otherwise, null.</returns>
        public static int? GetActualLineNumber(XElement? element)
        {
            if (element == null)
            {
                return null;
            }

            IXmlLineInfo? lineInfo = element as IXmlLineInfo;
            if (lineInfo != null && lineInfo.HasLineInfo())
            {
                return lineInfo.LineNumber;
            }
            return null; // Return null if no line info is available
        }

        /// <summary>
        /// Gets a line number for an <see cref="XElement"/>.
        /// It first attempts to get the line number from a non-standard 'line' attribute (for compatibility with Dart version).
        /// If not found, it falls back to the standard <see cref="IXmlLineInfo"/> if available.
        /// </summary>
        /// <param name="element">The XML element.</param>
        /// <returns>The line number as an int?, or null if not found through either method.</returns>
        public static int? GetLineNumber(XElement? element)
        {
            if (element == null)
            {
                return null;
            }

            // First, try the custom 'line' attribute method (Dart compatibility)
            int? lineNumber = GetLineNumberFromAttribute(element);
            if (lineNumber.HasValue)
            {
                return lineNumber;
            }

            // Fallback to standard IXmlLineInfo
            return GetActualLineNumber(element);
        }
    }
}
