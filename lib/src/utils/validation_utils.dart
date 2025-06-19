import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';

/// Utility class containing validation rules for MusicXML elements.
///
/// This class provides static methods for validating various musical elements
/// to ensure they conform to musical theory and MusicXML specifications.
class ValidationUtils {
  /// Valid pitch steps in musical notation.
  static const validPitchSteps = {'C', 'D', 'E', 'F', 'G', 'A', 'B'};

  /// Minimum valid octave number.
  static const minOctave = 0;

  /// Maximum valid octave number.
  static const maxOctave = 9;

  /// Minimum valid key signature fifths value.
  static const minFifths = -7;

  /// Maximum valid key signature fifths value.
  static const maxFifths = 7;

  /// Valid key signature modes.
  static const validModes = {
    'major',
    'minor',
    'dorian',
    'phrygian',
    'lydian',
    'mixolydian',
    'aeolian',
    'ionian',
    'locrian'
  };

  /// Validates a pitch object.
  ///
  /// Checks that the pitch step is valid (C, D, E, F, G, A, B) and
  /// the octave is within the valid range (0-9).
  ///
  /// Throws [MusicXmlValidationException] if validation fails.
  static void validatePitch(Pitch pitch,
      {int? line, Map<String, dynamic>? context}) {
    // Validate step
    if (!validPitchSteps.contains(pitch.step)) {
      throw MusicXmlValidationException(
        'Invalid pitch step "${pitch.step}". Expected one of: ${validPitchSteps.join(', ')}',
        rule: 'pitch_step_validation',
        line: line,
        context: {
          'step': pitch.step,
          'octave': pitch.octave,
          'alter': pitch.alter,
          ...?context,
        },
      );
    }

    // Validate octave
    if (pitch.octave < minOctave || pitch.octave > maxOctave) {
      throw MusicXmlValidationException(
        'Pitch octave ${pitch.octave} is out of valid range ($minOctave-$maxOctave)',
        rule: 'pitch_octave_validation',
        line: line,
        context: {
          'step': pitch.step,
          'octave': pitch.octave,
          'alter': pitch.alter,
          ...?context,
        },
      );
    }

    // Validate alter (alteration should be reasonable)
    if (pitch.alter != null && (pitch.alter! < -2 || pitch.alter! > 2)) {
      throw MusicXmlValidationException(
        'Pitch alteration ${pitch.alter} is out of reasonable range (-2 to +2)',
        rule: 'pitch_alter_validation',
        line: line,
        context: {
          'step': pitch.step,
          'octave': pitch.octave,
          'alter': pitch.alter,
          ...?context,
        },
      );
    }
  }

  /// Validates a duration object.
  ///
  /// Checks that the duration value is positive.
  ///
  /// Throws [MusicXmlValidationException] if validation fails.
  static void validateDuration(Duration duration,
      {int? line, Map<String, dynamic>? context}) {
    if (duration.value <= 0) {
      throw MusicXmlValidationException(
        'Duration value must be positive, got ${duration.value}',
        rule: 'duration_positive_validation',
        line: line,
        context: {
          'value': duration.value,
          'divisions': duration.divisions,
          ...?context,
        },
      );
    }

    if (duration.divisions <= 0) {
      throw MusicXmlValidationException(
        'Duration divisions must be positive, got ${duration.divisions}',
        rule: 'duration_divisions_validation',
        line: line,
        context: {
          'value': duration.value,
          'divisions': duration.divisions,
          ...?context,
        },
      );
    }
  }

  /// Validates a key signature object.
  ///
  /// Checks that the fifths value is within the valid range (-7 to +7)
  /// and the mode is valid if specified.
  ///
  /// Throws [MusicXmlValidationException] if validation fails.
  static void validateKeySignature(KeySignature keySignature,
      {int? line, Map<String, dynamic>? context}) {
    // Validate fifths
    if (keySignature.fifths < minFifths || keySignature.fifths > maxFifths) {
      throw MusicXmlValidationException(
        'Key signature fifths ${keySignature.fifths} is out of valid range ($minFifths to $maxFifths)',
        rule: 'key_signature_fifths_validation',
        line: line,
        context: {
          'fifths': keySignature.fifths,
          'mode': keySignature.mode,
          ...?context,
        },
      );
    }

    // Validate mode if specified
    if (keySignature.mode != null &&
        !validModes.contains(keySignature.mode!.toLowerCase())) {
      throw MusicXmlValidationException(
        'Invalid key signature mode "${keySignature.mode}". Expected one of: ${validModes.join(', ')}',
        rule: 'key_signature_mode_validation',
        line: line,
        context: {
          'fifths': keySignature.fifths,
          'mode': keySignature.mode,
          ...?context,
        },
      );
    }
  }

  /// Validates a time signature object.
  ///
  /// Checks that beats is positive and beat type is a power of 2.
  ///
  /// Throws [MusicXmlValidationException] if validation fails.
  static void validateTimeSignature(TimeSignature timeSignature,
      {int? line, Map<String, dynamic>? context}) {
    // Validate beats
    if (timeSignature.beats <= 0) {
      throw MusicXmlValidationException(
        'Time signature beats must be positive, got ${timeSignature.beats}',
        rule: 'time_signature_beats_validation',
        line: line,
        context: {
          'beats': timeSignature.beats,
          'beatType': timeSignature.beatType,
          ...?context,
        },
      );
    }

    // Validate beat type (should be a power of 2)
    if (timeSignature.beatType <= 0 || !_isPowerOfTwo(timeSignature.beatType)) {
      throw MusicXmlValidationException(
        'Time signature beat type must be a positive power of 2, got ${timeSignature.beatType}',
        rule: 'time_signature_beat_type_validation',
        line: line,
        context: {
          'beats': timeSignature.beats,
          'beatType': timeSignature.beatType,
          ...?context,
        },
      );
    }
  }

  /// Validates a note object.
  ///
  /// Performs comprehensive validation including pitch validation for non-rest notes
  /// and duration validation.
  ///
  /// Throws [MusicXmlValidationException] if validation fails.
  static void validateNote(Note note,
      {int? line, Map<String, dynamic>? context}) {
    // Validate duration
    validateDuration(note.duration, line: line, context: context);

    // Validate pitch if not a rest
    if (!note.isRest && note.pitch != null) {
      validatePitch(note.pitch!, line: line, context: context);
    }

    // Validate voice (should be positive if specified)
    if (note.voice != null && note.voice! <= 0) {
      throw MusicXmlValidationException(
        'Note voice must be positive, got ${note.voice}',
        rule: 'note_voice_validation',
        line: line,
        context: {
          'voice': note.voice,
          'isRest': note.isRest,
          ...?context,
        },
      );
    }

    // Validate that rests don't have pitches
    if (note.isRest && note.pitch != null) {
      throw MusicXmlValidationException(
        'Rest notes should not have pitch information',
        rule: 'rest_no_pitch_validation',
        line: line,
        context: {
          'isRest': note.isRest,
          'hasPitch': note.pitch != null,
          ...?context,
        },
      );
    }

    // Validate that non-rest notes have pitches (unless it's a special case)
    if (!note.isRest && note.pitch == null) {
      throw MusicXmlValidationException(
        'Non-rest notes must have pitch information',
        rule: 'note_pitch_required_validation',
        line: line,
        context: {
          'isRest': note.isRest,
          'hasPitch': note.pitch != null,
          ...?context,
        },
      );
    }
  }

  /// Validates that a list of notes has consistent voice assignments within a measure.
  ///
  /// Throws [MusicXmlValidationException] if validation fails.
  static void validateVoiceConsistency(List<Note> notes,
      {int? line, Map<String, dynamic>? context}) {
    final voiceNotes = <int, List<Note>>{};

    // Group notes by voice
    for (final note in notes) {
      final voice = note.voice ?? 1; // Default voice is 1
      voiceNotes.putIfAbsent(voice, () => []).add(note);
    }

    // Check for overlapping notes in the same voice
    for (final voice in voiceNotes.keys) {
      final voiceNoteList = voiceNotes[voice]!;

      // TODO: Implement proper voice overlap validation
      // This would require tracking note start times and durations
      // For now, we just verify that the voice grouping was successful
      if (voiceNoteList.isEmpty) {
        throw MusicXmlValidationException(
          'Voice $voice has no notes despite being registered',
          rule: 'voice_consistency_validation',
          line: line,
          context: context,
        );
      }
    }
  }

  /// Validates that measure duration matches the time signature.
  ///
  /// This is a simplified validation - a complete implementation would need
  /// to handle complex rhythmic patterns, grace notes, etc.
  ///
  /// Throws [MusicXmlValidationException] if validation fails.
  static void validateMeasureDuration(
    List<Note> notes,
    TimeSignature? timeSignature,
    int? divisions, {
    int? line,
    Map<String, dynamic>? context,
  }) {
    if (timeSignature == null || divisions == null) {
      return; // Can't validate without time signature and divisions
    }

    // Calculate expected measure duration in divisions
    final expectedDuration =
        (timeSignature.beats * divisions * 4) ~/ timeSignature.beatType;

    // Calculate actual duration from notes
    var actualDuration = 0;
    for (final note in notes) {
      actualDuration += note.duration.value;
    }

    if (actualDuration != expectedDuration) {
      throw MusicXmlValidationException(
        'Measure duration ($actualDuration) does not match time signature expectation ($expectedDuration)',
        rule: 'measure_duration_validation',
        line: line,
        context: {
          'actualDuration': actualDuration,
          'expectedDuration': expectedDuration,
          'timeSignature': '${timeSignature.beats}/${timeSignature.beatType}',
          'divisions': divisions,
          'noteCount': notes.length,
          ...?context,
        },
      );
    }
  }

  /// Helper method to check if a number is a power of 2.
  static bool _isPowerOfTwo(int n) {
    return n > 0 && (n & (n - 1)) == 0;
  }
}
