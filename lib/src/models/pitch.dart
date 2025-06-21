import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';
import 'package:xml/xml.dart';

/// Represents a musical pitch, including its step, octave, and alteration.
///
/// A pitch is defined by a step (A-G), an octave (0-9), and an optional
/// alteration (e.g., sharp, flat). This class ensures that pitch values
/// conform to standard musical notation.
///
/// Objects of this class are immutable.
@immutable
class Pitch {
  /// The musical step of the pitch, represented as a capital letter (C, D, E, F, G, A, B).
  final String step;

  /// The octave number (0-9) in which the pitch resides.
  final int octave;

  /// The chromatic alteration of the pitch.
  ///
  /// Positive values represent sharps (e.g., 1 for a single sharp),
  /// negative values represent flats (e.g., -1 for a single flat),
  /// and 0 or null represents no alteration. Typically ranges from -2 to 2.
  final int? alter;

  /// Creates a new [Pitch] instance.
  ///
  /// The constructor itself does basic assertions if any, but robust validation
  /// (e.g., ensuring step is a valid letter, octave is in range) is typically
  /// handled by factory constructors like [Pitch.fromXmlElement] or validation utilities.
  const Pitch({
    required this.step,
    required this.octave,
    this.alter,
  });

  /// Creates a new [Pitch] instance from an MusicXML `<pitch>` [element].
  ///
  /// This factory parses the required `<step>` and `<octave>` elements,
  /// and the optional `<alter>` element. It performs validation against
  /// MusicXML rules (e.g., valid pitch steps, octave range, alter range).
  ///
  /// Throws [MusicXmlStructureException] if required XML elements are missing.
  /// Throws [MusicXmlValidationException] if the parsed values are invalid
  /// according to MusicXML specifications.
  ///
  /// Parameters:
  ///   [element]: The XML element representing the `<pitch>`.
  ///   [partId]: The ID of the part, used for context in error messages.
  ///   [measureNumber]: The number of the measure, used for context in error messages.
  factory Pitch.fromXmlElement(
    XmlElement element,
    String partId,
    String measureNumber,
  ) {
    final line = XmlHelper.getLineNumber(element);

    final stepElement = element.findElements('step').firstOrNull;
    if (stepElement == null) {
      throw MusicXmlStructureException(
        'Required <step> element not found in <pitch>',
        parentElement: 'pitch',
        line: line,
        context: {'part': partId, 'measure': measureNumber},
      );
    }
    final step = stepElement.innerText.trim();

    final octaveElement = element.findElements('octave').firstOrNull;
    if (octaveElement == null) {
      throw MusicXmlStructureException(
        'Required <octave> element not found in <pitch>',
        parentElement: 'pitch',
        line: line,
        context: {'part': partId, 'measure': measureNumber},
      );
    }
    final octaveText = octaveElement.innerText.trim();
    final octave = int.tryParse(octaveText);

    final alterElement = element.findElements('alter').firstOrNull;
    final alterText = alterElement?.innerText.trim();
    final alter = alterText != null ? int.tryParse(alterText) : null;

    // Perform validation after extracting values
    if (!ValidationUtils.validPitchSteps.contains(step)) {
      throw MusicXmlValidationException(
        'Invalid pitch step: "$step". Must be one of ${ValidationUtils.validPitchSteps.join(", ")}.',
        rule: 'pitch_step_invalid',
        line: line,
        context: {'part': partId, 'measure': measureNumber, 'parsedStep': step},
      );
    }

    if (octave == null ||
        octave < ValidationUtils.minOctave ||
        octave > ValidationUtils.maxOctave) {
      throw MusicXmlValidationException(
        'Invalid octave: "$octaveText". Must be an integer between ${ValidationUtils.minOctave} and ${ValidationUtils.maxOctave}.',
        rule: 'pitch_octave_invalid',
        line: line,
        context: {
          'part': partId,
          'measure': measureNumber,
          'parsedOctave': octaveText
        },
      );
    }

    if (alterText != null && (alter == null || alter < -2 || alter > 2)) {
      throw MusicXmlValidationException(
        'Invalid alter value: "$alterText". If present, must be an integer between -2 and 2.',
        rule: 'pitch_alter_invalid',
        line: line,
        context: {
          'part': partId,
          'measure': measureNumber,
          'parsedAlter': alterText
        },
      );
    }

    return Pitch(step: step, octave: octave, alter: alter);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pitch &&
          runtimeType == other.runtimeType &&
          step == other.step &&
          octave == other.octave &&
          alter == other.alter;

  @override
  int get hashCode => step.hashCode ^ octave.hashCode ^ (alter?.hashCode ?? 0);

  @override
  String toString() => 'Pitch{step: $step, octave: $octave, alter: $alter}';
}
