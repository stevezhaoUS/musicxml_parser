import 'package:musicxml_parser/src/models/articulation.dart'; // Adjust import as needed
import 'package:test/test.dart';

void main() {
  group('Articulation Model', () {
    group('constructor and properties', () {
      test('creates instance with all properties', () {
        const articulation = Articulation(type: 'staccato', placement: 'above');
        expect(articulation.type, 'staccato');
        expect(articulation.placement, 'above');
      });

      test('placement can be null', () {
        const articulation = Articulation(type: 'accent');
        expect(articulation.type, 'accent');
        expect(articulation.placement, isNull);
      });
    });

    group('equality and hashCode', () {
      const art1 = Articulation(type: 'staccato', placement: 'above');
      const art2 = Articulation(type: 'staccato', placement: 'above');
      const art3 =
          Articulation(type: 'accent', placement: 'above'); // Different type
      const art4 = Articulation(
          type: 'staccato', placement: 'below'); // Different placement
      const art5 = Articulation(type: 'staccato'); // Null placement

      test('instances with same values are equal and have same hashCode', () {
        expect(art1, equals(art2));
        expect(art1.hashCode, equals(art2.hashCode));
      });

      test('instances with different type are not equal', () {
        expect(art1, isNot(equals(art3)));
      });

      test('instances with different placement are not equal', () {
        expect(art1, isNot(equals(art4)));
      });

      test('instances with null vs non-null placement are not equal', () {
        expect(art1, isNot(equals(art5)));
      });

      test('instances with both placement null are equal', () {
        const art_null1 = Articulation(type: 'tenuto');
        const art_null2 = Articulation(type: 'tenuto');
        expect(art_null1, equals(art_null2));
        expect(art_null1.hashCode, equals(art_null2.hashCode));
      });
    });

    group('toString representation', () {
      test('includes all fields when present', () {
        const articulation = Articulation(type: 'accent', placement: 'below');
        expect(articulation.toString(),
            equals('Articulation{type: accent, placement: below}'));
      });

      test('omits placement when null', () {
        const articulation = Articulation(type: 'strong-accent');
        expect(articulation.toString(),
            equals('Articulation{type: strong-accent}'));
      });
    });
  });
}
