import 'package:musicxml_parser/src/models/time_modification.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:test/test.dart';

void main() {
  group('TimeModification Model', () {
    group('constructor and basic properties', () {
      test('creates instance with all properties', () {
        const tm = TimeModification(
          actualNotes: 3,
          normalNotes: 2,
          normalType: 'eighth',
          normalDotCount: 1,
        );
        expect(tm.actualNotes, 3);
        expect(tm.normalNotes, 2);
        expect(tm.normalType, 'eighth');
        expect(tm.normalDotCount, 1);
      });

      test('creates instance with minimal properties', () {
        // normalType and normalDotCount are optional
        const tm = TimeModification(
          actualNotes: 3,
          normalNotes: 2,
        );
        expect(tm.actualNotes, 3);
        expect(tm.normalNotes, 2);
        expect(tm.normalType, isNull);
        expect(tm.normalDotCount, isNull);
      });
    });

    group('equality and hashCode', () {
      const tm1 = TimeModification(actualNotes: 3, normalNotes: 2, normalType: 'eighth', normalDotCount: 0);
      const tm2 = TimeModification(actualNotes: 3, normalNotes: 2, normalType: 'eighth', normalDotCount: 0);
      const tm3 = TimeModification(actualNotes: 5, normalNotes: 4, normalType: 'quarter'); // Different actual/normal notes
      const tm4 = TimeModification(actualNotes: 3, normalNotes: 2, normalType: 'quarter'); // Different normalType
      const tm5 = TimeModification(actualNotes: 3, normalNotes: 2, normalType: 'eighth', normalDotCount: 1); // Different normalDotCount

      test('instances with same values are equal and have same hashCode', () {
        expect(tm1, equals(tm2));
        expect(tm1.hashCode, equals(tm2.hashCode));
      });

      test('instances with different actualNotes are not equal', () {
        expect(tm1, isNot(equals(tm3)));
      });

      test('instances with different normalNotes are not equal', () {
         const tm_diff_normal = TimeModification(actualNotes: 3, normalNotes: 3, normalType: 'eighth');
        expect(tm1, isNot(equals(tm_diff_normal)));
      });

      test('instances with different normalType are not equal', () {
        expect(tm1, isNot(equals(tm4)));
      });

      test('instances with different normalDotCount are not equal', () {
        expect(tm1, isNot(equals(tm5)));
      });

      test('instances with null vs non-null optional fields are not equal', () {
        const tm_null_type = TimeModification(actualNotes: 3, normalNotes: 2, normalDotCount: 0); // normalType is null
        const tm_null_dots = TimeModification(actualNotes: 3, normalNotes: 2, normalType: 'eighth'); // normalDotCount is null

        // tm1 has normalType: 'eighth', normalDotCount: 0
        // tm_null_type has normalType: null, normalDotCount: 0
        expect(tm1, isNot(equals(tm_null_type)));

        // tm_null_dots has normalType: 'eighth', normalDotCount: null
        expect(tm1, isNot(equals(tm_null_dots)));
      });
    });

    group('toString representation', () {
      test('includes all fields when present', () {
        const tm = TimeModification(
          actualNotes: 3,
          normalNotes: 2,
          normalType: 'eighth',
          normalDotCount: 1,
        );
        expect(tm.toString(), contains('actualNotes: 3'));
        expect(tm.toString(), contains('normalNotes: 2'));
        expect(tm.toString(), contains('normalType: eighth'));
        expect(tm.toString(), contains('normalDotCount: 1'));
        expect(tm.toString(), equals('TimeModification{actualNotes: 3, normalNotes: 2, normalType: eighth, normalDotCount: 1}'));
      });

      test('omits optional fields when null', () {
        const tm = TimeModification(actualNotes: 3, normalNotes: 2);
        expect(tm.toString(), contains('actualNotes: 3'));
        expect(tm.toString(), contains('normalNotes: 2'));
        expect(tm.toString(), isNot(contains('normalType:')));
        expect(tm.toString(), isNot(contains('normalDotCount:')));
        expect(tm.toString(), equals('TimeModification{actualNotes: 3, normalNotes: 2}'));
      });

      test('omits only normalDotCount when normalType is present and normalDotCount is null', () {
        const tm = TimeModification(actualNotes: 3, normalNotes: 2, normalType: 'quarter');
        expect(tm.toString(), contains('actualNotes: 3'));
        expect(tm.toString(), contains('normalNotes: 2'));
        expect(tm.toString(), contains('normalType: quarter'));
        expect(tm.toString(), isNot(contains('normalDotCount:')));
        expect(tm.toString(), equals('TimeModification{actualNotes: 3, normalNotes: 2, normalType: quarter}'));
      });

      test('omits only normalType when normalDotCount is present and normalType is null', () {
        const tm = TimeModification(actualNotes: 3, normalNotes: 2, normalDotCount: 0);
        expect(tm.toString(), contains('actualNotes: 3'));
        expect(tm.toString(), contains('normalNotes: 2'));
        expect(tm.toString(), isNot(contains('normalType:')));
        expect(tm.toString(), contains('normalDotCount: 0'));
        expect(tm.toString(), equals('TimeModification{actualNotes: 3, normalNotes: 2, normalDotCount: 0}'));
      });
    });

    group('TimeModification.validated factory', () {
      test('allows valid values', () {
        expect(
            () => TimeModification.validated(
                actualNotes: 3, normalNotes: 2, normalType: 'eighth', normalDotCount: 1),
            returnsNormally);
        expect(
            () => TimeModification.validated(
                actualNotes: 3, normalNotes: 2, normalDotCount: 0), // normalDotCount = 0 is valid
            returnsNormally);
        expect(
            () => TimeModification.validated(
                actualNotes: 3, normalNotes: 2), // null normalDotCount is valid
            returnsNormally);
      });

      test('throws for non-positive actualNotes', () {
        expect(
            () => TimeModification.validated(actualNotes: 0, normalNotes: 2),
            throwsA(isA<MusicXmlValidationException>().having(
                (e) => e.rule, 'rule', 'time_modification_actual_notes_positive')));
        expect(
            () => TimeModification.validated(actualNotes: -1, normalNotes: 2),
            throwsA(isA<MusicXmlValidationException>().having(
                (e) => e.rule, 'rule', 'time_modification_actual_notes_positive')));
      });

      test('throws for non-positive normalNotes', () {
        expect(
            () => TimeModification.validated(actualNotes: 3, normalNotes: 0),
            throwsA(isA<MusicXmlValidationException>().having(
                (e) => e.rule, 'rule', 'time_modification_normal_notes_positive')));
        expect(
            () => TimeModification.validated(actualNotes: 3, normalNotes: -1),
            throwsA(isA<MusicXmlValidationException>().having(
                (e) => e.rule, 'rule', 'time_modification_normal_notes_positive')));
      });

      test('throws for negative normalDotCount if specified', () {
        expect(
            () => TimeModification.validated(actualNotes: 3, normalNotes: 2, normalDotCount: -1),
            throwsA(isA<MusicXmlValidationException>().having(
                (e) => e.rule, 'rule', 'time_modification_normal_dot_count_non_negative')));
      });

      test('allows normalDotCount to be null or 0 and sets value correctly', () {
         final tmNull = TimeModification.validated(actualNotes: 3, normalNotes: 2, normalDotCount: null);
         expect(tmNull.normalDotCount, isNull);
         final tmZero = TimeModification.validated(actualNotes: 3, normalNotes: 2, normalDotCount: 0);
         expect(tmZero.normalDotCount, 0);
      });
    });
  });
}
