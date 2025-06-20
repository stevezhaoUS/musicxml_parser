import 'package:musicxml_parser/src/models/slur.dart'; // Adjust import as needed
import 'package:test/test.dart';

void main() {
  group('Slur Model', () {
    group('constructor and properties', () {
      test('creates instance with all properties', () {
        const slur = Slur(type: 'start', number: 2, placement: 'above');
        expect(slur.type, 'start');
        expect(slur.number, 2);
        expect(slur.placement, 'above');
      });

      test('number defaults to 1 if not specified', () {
        const slur = Slur(type: 'stop', placement: 'below');
        expect(slur.type, 'stop');
        expect(slur.number, 1); // Default value
        expect(slur.placement, 'below');
      });

      test('placement can be null', () {
        const slur = Slur(type: 'continue', number: 3);
        expect(slur.type, 'continue');
        expect(slur.number, 3);
        expect(slur.placement, isNull);
      });
    });

    group('equality and hashCode', () {
      const slur1 = Slur(type: 'start', number: 1, placement: 'above');
      const slur2 = Slur(type: 'start', number: 1, placement: 'above');
      const slur3 = Slur(type: 'stop', number: 1, placement: 'above'); // Different type
      const slur4 = Slur(type: 'start', number: 2, placement: 'above'); // Different number
      const slur5 = Slur(type: 'start', number: 1, placement: 'below'); // Different placement
      const slur6 = Slur(type: 'start', number: 1); // Null placement

      test('instances with same values are equal and have same hashCode', () {
        expect(slur1, equals(slur2));
        expect(slur1.hashCode, equals(slur2.hashCode));
      });

      test('instances with different type are not equal', () {
        expect(slur1, isNot(equals(slur3)));
      });

      test('instances with different number are not equal', () {
        expect(slur1, isNot(equals(slur4)));
      });

      test('instances with different placement are not equal', () {
        expect(slur1, isNot(equals(slur5)));
      });

      test('instances with null vs non-null placement are not equal', () {
        expect(slur1, isNot(equals(slur6)));
      });
       test('instances with different null placements are equal', () {
        const s1 = Slur(type: 'start', number: 1);
        const s2 = Slur(type: 'start', number: 1);
        expect(s1, equals(s2));
        expect(s1.hashCode, equals(s2.hashCode));
      });
    });

    group('toString representation', () {
      test('includes all fields when present', () {
        const slur = Slur(type: 'start', number: 1, placement: 'above');
        expect(slur.toString(), equals('Slur{type: start, number: 1, placement: above}'));
      });

      test('omits placement when null', () {
        const slur = Slur(type: 'start', number: 2);
        expect(slur.toString(), equals('Slur{type: start, number: 2}'));
      });
       test('handles default number correctly in toString', () {
        const slur = Slur(type: 'stop');
        expect(slur.toString(), equals('Slur{type: stop, number: 1}'));
      });
    });
  });
}
