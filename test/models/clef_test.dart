import 'package:musicxml_parser/src/models/clef.dart';
import 'package:test/test.dart';

void main() {
  group('Clef', () {
    test('constructor sets properties correctly', () {
      const clef = Clef(sign: 'G', line: 2, octaveChange: 1, number: 1);
      expect(clef.sign, 'G');
      expect(clef.line, 2);
      expect(clef.octaveChange, 1);
      expect(clef.number, 1);
    });

    test('constructor handles optional properties', () {
      const clef = Clef(sign: 'F');
      expect(clef.sign, 'F');
      expect(clef.line, isNull);
      expect(clef.octaveChange, isNull);
      expect(clef.number, isNull);
    });

    test('equality works correctly', () {
      const clef1 = Clef(sign: 'G', line: 2, octaveChange: 0, number: 1);
      const clef2 = Clef(sign: 'G', line: 2, octaveChange: 0, number: 1);
      const clef3 = Clef(sign: 'F', line: 4, number: 2);

      expect(clef1, equals(clef2));
      expect(clef1, isNot(equals(clef3)));
      expect(clef2, isNot(equals(clef3)));
    });

    test('hashCode is consistent with equality', () {
      const clef1 = Clef(sign: 'G', line: 2, number: 1);
      const clef2 = Clef(sign: 'G', line: 2, number: 1);
      const clef3 = Clef(sign: 'C', line: 3, octaveChange: -1);

      expect(clef1.hashCode, equals(clef2.hashCode));
      expect(clef1.hashCode, isNot(equals(clef3.hashCode)));
    });

    test('toString() produces correct output', () {
      const clef1 = Clef(sign: 'G', line: 2);
      expect(clef1.toString(), 'Clef{sign: G, line: 2}');

      const clef2 = Clef(sign: 'F', line: 4, octaveChange: -1, number: 2);
      expect(clef2.toString(),
          'Clef{sign: F, line: 4, octaveChange: -1, staff: 2}');

      const clef3 = Clef(sign: 'percussion');
      expect(clef3.toString(), 'Clef{sign: percussion}');

      const clef4 = Clef(sign: 'G', line: 2, octaveChange: 0, number: 1);
      expect(clef4.toString(), 'Clef{sign: G, line: 2, staff: 1}');
    });
  });
}
