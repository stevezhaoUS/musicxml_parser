import 'package:musicxml_parser/src/models/direction_type_elements.dart';
import 'package:musicxml_parser/src/models/direction_words.dart';
import 'package:test/test.dart';

void main() {
  group('DirectionTypeElement subclasses', () {
    group('Segno', () {
      test('constructor sets all properties correctly', () {
        const segno = Segno(
          color: '#00FF00',
          defaultX: 1.0,
          defaultY: 2.0,
          fontFamily: 'Arial',
          fontSize: '10pt',
          fontStyle: 'italic',
          fontWeight: 'bold',
          halign: 'left',
          id: 'segno1',
          relativeX: 0.5,
          relativeY: -0.5,
          smufl: 'segnoSmufl',
          valign: 'top',
        );
        expect(segno.color, '#00FF00');
        expect(segno.defaultX, 1.0);
        // ... (add expects for all properties)
        expect(segno.smufl, 'segnoSmufl');
      });

      test('equality holds for identical instances', () {
        const segno1 = Segno(id: 's1');
        const segno2 = Segno(id: 's1');
        expect(segno1, equals(segno2));
      });

      test('equality fails for different instances', () {
        const segno1 = Segno(id: 's1');
        const segno2 = Segno(id: 's2');
        expect(segno1, isNot(equals(segno2)));
      });
    });

    group('Coda', () {
      test('constructor sets all properties correctly', () {
        const coda = Coda(
          color: '#0000FF',
          defaultX: 3.0,
          defaultY: 4.0,
          fontFamily: 'Times',
          fontSize: '12pt',
          fontStyle: 'normal',
          fontWeight: 'normal',
          halign: 'right',
          id: 'coda1',
          relativeX: 0.2,
          relativeY: -0.2,
          smufl: 'codaSmufl',
          valign: 'bottom',
        );
        expect(coda.color, '#0000FF');
        // ... (add expects for all properties)
        expect(coda.smufl, 'codaSmufl');
      });
      // Add equality tests like Segno
    });

    group('Dynamics', () {
      test('constructor sets all properties correctly', () {
        const dynamics = Dynamics(
          values: ['p', 'sfz'],
          color: '#FFFF00',
          defaultX: 5.0,
          defaultY: 6.0,
          enclosure: 'oval',
          // ... (add other properties)
          valign: 'baseline',
        );
        expect(dynamics.values, equals(['p', 'sfz']));
        expect(dynamics.color, '#FFFF00');
        // ... (add expects for all properties)
        expect(dynamics.valign, 'baseline');
      });
      // Add equality tests like Segno
      test('equality holds for identical instances with lists', () {
        const d1 = Dynamics(values: ['f', 'p'], id: 'dyn1');
        const d2 = Dynamics(values: ['f', 'p'], id: 'dyn1');
        expect(d1, equals(d2));
      });
      test('equality fails for different lists', () {
        const d1 = Dynamics(values: ['f', 'p'], id: 'dyn1');
        const d2 = Dynamics(values: ['p', 'f'], id: 'dyn1');
        expect(d1, isNot(equals(d2)));
      });
    });

    group('WordsDirection (as DirectionTypeElement)', () {
      test('constructor sets all properties correctly', () {
        const words = WordsDirection(
          text: 'Crescendo',
          color: '#123456',
          fontFamily: 'Helvetica',
          // ... (add other properties from WordsDirection)
        );
        expect(words.text, 'Crescendo');
        expect(words.color, '#123456');
        // ... (add expects)
      });
      // Add equality tests
    });
  });
}
