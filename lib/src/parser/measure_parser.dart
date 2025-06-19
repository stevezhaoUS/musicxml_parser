import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/measure.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/parser/attributes_parser.dart';
import 'package:musicxml_parser/src/parser/note_parser.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:xml/xml.dart';

/// Parser for MusicXML measure elements.
class MeasureParser {
  /// The parser for note elements.
  final NoteParser _noteParser;

  /// The parser for attributes elements.
  final AttributesParser _attributesParser;

  /// The warning system for collecting non-critical issues.
  final WarningSystem warningSystem;

  /// Creates a new [MeasureParser].
  ///
  /// [noteParser] - Optional note parser. If not provided, a new one will be created.
  /// [attributesParser] - Optional attributes parser. If not provided, a new one will be created.
  /// [warningSystem] - Optional warning system. If not provided, a new one will be created.
  MeasureParser({
    NoteParser? noteParser,
    AttributesParser? attributesParser,
    WarningSystem? warningSystem,
  })  : warningSystem = warningSystem ?? WarningSystem(),
        _noteParser = noteParser ??
            NoteParser(warningSystem: warningSystem ?? WarningSystem()),
        _attributesParser = attributesParser ?? const AttributesParser();

  /// Parses a measure element into a [Measure] object.
  ///
  /// [element] - The XML element representing the measure.
  /// [partId] - The ID of the part containing this measure.
  /// [inheritedDivisions] - The divisions value inherited from previous measures (if any).
  /// [inheritedKeySignature] - The key signature inherited from previous measures (if any).
  /// [inheritedTimeSignature] - The time signature inherited from previous measures (if any).
  Measure parse(
    XmlElement element,
    String partId, {
    int? inheritedDivisions,
    KeySignature? inheritedKeySignature,
    TimeSignature? inheritedTimeSignature,
  }) {
    final line = XmlHelper.getLineNumber(element);

    // Get measure number (required)
    final number = element.getAttribute('number');
    if (number == null || number.isEmpty) {
      throw MusicXmlValidationException(
        'Measure number is required',
        context: {
          'part': partId,
          'line': line,
        },
      );
    }

    // Validate measure number
    final measureNum = int.tryParse(number);
    if (measureNum == null || measureNum < 1) {
      throw MusicXmlValidationException(
        'Invalid measure number: $number',
        context: {
          'part': partId,
          'measure': number,
          'line': line,
        },
      );
    }

    // Get measure width (optional)
    final widthAttr = element.getAttribute('width');
    final width = widthAttr != null ? double.tryParse(widthAttr) : null;

    // Initialize with inherited values
    int? divisions = inheritedDivisions;
    var keySignature = inheritedKeySignature;
    var timeSignature = inheritedTimeSignature;
    final notes = <Note>[];

    // Process measure content
    for (final child in element.childElements) {
      if (child.name.local == 'attributes') {
        // Parse attributes (divisions, key, time, etc.)
        final attributes = _attributesParser.parse(
          child,
          partId,
          number,
          divisions,
        );

        // Update divisions if specified
        if (attributes['divisions'] != null) {
          divisions = attributes['divisions'];
        }

        // Update key signature if specified
        if (attributes['keySignature'] != null) {
          keySignature = attributes['keySignature'];
        }

        // Update time signature if specified
        if (attributes['timeSignature'] != null) {
          timeSignature = attributes['timeSignature'];
        }
      } else if (child.name.local == 'note') {
        // Parse note
        final note = _noteParser.parse(child, divisions, partId, number);
        if (note != null) {
          notes.add(note);
        }
      }
      // Other elements like backup, forward, direction, etc. can be added here
    }

    // Create and return the measure
    return Measure(
      number: number,
      notes: notes,
      keySignature: keySignature,
      timeSignature: timeSignature,
      width: width,
    );
  }
}
