import 'package:musicxml_parser/musicxml_parser.dart';
import 'package:test/test.dart';

void main() {
  group('Note Model', () {
    // Pitch and Duration instances for testing
    const pitchC4 = Pitch(step: 'C', octave: 4);
    const pitchG4 = Pitch(step: 'G', octave: 4); // For variety
    const durationQuarter = Duration(value: 480, divisions: 480);
    const durationHalf = Duration(value: 960, divisions: 480); // For variety

    group('constructor and basic properties', () {
      test('creates a note with dots', () {
        final note = Note(
          pitch: pitchC4,
          duration: durationQuarter,
          isRest: false,
          dots: 1,
        );
        expect(note.dots, equals(1));
      });

      test('creates a note with null dots', () {
        final note = Note(
          pitch: pitchC4,
          duration: durationQuarter,
          isRest: false,
          dots: null, // Explicitly null
        );
        expect(note.dots, isNull);
      });

      test('creates a note without specifying dots (defaults to null)', () {
        final note = Note(
          pitch: pitchC4,
          duration: durationQuarter,
          isRest: false,
        );
        expect(note.dots, isNull);
      });

      test('creates a rest with dots', () {
        final rest = Note(
          duration: durationQuarter,
          isRest: true,
          dots: 1,
        );
        expect(rest.dots, equals(1));
        expect(rest.isRest, isTrue);
        expect(rest.pitch, isNull);
      });
    });

    group('equality and hashCode', () {
      test(
          'notes with same properties (including dots) are equal and have same hashCode',
          () {
        final note1 = Note(
            pitch: pitchC4, duration: durationQuarter, isRest: false, dots: 1);
        final note2 = Note(
            pitch: pitchC4, duration: durationQuarter, isRest: false, dots: 1);
        expect(note1 == note2, isTrue);
        expect(note1.hashCode == note2.hashCode, isTrue);
      });

      test('notes with different dots are not equal', () {
        final note1 = Note(
            pitch: pitchC4, duration: durationQuarter, isRest: false, dots: 1);
        final note2 = Note(
            pitch: pitchC4, duration: durationQuarter, isRest: false, dots: 2);
        expect(note1 == note2, isFalse);
      });

      test('notes with null dots vs non-null dots are not equal', () {
        final note1 = Note(
            pitch: pitchC4,
            duration: durationQuarter,
            isRest: false,
            dots: null);
        final note2 = Note(
            pitch: pitchC4, duration: durationQuarter, isRest: false, dots: 1);
        expect(note1 == note2, isFalse);
      });

      test('notes with different pitch are not equal when dots are same', () {
        final note1 = Note(
            pitch: pitchC4, duration: durationQuarter, isRest: false, dots: 1);
        final note2 = Note(
            pitch: pitchG4, duration: durationQuarter, isRest: false, dots: 1);
        expect(note1 == note2, isFalse);
      });

      test('notes with different duration are not equal when dots are same',
          () {
        final note1 = Note(
            pitch: pitchC4, duration: durationQuarter, isRest: false, dots: 1);
        final note2 = Note(
            pitch: pitchC4, duration: durationHalf, isRest: false, dots: 1);
        expect(note1 == note2, isFalse);
      });

      test('rest vs pitch note with same duration and dots are not equal', () {
        final note1 = Note(
            pitch: pitchC4, duration: durationQuarter, isRest: false, dots: 1);
        final note2 = Note(duration: durationQuarter, isRest: true, dots: 1);
        expect(note1 == note2, isFalse);
      });
    });

    group('toString representation', () {
      test('toString includes dot information for single dot', () {
        final note = Note(
            pitch: pitchC4, duration: durationQuarter, isRest: false, dots: 1);
        expect(note.toString(), contains('dots: 1'));
      });

      test('toString includes dot information for multiple dots', () {
        final note = Note(
            pitch: pitchC4, duration: durationQuarter, isRest: false, dots: 2);
        expect(note.toString(), contains('dots: 2'));
      });

      test('toString does not mention dots if dots is null', () {
        final note = Note(
            pitch: pitchC4,
            duration: durationQuarter,
            isRest: false,
            dots: null);
        expect(note.toString(), isNot(contains('dots:')));
      });

      test('toString does not mention dots if dots is 0', () {
        // Based on the implementation: "if (dots != null && dots! > 0)"
        final note = Note(
            pitch: pitchC4, duration: durationQuarter, isRest: false, dots: 0);
        expect(note.toString(), isNot(contains('dots:')));
      });

      test('toString for rest with dots', () {
        final rest = Note(duration: durationQuarter, isRest: true, dots: 1);
        expect(
            rest.toString(),
            contains(
                'Rest{duration: Duration{value: 480, divisions: 480}, dots: 1}'));
      });

      test('toString for rest with no dots', () {
        final rest = Note(duration: durationQuarter, isRest: true, dots: null);
        expect(rest.toString(),
            equals('Rest{duration: Duration{value: 480, divisions: 480}}'));
      });
    });

    group('Note.validated factory', () {
      test('Note.validated allows positive dots', () {
        expect(
            () => Note.validated(
                pitch: pitchC4, duration: durationQuarter, dots: 1),
            returnsNormally);
        final note =
            Note.validated(pitch: pitchC4, duration: durationQuarter, dots: 1);
        expect(note.dots, equals(1));
      });

      test('Note.validated allows null dots', () {
        expect(
            () => Note.validated(
                pitch: pitchC4, duration: durationQuarter, dots: null),
            returnsNormally);
        final note = Note.validated(
            pitch: pitchC4, duration: durationQuarter, dots: null);
        expect(note.dots, isNull);
      });

      test('Note.validated allows zero dots', () {
        expect(
            () => Note.validated(
                pitch: pitchC4, duration: durationQuarter, dots: 0),
            returnsNormally);
        final note =
            Note.validated(pitch: pitchC4, duration: durationQuarter, dots: 0);
        expect(note.dots, equals(0));
      });

      test('Note.validated throws for negative dots', () {
        expect(
            () => Note.validated(
                pitch: pitchC4, duration: durationQuarter, dots: -1),
            throwsA(isA<MusicXmlValidationException>()
                .having((e) => e.message, 'message',
                    'Note dots must be non-negative, got -1')
                .having((e) => e.rule, 'rule', 'note_dots_validation')));
      });

      // Test for rest with dots using validated factory
      test('Note.validated allows dots for rests', () {
        expect(
            () => Note.validated(
                isRest: true, duration: durationQuarter, dots: 1),
            returnsNormally);
        final rest =
            Note.validated(isRest: true, duration: durationQuarter, dots: 1);
        expect(rest.isRest, isTrue);
        expect(rest.dots, equals(1));
      });

      test('Note.validated throws for negative dots on a rest', () {
        expect(
            () => Note.validated(
                isRest: true, duration: durationQuarter, dots: -1),
            throwsA(isA<MusicXmlValidationException>().having((e) => e.message,
                'message', 'Note dots must be non-negative, got -1')));
      });
    });
  });
}
