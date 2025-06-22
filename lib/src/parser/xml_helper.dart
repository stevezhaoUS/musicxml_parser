import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:xml/xml.dart';

/// Utility class providing helper methods for parsing MusicXML documents.
///
/// This class includes functions for common XML operations such as retrieving
/// element line numbers, finding child elements, and converting element text
/// to various data types, tailored for the needs of MusicXML parsing.
class XmlHelper {
  /// Gets the line number of an XML [element], if available from its attributes.
  ///
  /// MusicXML elements do not standardly include line numbers. This method
  /// checks for a non-standard 'line' attribute that might be added by
  /// pre-processing tools or for debugging.
  ///
  /// Returns the line number if found, otherwise -1.
  static int getLineNumber(XmlElement? element) {
    if (element == null) return -1;

    final lineAttribute = element.getAttribute('line');
    if (lineAttribute != null) {
      final lineNum = int.tryParse(lineAttribute);
      if (lineNum != null) return lineNum;
    }
    return -1;
  }

  /// Finds the text content of an optional child element specified by a simple [path].
  ///
  /// The [path] is a '/' separated string representing a sequence of child elements.
  /// It also supports selecting an attribute using '@attributeName' as the last segment,
  /// or filtering by an attribute value using 'elementName[@attribute="value"]'.
  ///
  /// Example paths:
  /// - 'work/work-title' (finds `<work-title>` inside `<work>`)
  /// - 'identification/creator[@type="composer"]' (finds `<creator type="composer">` inside `<identification>`)
  /// - 'attributes/@version' (gets the 'version' attribute of the `<attributes>` element)
  ///
  /// Returns the trimmed text content of the found element or attribute, or `null` if not found.
  static String? findOptionalTextElement(XmlElement element, String path) {
    XmlElement? currentContextNode = element;
    final pathSegments = path.split('/');

    for (int i = 0; i < pathSegments.length; i++) {
      final segment = pathSegments[i];
      if (currentContextNode == null) return null;

      if (segment.startsWith('@')) {
        // Attribute selection should be the last segment
        if (i == pathSegments.length - 1) {
          final attributeName = segment.substring(1);
          return currentContextNode.getAttribute(attributeName);
        } else {
          // Attribute selection in the middle of a path is not supported by this simplified helper
          return null;
        }
      } else {
        // Element selection with optional predicate
        currentContextNode =
            _findElementFromSegment(currentContextNode, segment);
      }
    }

    return currentContextNode?.innerText.trim();
  }

  /// Internal helper to find a child element based on a [segment] name, handling predicates.
  ///
  /// A [segment] can be a simple element name (e.g., "note") or an element name
  /// with an attribute predicate (e.g., 'creator[@type="composer"]').
  ///
  /// Returns the first matching [XmlElement], or `null` if not found.
  static XmlElement? _findElementFromSegment(
      XmlElement parent, String segment) {
    final predicateMatch = RegExp(r'(.+?)\[(.+?)\]').firstMatch(segment);

    if (predicateMatch != null) {
      final elementName = predicateMatch.group(1);
      final predicate = predicateMatch.group(2);

      if (elementName == null || predicate == null) {
        // Malformed segment (e.g., "name[]" or "[]value"), treat as simple element name
        return parent.findElements(segment).firstOrNull;
      }

      // Handle @attribute="value" predicate
      final attributePredicateMatch =
          RegExp(r'@(.+?)="(.+?)"').firstMatch(predicate);
      if (attributePredicateMatch != null) {
        final attributeName = attributePredicateMatch.group(1);
        final attributeValue = attributePredicateMatch.group(2);

        if (attributeName != null && attributeValue != null) {
          try {
            return parent.findElements(elementName).firstWhere(
                  (el) => el.getAttribute(attributeName) == attributeValue,
                );
          } catch (e) {
            // firstWhere throws StateError if no element is found
            return null;
          }
        }
      }
      // Fallback for unhandled or malformed predicate: find first element by name if any
      return parent.findElements(elementName).firstOrNull;
    } else {
      // Simple element name, no predicate
      return parent.findElements(segment).firstOrNull;
    }
  }

  /// Finds and returns a required child [XmlElement] with the given [name].
  ///
  /// Throws a [MusicXmlStructureException] if the element is not found.
  /// The [requiredElement] parameter can be used to specify a more descriptive
  /// name in the exception message if [name] is too generic.
  static XmlElement getRequiredElement(
    XmlElement parent,
    String name, {
    String? requiredElement,
  }) {
    final elements = parent.findElements(name);
    if (elements.isEmpty) {
      throw MusicXmlStructureException(
        'Required element <${requiredElement ?? name}> not found as a child of <${parent.name.local}>.',
        requiredElement: requiredElement ?? name,
        parentElement: parent.name.local,
        line: getLineNumber(parent),
      );
    }
    return elements.first;
  }

  /// Finds and returns an optional child [XmlElement] with the given [name].
  ///
  /// Returns `null` if the element is not found.
  static XmlElement? findOptionalElement(XmlElement parent, String name) {
    final elements = parent.findElements(name);
    return elements.isNotEmpty ? elements.first : null;
  }

  /// Gets the trimmed text content of an [element] and parses it as an integer.
  ///
  /// Returns the integer value, or `null` if the [element] is `null`,
  /// its text is empty, or not a valid integer.
  static int? getElementTextAsInt(XmlElement? element) {
    if (element == null) return null;
    final text = element.innerText.trim();
    return int.tryParse(text);
  }

  /// Gets the trimmed text content of an [element] and parses it as a double.
  ///
  /// Returns the double value, or `null` if the [element] is `null`,
  /// its text is empty, or not a valid double.
  static double? getElementTextAsDouble(XmlElement? element) {
    if (element == null) return null;
    final text = element.innerText.trim();
    return double.tryParse(text);
  }

  /// Gets the trimmed text content of an [element] and interprets it as a boolean.
  ///
  /// Recognizes "yes" (case-insensitive) as `true` and "no" (case-insensitive)
  /// as `false`. For any other text, or if the element is `null` or its text is empty,
  /// returns the [defaultValue] (which is `false` if not specified).
  static bool getElementTextAsBool(XmlElement? element,
      {bool defaultValue = false}) {
    if (element == null) return defaultValue;
    final text = element.innerText.trim().toLowerCase();
    if (text == 'yes') return true;
    if (text == 'no') return false;
    return defaultValue;
  }

  /// Gets the value of an attribute by [attributeName] from an [element].
  ///
  /// Returns the attribute value as a `String?`, or `null` if the element is `null`
  /// or the attribute does not exist.
  static String? getAttributeValue(XmlElement? element, String attributeName) {
    if (element == null) return null;
    return element.getAttribute(attributeName);
  }

  /// Gets the value of an attribute by [attributeName] from an [element] and parses it as a double.
  ///
  /// Returns the attribute value as a `double?`, or `null` if the element is `null`,
  /// the attribute does not exist, or its value is not a valid double.
  static double? getAttributeValueAsDouble(
      XmlElement? element, String attributeName) {
    if (element == null) return null;
    final attributeValue = element.getAttribute(attributeName);
    if (attributeValue == null) return null;
    return double.tryParse(attributeValue);
  }

  /// Gets the value of an attribute by [attributeName] from an [element] and parses it as an integer.
  ///
  /// Returns the attribute value as an `int?`, or `null` if the element is `null`,
  /// the attribute does not exist, or its value is not a valid integer.
  static int? getAttributeValueAsInt(
      XmlElement? element, String attributeName) {
    if (element == null) return null;
    final attributeValue = element.getAttribute(attributeName);
    if (attributeValue == null) return null;
    return int.tryParse(attributeValue);
  }
}
