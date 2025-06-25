using System.Xml.Linq;
using System.Linq;
using MusicXMLParser.Exceptions; // Assuming MusicXmlStructureException is in this namespace
using System.Text.RegularExpressions; // For regex in FindOptionalTextElement
using System.Xml; // For IXmlLineInfo

namespace MusicXMLParser.Utils
{
    public static class XmlHelper
    {
        public static int GetLineNumber(XElement? element)
        {
            if (element == null) return -1;

            // Standard way to get line info in System.Xml.Linq
            IXmlLineInfo? lineInfo = element as IXmlLineInfo; // Use 'as' for safer casting
            if (lineInfo != null && lineInfo.HasLineInfo())
            {
                return lineInfo.LineNumber;
            }

            // Fallback for non-standard 'line' attribute (as in Dart version)
            var lineAttribute = element.Attribute("line")?.Value;
            if (lineAttribute != null && int.TryParse(lineAttribute, out int lineNum))
            {
                return lineNum;
            }
            return -1;
        }

        public static string? FindOptionalTextElement(XElement? element, string path)
        {
            if (element == null || string.IsNullOrEmpty(path)) return null;

            XElement? currentContextNode = element; // currentContextNode can become null
            var pathSegments = path.Split('/');

            for (int i = 0; i < pathSegments.Length; i++)
            {
                if (currentContextNode == null) return null;
                string segment = pathSegments[i];

                if (segment.StartsWith("@"))
                {
                    if (i == pathSegments.Length - 1)
                    {
                        var attributeName = segment.Substring(1);
                        return currentContextNode.Attribute(attributeName)?.Value;
                    }
                    else
                    {
                        return null; // Attribute selection in middle of path not supported
                    }
                }
                else
                {
                    currentContextNode = FindElementFromSegment(currentContextNode, segment);
                }
            }
            return currentContextNode?.Value.Trim();
        }

        private static XElement? FindElementFromSegment(XElement? parent, string segment)
        {
            if (parent == null) return null; // Added null check

            var predicateMatch = Regex.Match(segment, @"(.+?)\[(.+?)\]");

            if (predicateMatch.Success)
            {
                string elementName = predicateMatch.Groups[1].Value;
                string predicate = predicateMatch.Groups[2].Value;

                var attributePredicateMatch = Regex.Match(predicate, @"@(.+?)=""(.+?)""");
                if (attributePredicateMatch.Success)
                {
                    string attributeName = attributePredicateMatch.Groups[1].Value;
                    string attributeValue = attributePredicateMatch.Groups[2].Value;
                    return parent.Elements(elementName)
                                 .FirstOrDefault(el => el.Attribute(attributeName)?.Value == attributeValue);
                }
                // Fallback for unhandled or malformed predicate
                return parent.Elements(elementName).FirstOrDefault();
            }
            else
            {
                return parent.Elements(segment).FirstOrDefault();
            }
        }

        public static XElement GetRequiredElement(XElement parent, string name, string? requiredElement = null)
        {
            // parent is assumed to be non-null by contract of this method.
            // If parent could be null, an ArgumentNullException or different handling is needed.
            var elements = parent.Elements(name);
            if (!elements.Any())
            {
                throw new MusicXmlStructureException(
                    $"Required element <{requiredElement ?? name}> not found as a child of <{parent.Name.LocalName}>.",
                    requiredElement ?? name,
                    parent.Name.LocalName,
                    GetLineNumber(parent),
                    null // context can be null here
                );
            }
            return elements.First();
        }

        public static XElement? FindOptionalElement(XElement? parent, string name)
        {
            return parent?.Elements(name).FirstOrDefault(); // Use null-conditional access
        }

        public static int? GetElementTextAsInt(XElement? element)
        {
            if (element == null) return null;
            var text = element.Value.Trim();
            return int.TryParse(text, out int result) ? result : (int?)null;
        }

        public static double? GetElementTextAsDouble(XElement? element)
        {
            if (element == null) return null;
            var text = element.Value.Trim();
            // Use System.Globalization.CultureInfo.InvariantCulture for consistent parsing
            return double.TryParse(text, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out double result) ? result : (double?)null;
        }

        public static bool GetElementTextAsBool(XElement? element, bool defaultValue = false)
        {
            if (element == null) return defaultValue;
            var text = element.Value.Trim().ToLowerInvariant();
            if (text == "yes") return true;
            if (text == "no") return false;
            return defaultValue;
        }

        public static string? GetAttributeValue(XElement? element, string attributeName)
        {
            return element?.Attribute(attributeName)?.Value;
        }

        public static double? GetAttributeValueAsDouble(XElement? element, string attributeName)
        {
            var attributeValue = element?.Attribute(attributeName)?.Value;
            if (attributeValue == null) return null;
            // Use System.Globalization.CultureInfo.InvariantCulture for consistent parsing
            return double.TryParse(attributeValue, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out double result) ? result : (double?)null;
        }

        public static int? GetAttributeValueAsInt(XElement? element, string attributeName)
        {
            var attributeValue = element?.Attribute(attributeName)?.Value;
            if (attributeValue == null) return null;
            return int.TryParse(attributeValue, out int result) ? result : (int?)null;
        }

        public static bool? GetAttributeValueAsBool(XElement? element, string attributeName)
        {
            var attributeValue = element?.Attribute(attributeName)?.Value;
            if (attributeValue == null) return null;
            return attributeValue.ToLowerInvariant() switch
            {
                "yes" => true,
                "no" => false,
                _ => null
            };
        }

        public static string? GetElementText(XElement? parent, string elementName)
        {
            return parent?.Element(elementName)?.Value?.Trim();
        }

        public static int? GetElementTextAsInt(XElement? parent, string elementName)
        {
            var element = parent?.Element(elementName);
            return GetElementTextAsInt(element);
        }

        public static double? GetElementTextAsDouble(XElement? parent, string elementName)
        {
            var element = parent?.Element(elementName);
            return GetElementTextAsDouble(element);
        }

        public static bool GetElementTextAsBool(XElement? parent, string elementName, bool defaultValue = false)
        {
            var element = parent?.Element(elementName);
            return GetElementTextAsBool(element, defaultValue);
        }

        public static bool HasElement(XElement? parent, string elementName)
        {
            return parent?.Element(elementName) != null;
        }

        public static int GetElementCount(XElement? parent, string elementName)
        {
            return parent?.Elements(elementName).Count() ?? 0;
        }

        public static string? FindOptionalTextElementOptimized(XElement? element, string path)
        {
            if (element == null || string.IsNullOrEmpty(path)) return null;

            if (!path.Contains('/') && !path.Contains('['))
            {
                return element.Element(path)?.Value?.Trim();
            }

            return FindOptionalTextElement(element, path);
        }
    }
}
