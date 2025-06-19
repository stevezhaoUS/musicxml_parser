import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:xml/xml.dart';

/// Parser for MusicXML note elements.
class NoteParser {
  /// The warning system for collecting non-critical issues.
  final WarningSystem warningSystem;

  /// Creates a new [NoteParser].
  ///
  /// [warningSystem] - Optional warning system. If not provided, a new one will be created.
  NoteParser({WarningSystem? warningSystem})
      : warningSystem = warningSystem ?? WarningSystem();

  /// Parses a note element into a [Note] object.
  ///
  /// [element] - The XML element representing the note.
  /// [parentDivisions] - The divisions value from the parent measure.
  /// [partId] - The ID of the part containing this note.
  /// [measureNumber] - The number of the measure containing this note.
  Note? parse(
    XmlElement element,
    int? parentDivisions,
    String partId,
    String measureNumber,
  ) {
    final line = XmlHelper.getLineNumber(element);

    // Check if it's a rest
    final isRest = element.findElements('rest').isNotEmpty;

    // Parse pitch (if not a rest)
    Pitch? pitch;
    if (!isRest) {
      final pitchElement = element.findElements('pitch').firstOrNull;
      if (pitchElement == null) {
        throw MusicXmlStructureException(
          'Non-rest note is missing pitch element',
          requiredElement: 'pitch',
          parentElement: 'note',
          line: line,
        );
      }
      pitch = _parsePitch(pitchElement, partId, measureNumber);
    }

    // Parse duration
    final durationElement = element.findElements('duration').firstOrNull;
    Duration? duration;
    if (durationElement != null) {
      final durationValue = XmlHelper.getElementTextAsInt(durationElement);
      
      if (durationValue != null && durationValue >= 0) {
        if (parentDivisions == null || parentDivisions <= 0) {
          warningSystem.addWarning(
            'No valid divisions specified for note. Using default value 1.',
            category: 'note_divisions',
            context: {
              'part': partId,
              'measure': measureNumber,
              'line': line,
            },
          );
          parentDivisions = 1;
        }
        
        duration = Duration(
          value: durationValue,
          divisions: parentDivisions,
        );
      } else {
        warningSystem.addWarning(
          'Invalid duration value: $durationValue',
          category: 'note_duration',
          context: {
            'part': partId,
            'measure': measureNumber,
            'line': line,
          },
        );
      }
    } else {
      // Duration is required for most notes
      warningSystem.addWarning(
        'Note without duration',
        category: WarningCategories.duration,
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
      return null;
    }

    // Parse note type
    final typeElement = element.findElements('type').firstOrNull;
    final type = typeElement?.innerText.trim();

    // Parse voice
    final voiceElement = element.findElements('voice').firstOrNull;
    final voice = voiceElement?.innerText.trim();
    final voiceNum = voice != null ? int.tryParse(voice) : null;

    // Create and return the note
    return Note(
      pitch: pitch,
      duration: duration!,
      isRest: isRest,
      type: type,
      voice: voiceNum,
    );
  }

  /// Parses a pitch element into a [Pitch] object.
  Pitch _parsePitch(XmlElement element, String partId, String measureNumber) {
    final line = XmlHelper.getLineNumber(element);

    // Parse step (required)
    final stepElement = element.findElements('step').firstOrNull;
    final step = stepElement?.innerText.trim();

    // Validate step
    if (step == null || !ValidationUtils.validPitchSteps.contains(step)) {
      throw MusicXmlValidationException(
        'Invalid pitch step: $step',
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    // Parse octave (required)
    final octaveElement = element.findElements('octave').firstOrNull;
    final octaveText = octaveElement?.innerText.trim();
    final octave = octaveText != null ? int.tryParse(octaveText) : null;

    // Validate octave
    if (octave == null || octave < ValidationUtils.minOctave || octave > ValidationUtils.maxOctave) {
      throw MusicXmlValidationException(
        'Invalid octave: $octaveText',
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    // Parse alter (optional)
    final alterElement = element.findElements('alter').firstOrNull;
    final alterText = alterElement?.innerText.trim();
    final alter = alterText != null ? int.tryParse(alterText) : null;

    // Validate alter if present
    if (alterText != null &&
        (alter == null || alter < -2 || alter > 2)) {
      throw MusicXmlValidationException(
        'Invalid alter value: $alterText',
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    return Pitch(
      step: step,
      octave: octave,
      alter: alter,
    );
  }
}
