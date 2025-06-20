import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart'; // Added for backup/forward
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/beam.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/measure.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/parser/attributes_parser.dart';
import 'package:musicxml_parser/src/parser/beam_parser.dart';
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
    final implicit = element.getAttribute('implicit');
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
    if (measureNum == null || measureNum < 0) {
      throw MusicXmlValidationException(
        'Invalid measure number: $number',
        context: {
          'part': partId,
          'measure': number,
          'line': line,
        },
      );
    }

    // Check for measure "0" - only valid for pickup measures with implicit="yes"
    final isPickup = (number == '0' && implicit == 'yes');
    if (measureNum == 0 && !isPickup) {
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
    final beams = <Beam>[]; // beams 列表

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
        final note = _noteParser.parse(child, divisions, partId, number);
        if (note != null) {
          final noteIndex = notes.length;
          notes.add(note);

          // 调用 BeamParser 解析 beams
          final noteBeams = BeamParser.parse(child, noteIndex, number);
          beams.addAll(noteBeams);
        }
      } else if (child.name.local == 'backup') {
        final durationElement = child.findElements('duration').firstOrNull;
        if (durationElement == null) {
          throw MusicXmlStructureException(
            "Backup element missing required <duration> child.",
            parentElement: 'backup',
            line: XmlHelper.getLineNumber(child),
            context: {'part': partId, 'measure': number},
          );
        }
        final int? duration = XmlHelper.getElementTextAsInt(durationElement);
        if (duration == null || duration < 0) {
          throw MusicXmlStructureException(
            "Invalid or missing duration value for <backup>.",
            parentElement: 'backup',
            line: XmlHelper.getLineNumber(durationElement),
            context: {'part': partId, 'measure': number, 'parsedDuration': duration},
          );
        }
        warningSystem.addWarning(
          "Encountered <backup> with duration $duration. Full timeline impact not yet implemented.",
          category: 'partial_processing',
          context: {
            'element': 'backup',
            'part': partId,
            'measure': number,
            'duration': duration,
            'line': XmlHelper.getLineNumber(child)
          },
        );
      } else if (child.name.local == 'forward') {
        final durationElement = child.findElements('duration').firstOrNull;
        if (durationElement == null) {
          throw MusicXmlStructureException(
            "Forward element missing required <duration> child.",
            parentElement: 'forward',
            line: XmlHelper.getLineNumber(child),
            context: {'part': partId, 'measure': number},
          );
        }
        final int? duration = XmlHelper.getElementTextAsInt(durationElement);
        if (duration == null || duration < 0) {
          throw MusicXmlStructureException(
            "Invalid or missing duration value for <forward>.",
            parentElement: 'forward',
            line: XmlHelper.getLineNumber(durationElement),
            context: {'part': partId, 'measure': number, 'parsedDuration': duration},
          );
        }
        warningSystem.addWarning(
          "Encountered <forward> with duration $duration. Full timeline impact not yet implemented.",
          category: 'partial_processing',
          context: {
            'element': 'forward',
            'part': partId,
            'measure': number,
            'duration': duration,
            'line': XmlHelper.getLineNumber(child)
          },
        );
      }
      // Other elements like direction, etc. can be added here
    }

    // 合并 beams 为连续的 beam 组
    final mergedBeams = BeamParser.mergeBeams(beams, number);

    // 创建并返回 Measure
    return Measure(
      number: number,
      notes: notes,
      keySignature: keySignature,
      timeSignature: timeSignature,
      width: width,
      beams: mergedBeams,
      isPickup: isPickup,
    );
  }
}
