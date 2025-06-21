import 'package:musicxml_parser/src/models/system_layout.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:xml/xml.dart';

/// Parser for <system-layout> elements.
class SystemLayoutParser {
  /// Parses an [XmlElement] into a [SystemLayout] object.
  SystemLayout parse(XmlElement element) {
    // TODO: Implement parsing logic
    // Placeholder implementation
    SystemMargins? margins;
    final marginsElement = element.findElements('system-margins').firstOrNull;
    if (marginsElement != null) {
      margins = SystemMargins(
        leftMargin: XmlHelper.getElementTextAsDouble(marginsElement.findElements('left-margin').firstOrNull),
        rightMargin: XmlHelper.getElementTextAsDouble(marginsElement.findElements('right-margin').firstOrNull),
      );
    }

    SystemDividers? dividers;
    final dividersElement = element.findElements('system-dividers').firstOrNull;
    if (dividersElement != null) {
      dividers = SystemDividers(
        leftDivider: XmlHelper.getElementTextAsBool(dividersElement.findElements('left-divider').firstOrNull),
        rightDivider: XmlHelper.getElementTextAsBool(dividersElement.findElements('right-divider').firstOrNull),
      );
    }

    return SystemLayout(
      systemMargins: margins,
      systemDistance: XmlHelper.getElementTextAsDouble(element.findElements('system-distance').firstOrNull),
      topSystemDistance: XmlHelper.getElementTextAsDouble(element.findElements('top-system-distance').firstOrNull),
      systemDividers: dividers,
    );
  }
}
