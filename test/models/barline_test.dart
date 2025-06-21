import 'package:musicxml_parser/src/models/barline.dart'; // Adjust import as needed
import 'package:test/test.dart';

void main() {
  group('Barline Model', () {
    group('constructor and properties', () {
      test('creates instance with all properties', () {
        const barline = Barline(
          location: 'right',
          barStyle: 'light-heavy',
          repeatDirection: 'backward',
          times: 2,
        );
        expect(barline.location, 'right');
        expect(barline.barStyle, 'light-heavy');
        expect(barline.repeatDirection, 'backward');
        expect(barline.times, 2);
      });

      test('all properties can be null (or default)', () {
        const barline = Barline();
        expect(barline.location, isNull);
        expect(barline.barStyle, isNull);
        expect(barline.repeatDirection, isNull);
        expect(barline.times, isNull);
      });
    });

    group('equality and hashCode', () {
      const b1 = Barline(location: 'right', barStyle: 'light-heavy', repeatDirection: 'backward', times: 2);
      const b2 = Barline(location: 'right', barStyle: 'light-heavy', repeatDirection: 'backward', times: 2);
      const b3 = Barline(location: 'left', barStyle: 'light-heavy', repeatDirection: 'backward', times: 2); // diff location
      const b4 = Barline(location: 'right', barStyle: 'light-light', repeatDirection: 'backward', times: 2); // diff barStyle
      const b5 = Barline(location: 'right', barStyle: 'light-heavy', repeatDirection: 'forward', times: 2); // diff repeatDirection
      const b6 = Barline(location: 'right', barStyle: 'light-heavy', repeatDirection: 'backward', times: 3); // diff times
      const b7 = Barline(); // all null

      test('instances with same values are equal and have same hashCode', () {
        expect(b1, equals(b2));
        expect(b1.hashCode, equals(b2.hashCode));
      });

      test('instances with all null values are equal', () {
        const b_all_null1 = Barline();
        const b_all_null2 = Barline();
        expect(b_all_null1, equals(b_all_null2));
        expect(b_all_null1.hashCode, equals(b_all_null2.hashCode));
      });

      test('instances with different location are not equal', () {
        expect(b1, isNot(equals(b3)));
      });

      test('instances with different barStyle are not equal', () {
        expect(b1, isNot(equals(b4)));
      });

      test('instances with different repeatDirection are not equal', () {
        expect(b1, isNot(equals(b5)));
      });

      test('instances with different times are not equal', () {
        expect(b1, isNot(equals(b6)));
      });

      test('instance with values vs all null is not equal', () {
        expect(b1, isNot(equals(b7)));
      });
    });

    group('toString representation', () {
      test('includes all fields when present', () {
        const barline = Barline(location: 'right', barStyle: 'light-heavy', repeatDirection: 'backward', times: 2);
        expect(barline.toString(), equals('Barline{location: right, barStyle: light-heavy, repeatDirection: backward, times: 2}'));
      });

      test('omits fields when null', () {
        const barline = Barline(barStyle: 'none');
        expect(barline.toString(), equals('Barline{barStyle: none}'));
      });

      test('empty when all fields null', () {
        const barline = Barline();
        expect(barline.toString(), equals('Barline{}'));
      });
    });
  });
}
