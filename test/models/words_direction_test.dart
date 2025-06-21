import 'package:musicxml_parser/src/models/direction_words.dart';
import 'package:test/test.dart';

void main() {
  group('WordsDirection', () {
    test('constructor sets all properties correctly', () {
      const wordsDirection = WordsDirection(
        text: 'Sample Text',
        color: '#FF0000',
        defaultX: 10.0,
        defaultY: 20.0,
        dir: 'ltr',
        enclosure: 'rectangle',
        fontFamily: 'Arial',
        fontSize: '12pt',
        fontStyle: 'italic',
        fontWeight: 'bold',
        halign: 'center',
        id: 'words1',
        justify: 'left',
        letterSpacing: 'normal',
        lineHeight: '1.2',
        lineThrough: 1,
        overline: 0,
        relativeX: 5.0,
        relativeY: -5.0,
        rotation: 45.0,
        underline: 1,
        valign: 'middle',
        xmlLang: 'en',
        xmlSpace: 'preserve',
      );

      expect(wordsDirection.text, 'Sample Text');
      expect(wordsDirection.color, '#FF0000');
      expect(wordsDirection.defaultX, 10.0);
      expect(wordsDirection.defaultY, 20.0);
      expect(wordsDirection.dir, 'ltr');
      expect(wordsDirection.enclosure, 'rectangle');
      expect(wordsDirection.fontFamily, 'Arial');
      expect(wordsDirection.fontSize, '12pt');
      expect(wordsDirection.fontStyle, 'italic');
      expect(wordsDirection.fontWeight, 'bold');
      expect(wordsDirection.halign, 'center');
      expect(wordsDirection.id, 'words1');
      expect(wordsDirection.justify, 'left');
      expect(wordsDirection.letterSpacing, 'normal');
      expect(wordsDirection.lineHeight, '1.2');
      expect(wordsDirection.lineThrough, 1);
      expect(wordsDirection.overline, 0);
      expect(wordsDirection.relativeX, 5.0);
      expect(wordsDirection.relativeY, -5.0);
      expect(wordsDirection.rotation, 45.0);
      expect(wordsDirection.underline, 1);
      expect(wordsDirection.valign, 'middle');
      expect(wordsDirection.xmlLang, 'en');
      expect(wordsDirection.xmlSpace, 'preserve');
    });

    test('equality holds for identical instances', () {
      const wordsDirection1 = WordsDirection(
        text: 'Test',
        fontFamily: 'Times New Roman',
        fontSize: '10',
      );
      const wordsDirection2 = WordsDirection(
        text: 'Test',
        fontFamily: 'Times New Roman',
        fontSize: '10',
      );
      expect(wordsDirection1, equals(wordsDirection2));
    });

    test('equality fails for different instances', () {
      const wordsDirection1 = WordsDirection(text: 'Test1');
      const wordsDirection2 = WordsDirection(text: 'Test2');
      expect(wordsDirection1, isNot(equals(wordsDirection2)));
    });

    test('hashCode is consistent', () {
      const wordsDirection = WordsDirection(text: 'HashCodeTest');
      expect(wordsDirection.hashCode, equals(wordsDirection.hashCode));
    });

    test('toString contains all relevant fields', () {
      const wordsDirection = WordsDirection(
        text: 'ToString',
        fontFamily: 'Verdana',
        defaultX: 15,
      );
      final stringRepresentation = wordsDirection.toString();
      expect(stringRepresentation, contains('ToString'));
      expect(stringRepresentation, contains('Verdana'));
      expect(stringRepresentation, contains('15'));
    });
  });
}
