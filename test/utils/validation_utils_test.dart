import 'package:test/test.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';

void main() {
  group('ValidationUtils', () {
    group('validatePitch', () {
      test('accepts valid pitch', () {
        final pitch = Pitch(step: 'C', octave: 4);

        expect(() => ValidationUtils.validatePitch(pitch), returnsNormally);
      });

      test('rejects invalid pitch step', () {
        final pitch = Pitch(step: 'H', octave: 4);

        expect(
          () => ValidationUtils.validatePitch(pitch),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'pitch_step_validation')
              .having((e) => e.message, 'message',
                  contains('Invalid pitch step "H"'))),
        );
      });

      test('rejects octave too low', () {
        final pitch = Pitch(step: 'C', octave: -1);

        expect(
          () => ValidationUtils.validatePitch(pitch),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'pitch_octave_validation')
              .having(
                  (e) => e.message, 'message', contains('out of valid range'))),
        );
      });

      test('rejects octave too high', () {
        final pitch = Pitch(step: 'C', octave: 10);

        expect(
          () => ValidationUtils.validatePitch(pitch),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'pitch_octave_validation')
              .having(
                  (e) => e.message, 'message', contains('out of valid range'))),
        );
      });

      test('accepts valid alteration', () {
        final pitch = Pitch(step: 'C', octave: 4, alter: 1);

        expect(() => ValidationUtils.validatePitch(pitch), returnsNormally);
      });

      test('rejects extreme alteration', () {
        final pitch = Pitch(step: 'C', octave: 4, alter: 3);

        expect(
          () => ValidationUtils.validatePitch(pitch),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'pitch_alter_validation')
              .having((e) => e.message, 'message',
                  contains('out of reasonable range'))),
        );
      });

      test('includes context in validation error', () {
        final pitch = Pitch(step: 'H', octave: 4);
        final context = {'measure': 5, 'part': 'P1'};

        expect(
          () =>
              ValidationUtils.validatePitch(pitch, line: 42, context: context),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.line, 'line', 42)
              .having((e) => e.context, 'context', contains('measure'))),
        );
      });
    });

    group('validateDuration', () {
      test('accepts valid duration', () {
        final duration = Duration(value: 480, divisions: 480);

        expect(
            () => ValidationUtils.validateDuration(duration), returnsNormally);
      });

      test('rejects zero duration value', () {
        final duration = Duration(value: 0, divisions: 480);

        expect(
          () => ValidationUtils.validateDuration(duration),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'duration_positive_validation')
              .having(
                  (e) => e.message, 'message', contains('must be positive'))),
        );
      });

      test('rejects negative duration value', () {
        final duration = Duration(value: -100, divisions: 480);

        expect(
          () => ValidationUtils.validateDuration(duration),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'duration_positive_validation')),
        );
      });

      test('rejects zero divisions', () {
        final duration = Duration(value: 480, divisions: 0);

        expect(
          () => ValidationUtils.validateDuration(duration),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'duration_divisions_validation')
              .having((e) => e.message, 'message',
                  contains('divisions must be positive'))),
        );
      });
    });

    group('validateKeySignature', () {
      test('accepts valid key signature', () {
        final keySignature = KeySignature(fifths: 2, mode: 'major');

        expect(() => ValidationUtils.validateKeySignature(keySignature),
            returnsNormally);
      });

      test('rejects fifths too low', () {
        final keySignature = KeySignature(fifths: -8);

        expect(
          () => ValidationUtils.validateKeySignature(keySignature),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'key_signature_fifths_validation')
              .having(
                  (e) => e.message, 'message', contains('out of valid range'))),
        );
      });

      test('rejects fifths too high', () {
        final keySignature = KeySignature(fifths: 8);

        expect(
          () => ValidationUtils.validateKeySignature(keySignature),
          throwsA(isA<MusicXmlValidationException>().having(
              (e) => e.rule, 'rule', 'key_signature_fifths_validation')),
        );
      });

      test('accepts valid modes', () {
        for (final mode in [
          'major',
          'minor',
          'dorian',
          'phrygian',
          'lydian',
          'mixolydian'
        ]) {
          final keySignature = KeySignature(fifths: 0, mode: mode);
          expect(() => ValidationUtils.validateKeySignature(keySignature),
              returnsNormally);
        }
      });

      test('rejects invalid mode', () {
        final keySignature = KeySignature(fifths: 0, mode: 'invalid');

        expect(
          () => ValidationUtils.validateKeySignature(keySignature),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'key_signature_mode_validation')
              .having((e) => e.message, 'message',
                  contains('Invalid key signature mode'))),
        );
      });

      test('accepts null mode', () {
        final keySignature = KeySignature(fifths: 0);

        expect(() => ValidationUtils.validateKeySignature(keySignature),
            returnsNormally);
      });
    });

    group('validateTimeSignature', () {
      test('accepts valid time signature', () {
        final timeSignature = TimeSignature(beats: 4, beatType: 4);

        expect(() => ValidationUtils.validateTimeSignature(timeSignature),
            returnsNormally);
      });

      test('rejects zero beats', () {
        final timeSignature = TimeSignature(beats: 0, beatType: 4);

        expect(
          () => ValidationUtils.validateTimeSignature(timeSignature),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'time_signature_beats_validation')
              .having((e) => e.message, 'message',
                  contains('beats must be positive'))),
        );
      });

      test('rejects negative beats', () {
        final timeSignature = TimeSignature(beats: -1, beatType: 4);

        expect(
          () => ValidationUtils.validateTimeSignature(timeSignature),
          throwsA(isA<MusicXmlValidationException>().having(
              (e) => e.rule, 'rule', 'time_signature_beats_validation')),
        );
      });

      test('accepts valid beat types (powers of 2)', () {
        for (final beatType in [1, 2, 4, 8, 16, 32]) {
          final timeSignature = TimeSignature(beats: 4, beatType: beatType);
          expect(() => ValidationUtils.validateTimeSignature(timeSignature),
              returnsNormally);
        }
      });

      test('rejects invalid beat types (not powers of 2)', () {
        for (final beatType in [3, 5, 6, 7, 9, 10]) {
          final timeSignature = TimeSignature(beats: 4, beatType: beatType);
          expect(
            () => ValidationUtils.validateTimeSignature(timeSignature),
            throwsA(isA<MusicXmlValidationException>()
                .having((e) => e.rule, 'rule',
                    'time_signature_beat_type_validation')
                .having((e) => e.message, 'message',
                    contains('must be a positive power of 2'))),
          );
        }
      });

      test('rejects zero beat type', () {
        final timeSignature = TimeSignature(beats: 4, beatType: 0);

        expect(
          () => ValidationUtils.validateTimeSignature(timeSignature),
          throwsA(isA<MusicXmlValidationException>().having(
              (e) => e.rule, 'rule', 'time_signature_beat_type_validation')),
        );
      });
    });

    group('validateNote', () {
      test('accepts valid note with pitch', () {
        final pitch = Pitch(step: 'C', octave: 4);
        final duration = Duration(value: 480, divisions: 480);
        final note = Note(
          pitch: pitch,
          duration: duration,
          isRest: false,
          voice: 1,
        );

        expect(() => ValidationUtils.validateNote(note), returnsNormally);
      });

      test('accepts valid rest', () {
        final duration = Duration(value: 480, divisions: 480);
        final note = Note(
          duration: duration,
          isRest: true,
        );

        expect(() => ValidationUtils.validateNote(note), returnsNormally);
      });

      test('rejects rest with pitch', () {
        final pitch = Pitch(step: 'C', octave: 4);
        final duration = Duration(value: 480, divisions: 480);

        expect(
          () => Note.validated(
            pitch: pitch,
            duration: duration,
            isRest: true,
          ),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'rest_no_pitch_validation')
              .having((e) => e.message, 'message',
                  contains('Rest notes should not have pitch'))),
        );
      });

      test('rejects non-rest without pitch', () {
        final duration = Duration(value: 480, divisions: 480);

        expect(
          () => Note.validated(
            duration: duration,
            isRest: false,
          ),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'note_pitch_required_validation')
              .having((e) => e.message, 'message',
                  contains('Non-rest notes must have pitch'))),
        );
      });

      test('rejects zero voice', () {
        final pitch = Pitch(step: 'C', octave: 4);
        final duration = Duration(value: 480, divisions: 480);
        final note = Note(
          pitch: pitch,
          duration: duration,
          isRest: false,
          voice: 0,
        );

        expect(
          () => ValidationUtils.validateNote(note),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'note_voice_validation')
              .having((e) => e.message, 'message',
                  contains('voice must be positive'))),
        );
      });
    });

    group('validateMeasureDuration', () {
      test('accepts correct measure duration', () {
        final duration = Duration(value: 480, divisions: 480);
        final notes = [
          Note(
              duration: duration,
              isRest: false,
              pitch: Pitch(step: 'C', octave: 4)),
          Note(
              duration: duration,
              isRest: false,
              pitch: Pitch(step: 'D', octave: 4)),
          Note(
              duration: duration,
              isRest: false,
              pitch: Pitch(step: 'E', octave: 4)),
          Note(
              duration: duration,
              isRest: false,
              pitch: Pitch(step: 'F', octave: 4)),
        ];
        final timeSignature = TimeSignature(beats: 4, beatType: 4);

        expect(
          () => ValidationUtils.validateMeasureDuration(
              notes, timeSignature, 480),
          returnsNormally,
        );
      });

      test('rejects incorrect measure duration', () {
        final duration = Duration(value: 480, divisions: 480);
        final notes = [
          Note(
              duration: duration,
              isRest: false,
              pitch: Pitch(step: 'C', octave: 4)),
          Note(
              duration: duration,
              isRest: false,
              pitch: Pitch(step: 'D', octave: 4)),
        ];
        final timeSignature = TimeSignature(beats: 4, beatType: 4);

        expect(
          () => ValidationUtils.validateMeasureDuration(
              notes, timeSignature, 480),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.rule, 'rule', 'measure_duration_validation')
              .having(
                  (e) => e.message, 'message', contains('Measure duration'))),
        );
      });

      test('skips validation when time signature is null', () {
        final duration = Duration(value: 480, divisions: 480);
        final notes = [
          Note(
              duration: duration,
              isRest: false,
              pitch: Pitch(step: 'C', octave: 4)),
        ];

        expect(
          () => ValidationUtils.validateMeasureDuration(notes, null, 480),
          returnsNormally,
        );
      });

      test('skips validation when divisions is null', () {
        final duration = Duration(value: 480, divisions: 480);
        final notes = [
          Note(
              duration: duration,
              isRest: false,
              pitch: Pitch(step: 'C', octave: 4)),
        ];
        final timeSignature = TimeSignature(beats: 4, beatType: 4);

        expect(
          () => ValidationUtils.validateMeasureDuration(
              notes, timeSignature, null),
          returnsNormally,
        );
      });
    });
  });
}
