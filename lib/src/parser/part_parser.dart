import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/part.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/parser/measure_parser.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:xml/xml.dart';

/// Parser for MusicXML part elements.
class PartParser {
  /// The parser for measure elements.
  final MeasureParser _measureParser;

  /// The warning system for collecting non-critical issues.
  final WarningSystem warningSystem;

  /// Creates a new [PartParser].
  ///
  /// [measureParser] - Optional measure parser. If not provided, a new one will be created.
  /// [warningSystem] - Optional warning system. If not provided, a new one will be created.
  PartParser({
    MeasureParser? measureParser,
    WarningSystem? warningSystem,
  })  : warningSystem = warningSystem ?? WarningSystem(),
        _measureParser = measureParser ??
            MeasureParser(warningSystem: warningSystem ?? WarningSystem());

  /// Parses a part element into a [Part] object.
  ///
  /// [element] - The XML element representing the part.
  /// [partList] - The part-list element containing part information.
  Part parse(XmlElement element, XmlElement? partList) {
    final line = XmlHelper.getLineNumber(element);

    // Get part ID (required)
    final id = element.getAttribute('id');
    if (id == null || id.isEmpty) {
      throw MusicXmlStructureException(
        'Part element is missing required "id" attribute',
        requiredElement: 'id',
        parentElement: 'part',
        line: line,
      );
    }

    // Get part name from part-list (if available)
    String? name;
    if (partList != null) {
      final scorePartElements = partList.findElements('score-part');
      XmlElement? scorePart;

      for (var element in scorePartElements) {
        if (element.getAttribute('id') == id) {
          scorePart = element;
          break;
        }
      }

      if (scorePart == null) {
        throw MusicXmlValidationException(
          'Part ID $id not found in part-list',
          context: {
            'partId': id,
            'line': line,
          },
        );
      }

      name = XmlHelper.findOptionalTextElement(scorePart, 'part-name');
    }

    final partBuilder = PartBuilder(id, line: line)..setName(name);

    int? activeDivisions;
    KeySignature? activeKeySignature;
    TimeSignature? activeTimeSignature;

    for (final measureElement in element.findElements('measure')) {
      final measure = _measureParser.parse(
        measureElement,
        id,
        inheritedDivisions: activeDivisions,
        inheritedKeySignature: activeKeySignature,
        inheritedTimeSignature: activeTimeSignature,
      );
      partBuilder.addMeasure(measure);

      // Update active attributes for the *next* measure based on what was
      // defined or inherited by the measure just parsed.

      // Divisions: If the current measure defined new divisions, use that.
      // Otherwise, continue with the previously active divisions.
      final attributesInMeasure =
          measureElement.findElements('attributes').firstOrNull;
      if (attributesInMeasure != null) {
        final divisionsElement =
            attributesInMeasure.findElements('divisions').firstOrNull;
        if (divisionsElement != null) {
          final newDivisions = int.tryParse(divisionsElement.innerText.trim());
          if (newDivisions != null && newDivisions > 0) {
            activeDivisions = newDivisions;
          }
        }
      }
      // Key and Time Signature: The measure object itself contains the key/time
      // that applied to it (either newly defined or inherited). So, use that for the next.
      if (measure.keySignature != null) {
        activeKeySignature = measure.keySignature;
      }
      if (measure.timeSignature != null) {
        activeTimeSignature = measure.timeSignature;
      }
    }
    return partBuilder.build();
  }
}
