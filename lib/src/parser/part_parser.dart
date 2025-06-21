import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/measure.dart';
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

    // Parse measures
    final measures = <Measure>[];
    int? currentDivisions;
    KeySignature? currentKeySignature;
    TimeSignature? currentTimeSignature;

    for (final measureElement in element.findElements('measure')) {
      final measure = _measureParser.parse(
        measureElement,
        id,
        inheritedDivisions: currentDivisions,
        inheritedKeySignature: currentKeySignature,
        inheritedTimeSignature: currentTimeSignature,
      );

      // Carry forward attributes to the next measure
      if (measure.keySignature != null) {
        currentKeySignature = measure.keySignature;
      }
      if (measure.timeSignature != null) {
        currentTimeSignature = measure.timeSignature;
      }

      measures.add(measure);
    }

    // Use PartBuilder
    final partBuilder = PartBuilder(id, line: line)..setName(name);

    // These variables will hold the *active* attributes to be inherited by subsequent measures.
    int? activeDivisions = currentDivisions; // Initialize with potentially inherited divisions from score defaults or previous part context
    KeySignature? activeKeySignature = currentKeySignature; // Initialize similarly
    TimeSignature? activeTimeSignature = currentTimeSignature; // Initialize similarly

    for (final measureElement in element.findElements('measure')) {
      final measure = _measureParser.parse(
        measureElement,
        id, // partId for context
        inheritedDivisions: activeDivisions,
        inheritedKeySignature: activeKeySignature,
        inheritedTimeSignature: activeTimeSignature,
      );

      partBuilder.addMeasure(measure);

      // Update active attributes for the next measure based on what was
      // defined *within* the measure just parsed.
      final attributesInMeasure = measureElement.findElements('attributes').firstOrNull;
      if (attributesInMeasure != null) {
        final divisionsElement = attributesInMeasure.findElements('divisions').firstOrNull;
        if (divisionsElement != null) {
          final newDivisions = int.tryParse(divisionsElement.innerText.trim());
          if (newDivisions != null && newDivisions > 0) {
            activeDivisions = newDivisions;
          }
        }
        // The measure object itself now holds the key/time signature that applies to it.
        // So, if the parsed measure has a key/time signature, that's the new active one.
        // If it's null, the previously active one (from a prior measure or defaults) continues.
        if (measure.keySignature != null) {
          activeKeySignature = measure.keySignature;
        }
        if (measure.timeSignature != null) {
          activeTimeSignature = measure.timeSignature;
        }
      }
    }
    return partBuilder.build();
  }
}
