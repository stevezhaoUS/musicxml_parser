import 'package:musicxml_parser/src/models/tie.dart'; // Adjust import as needed
import 'package:test/test.dart';

void main() {
  group('Tie Model', () {
    group('constructor and properties', () {
      test('creates instance with all properties', () {
        const tie = Tie(type: 'start', placement: 'above');
        expect(tie.type, 'start');
        expect(tie.placement, 'above');
      });

      test('placement can be null', () {
        const tie = Tie(type: 'stop');
        expect(tie.type, 'stop');
        expect(tie.placement, isNull);
      });
    });

    group('equality and hashCode', () {
      const tie1 = Tie(type: 'start', placement: 'above');
      const tie2 = Tie(type: 'start', placement: 'above');
      const tie3 = Tie(type: 'stop', placement: 'above'); // Different type
      const tie4 = Tie(type: 'start', placement: 'below'); // Different placement
      const tie5 = Tie(type: 'start'); // Null placement

      test('instances with same values are equal and have same hashCode', () {
        expect(tie1, equals(tie2));
        expect(tie1.hashCode, equals(tie2.hashCode));
      });

      test('instances with different type are not equal', () {
        expect(tie1, isNot(equals(tie3)));
      });

      test('instances with different placement are not equal', () {
        expect(tie1, isNot(equals(tie4)));
      });

      test('instances with null vs non-null placement are not equal', () {
        expect(tie1, isNot(equals(tie5)));
      });

      test('instances with both placement null are equal', () {
        const tie_null1 = Tie(type: 'start');
        const tie_null2 = Tie(type: 'start');
        expect(tie_null1, equals(tie_null2));
        expect(tie_null1.hashCode, equals(tie_null2.hashCode));
      });
    });

    group('toString representation', () {
      test('includes all fields when present', () {
        const tie = Tie(type: 'start', placement: 'below');
        expect(tie.toString(), equals('Tie{type: start, placement: below}'));
      });

      test('omits placement when null', () {
        const tie = Tie(type: 'stop');
        expect(tie.toString(), equals('Tie{type: stop}'));
      });
    });
  });
}
