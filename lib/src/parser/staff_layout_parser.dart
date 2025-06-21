import 'package:musicxml_parser/src/models/staff_layout.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:xml/xml.dart';

/// Parser for <staff-layout> elements.
class StaffLayoutParser {
  /// Parses an [XmlElement] into a [StaffLayout] object.
  StaffLayout parse(XmlElement element) {
    // TODO: Implement parsing logic
    // Placeholder implementation
    final numberStr = element.getAttribute('number');
    final staffNumber = numberStr != null ? int.tryParse(numberStr) ?? 1 : 1;

    return StaffLayout(
      staffNumber: staffNumber,
      staffDistance: XmlHelper.getElementTextAsDouble(element.findElements('staff-distance').firstOrNull),
    );
  }
}
