import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:xml/xml.dart';

/// Helper class for XML operations specific to MusicXML parsing.
class XmlHelper {
  /// Gets the line number of an XML element, if available.
  ///
  /// Returns -1 if the line number is not available.
  static int getLineNumber(XmlElement? element) {
    if (element == null) return -1;

    // Check for line number in element attributes
    final lineAttribute = element.getAttribute('line');
    if (lineAttribute != null) {
      final lineNum = int.tryParse(lineAttribute);
      if (lineNum != null) return lineNum;
    }

    // Line number not available
    return -1;
  }

  /// Finds optional text content from an XML element using an XPath-like path.
  ///
  /// [element] - The parent XML element to search from.
  /// [path] - A simplified XPath-like string (e.g., 'work/work-title').
  ///
  /// Returns the text content of the found element, or null if not found.
  static String? findOptionalTextElement(XmlElement element, String path) {
    XmlElement? current = element;
    final parts = path.split('/');

    for (final part in parts) {
      if (current == null) return null;

      // Handle attribute selector
      if (part.startsWith('@')) {
        final attrName = part.substring(1);
        return current.getAttribute(attrName);
      }

      // Handle predicates like element[@attr="value"]
      if (part.contains('[') && part.contains(']')) {
        final match = RegExp(r'(.+?)\[(.+?)\]').firstMatch(part);
        if (match != null) {
          final elementName = match.group(1);
          final predicate = match.group(2);

          if (elementName != null && predicate != null) {
            // Handle @attr="value" predicate
            if (predicate.startsWith('@')) {
              final attrMatch = RegExp(r'@(.+?)="(.+?)"').firstMatch(predicate);
              if (attrMatch != null) {
                final attrName = attrMatch.group(1);
                final attrValue = attrMatch.group(2);

                if (attrName != null && attrValue != null) {
                  final elements = current.findElements(elementName);
                  XmlElement? found = null;
                  for (var e in elements) {
                    if (e.getAttribute(attrName) == attrValue) {
                      found = e;
                      break;
                    }
                  }
                  current = found;
                  continue;
                }
              }
            }
          }
        }

        // Regular element name
        current = current.findElements(part).firstOrNull;
      } else {
        // Regular element name
        current = current.findElements(part).firstOrNull;
      }
    }

    return current?.innerText.trim();
  }

  /// Finds and returns a required element.
  ///
  /// Throws [MusicXmlStructureException] if the element is not found.
  static XmlElement getRequiredElement(
    XmlElement parent,
    String name, {
    String? requiredElement,
  }) {
    final elements = parent.findElements(name);
    if (elements.isEmpty) {
      throw MusicXmlStructureException(
        'Required element $name not found',
        requiredElement: requiredElement ?? name,
        line: getLineNumber(parent),
      );
    }
    return elements.first;
  }

  /// Finds and returns an optional element.
  ///
  /// Returns null if the element is not found.
  static XmlElement? findOptionalElement(XmlElement parent, String name) {
    final elements = parent.findElements(name);
    return elements.isNotEmpty ? elements.first : null;
  }

  /// Gets the text content of an element as an integer.
  ///
  /// Returns null if the element is not found or the content is not a valid integer.
  static int? getElementTextAsInt(XmlElement? element) {
    if (element == null) return null;

    final text = element.innerText.trim();
    return int.tryParse(text);
  }

  /// Gets the text content of an element as a double.
  ///
  /// Returns null if the element is not found or the content is not a valid double.
  static double? getElementTextAsDouble(XmlElement? element) {
    if (element == null) return null;

    final text = element.innerText.trim();
    return double.tryParse(text);
  }

  /// Gets the text content of an element as a boolean.
  ///
  /// Returns `true` if the text is "yes" (case-insensitive).
  /// Returns `false` if the text is "no" (case-insensitive).
  /// Returns `defaultValue` (which is `false` if not specified) for any other text,
  /// or if the element is null or its text is empty.
  static bool getElementTextAsBool(XmlElement? element, {bool defaultValue = false}) {
    if (element == null) return defaultValue;

    final text = element.innerText.trim().toLowerCase();
    if (text == 'yes') {
      return true;
    }
    if (text == 'no') {
      return false;
    }
    return defaultValue;
  }
}
