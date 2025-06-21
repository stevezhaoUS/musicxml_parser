import 'package:musicxml_parser/src/models/page_layout.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:xml/xml.dart';

/// Parser for <page-layout> elements.
class PageLayoutParser {
  /// Parses an [XmlElement] into a [PageLayout] object.
  PageLayout parse(XmlElement element) {
    // TODO: Implement parsing logic
    // Placeholder implementation
    final pageHeight = XmlHelper.getElementTextAsDouble(
        element.findElements('page-height').firstOrNull);
    final pageWidth = XmlHelper.getElementTextAsDouble(
        element.findElements('page-width').firstOrNull);
    final margins = <PageMargins>[];
    for (final marginElement in element.findElements('page-margins')) {
      final type = marginElement.getAttribute('type');
      final left = XmlHelper.getElementTextAsDouble(
          marginElement.findElements('left-margin').firstOrNull);
      final right = XmlHelper.getElementTextAsDouble(
          marginElement.findElements('right-margin').firstOrNull);
      final top = XmlHelper.getElementTextAsDouble(
          marginElement.findElements('top-margin').firstOrNull);
      final bottom = XmlHelper.getElementTextAsDouble(
          marginElement.findElements('bottom-margin').firstOrNull);
      margins.add(PageMargins(
        type: type,
        leftMargin: left,
        rightMargin: right,
        topMargin: top,
        bottomMargin: bottom,
      ));
    }
    return PageLayout(
      pageHeight: pageHeight,
      pageWidth: pageWidth,
      pageMargins: margins,
    );
  }
}

/// Parser for <scaling> elements.
class ScalingParser {
  /// Parses an [XmlElement] into a [Scaling] object.
  Scaling parse(XmlElement element) {
    // TODO: Implement parsing logic if needed separately, or integrate into ScoreParser/DefaultsParser
    // Placeholder implementation
    final millimeters = XmlHelper.getElementTextAsDouble(
        element.findElements('millimeters').firstOrNull);
    final tenths = XmlHelper.getElementTextAsDouble(
        element.findElements('tenths').firstOrNull);

    if (millimeters == null || tenths == null) {
      // Or throw an exception, depending on how strict parsing should be
      // For now, returning a default or handling nullability in the Scaling model might be options
      // However, the model expects non-null values.
      throw Exception(
          '<scaling> element must contain <millimeters> and <tenths>');
    }
    return Scaling(millimeters: millimeters, tenths: tenths);
  }
}
