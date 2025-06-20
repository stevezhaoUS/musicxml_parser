import 'package:musicxml_parser/src/models/page_layout.dart';
import 'package:musicxml_parser/src/models/page_margins.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_parse_exception.dart';
import 'package:xml/xml.dart';

/// Parser for page-layout elements in MusicXML.
/// 
/// Handles parsing of page layout information including page dimensions
/// and page margins from MusicXML documents.
class PageLayoutParser {
  /// Parses a page-layout element into a [PageLayout] object.
  ///
  /// [element] - The XML element representing the page-layout.
  /// [line] - Optional line number for error reporting.
  /// [context] - Optional context information for error reporting.
  static PageLayout parse(
    XmlElement element, {
    int? line,
    Map<String, dynamic>? context,
  }) {
    try {
      // Parse page dimensions
      final pageHeightElement = element.findElements('page-height').singleOrNull;
      final pageWidthElement = element.findElements('page-width').singleOrNull;

      double? pageHeight;
      double? pageWidth;

      if (pageHeightElement != null) {
        final heightText = pageHeightElement.innerText.trim();
        pageHeight = double.tryParse(heightText);
        if (pageHeight == null) {
          throw MusicXmlParseException(
            'Invalid page height value: $heightText',
            element: 'page-height',
            line: line,
            context: {'value': heightText, ...?context},
          );
        }
      }

      if (pageWidthElement != null) {
        final widthText = pageWidthElement.innerText.trim();
        pageWidth = double.tryParse(widthText);
        if (pageWidth == null) {
          throw MusicXmlParseException(
            'Invalid page width value: $widthText',
            element: 'page-width',
            line: line,
            context: {'value': widthText, ...?context},
          );
        }
      }

      // Parse page margins
      final pageMargins = <PageMargins>[];
      final marginElements = element.findElements('page-margins');

      for (final marginElement in marginElements) {
        final margins = _parsePageMargins(marginElement, line: line, context: context);
        pageMargins.add(margins);
      }

      return PageLayout.validated(
        pageHeight: pageHeight,
        pageWidth: pageWidth,
        pageMargins: pageMargins,
        line: line,
        context: context,
      );
    } catch (e) {
      if (e is MusicXmlParseException) {
        rethrow;
      }
      throw MusicXmlParseException(
        'Failed to parse page-layout element: $e',
        element: 'page-layout',
        line: line,
        context: context,
      );
    }
  }

  /// Parses a page-margins element into a [PageMargins] object.
  static PageMargins _parsePageMargins(
    XmlElement element, {
    int? line,
    Map<String, dynamic>? context,
  }) {
    try {
      // Get the type attribute (defaults to "both" if not specified)
      final type = element.getAttribute('type') ?? 'both';

      // Parse margin values
      final leftMarginElement = element.findElements('left-margin').singleOrNull;
      final rightMarginElement = element.findElements('right-margin').singleOrNull;
      final topMarginElement = element.findElements('top-margin').singleOrNull;
      final bottomMarginElement = element.findElements('bottom-margin').singleOrNull;

      double leftMargin = 0.0;
      double rightMargin = 0.0;
      double topMargin = 0.0;
      double bottomMargin = 0.0;

      if (leftMarginElement != null) {
        final leftText = leftMarginElement.innerText.trim();
        leftMargin = double.tryParse(leftText) ?? 0.0;
        if (leftMargin < 0) {
          throw MusicXmlParseException(
            'Left margin cannot be negative: $leftText',
            element: 'left-margin',
            line: line,
            context: {'value': leftText, ...?context},
          );
        }
      }

      if (rightMarginElement != null) {
        final rightText = rightMarginElement.innerText.trim();
        rightMargin = double.tryParse(rightText) ?? 0.0;
        if (rightMargin < 0) {
          throw MusicXmlParseException(
            'Right margin cannot be negative: $rightText',
            element: 'right-margin',
            line: line,
            context: {'value': rightText, ...?context},
          );
        }
      }

      if (topMarginElement != null) {
        final topText = topMarginElement.innerText.trim();
        topMargin = double.tryParse(topText) ?? 0.0;
        if (topMargin < 0) {
          throw MusicXmlParseException(
            'Top margin cannot be negative: $topText',
            element: 'top-margin',
            line: line,
            context: {'value': topText, ...?context},
          );
        }
      }

      if (bottomMarginElement != null) {
        final bottomText = bottomMarginElement.innerText.trim();
        bottomMargin = double.tryParse(bottomText) ?? 0.0;
        if (bottomMargin < 0) {
          throw MusicXmlParseException(
            'Bottom margin cannot be negative: $bottomText',
            element: 'bottom-margin',
            line: line,
            context: {'value': bottomText, ...?context},
          );
        }
      }

      return PageMargins.validated(
        type: type,
        leftMargin: leftMargin,
        rightMargin: rightMargin,
        topMargin: topMargin,
        bottomMargin: bottomMargin,
        line: line,
        context: context,
      );
    } catch (e) {
      if (e is MusicXmlParseException) {
        rethrow;
      }
      throw MusicXmlParseException(
        'Failed to parse page-margins element: $e',
        element: 'page-margins',
        line: line,
        context: context,
      );
    }
  }
}