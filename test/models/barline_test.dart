import 'package:musicxml_parser/src/models/barline.dart';
import 'package:musicxml_parser/src/models/repeat.dart';
import 'package:musicxml_parser/src/models/ending.dart';
import 'package:test/test.dart';

void main() {
  group('BarlineLocation', () {
    test('has correct enum values', () {
      expect(BarlineLocation.values.length, equals(3));
      expect(BarlineLocation.values, contains(BarlineLocation.left));
      expect(BarlineLocation.values, contains(BarlineLocation.right));
      expect(BarlineLocation.values, contains(BarlineLocation.middle));
    });
  });

  group('BarlineStyle', () {
    test('has correct enum values', () {
      expect(BarlineStyle.values.length, equals(8));
      expect(BarlineStyle.values, contains(BarlineStyle.regular));
      expect(BarlineStyle.values, contains(BarlineStyle.lightHeavy));
      expect(BarlineStyle.values, contains(BarlineStyle.heavyLight));
      expect(BarlineStyle.values, contains(BarlineStyle.lightLight));
      expect(BarlineStyle.values, contains(BarlineStyle.heavyHeavy));
      expect(BarlineStyle.values, contains(BarlineStyle.dashed));
      expect(BarlineStyle.values, contains(BarlineStyle.dotted));
      expect(BarlineStyle.values, contains(BarlineStyle.none));
    });
  });

  group('Barline', () {
    test('constructor sets properties correctly', () {
      const barline = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.regular,
      );
      expect(barline.location, equals(BarlineLocation.right));
      expect(barline.style, equals(BarlineStyle.regular));
      expect(barline.repeat, isNull);
      expect(barline.ending, isNull);
    });

    test('constructor with repeat and ending', () {
      const repeat = Repeat(direction: RepeatDirection.backward);
      const ending = Ending(number: '1', type: EndingType.start);
      
      const barline = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.lightHeavy,
        repeat: repeat,
        ending: ending,
      );
      
      expect(barline.location, equals(BarlineLocation.right));
      expect(barline.style, equals(BarlineStyle.lightHeavy));
      expect(barline.repeat, equals(repeat));
      expect(barline.ending, equals(ending));
    });

    test('equals works correctly', () {
      const barline1 = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.regular,
      );
      const barline2 = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.regular,
      );
      const barline3 = Barline(
        location: BarlineLocation.left,
        style: BarlineStyle.regular,
      );

      expect(barline1, equals(barline2));
      expect(barline1, isNot(equals(barline3)));
    });

    test('equals works correctly with repeat and ending', () {
      const repeat = Repeat(direction: RepeatDirection.backward);
      const ending = Ending(number: '1', type: EndingType.start);
      
      const barline1 = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.lightHeavy,
        repeat: repeat,
        ending: ending,
      );
      const barline2 = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.lightHeavy,
        repeat: repeat,
        ending: ending,
      );
      const barline3 = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.lightHeavy,
        repeat: repeat,
      );

      expect(barline1, equals(barline2));
      expect(barline1, isNot(equals(barline3)));
    });

    test('hashCode works correctly', () {
      const barline1 = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.regular,
      );
      const barline2 = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.regular,
      );

      expect(barline1.hashCode, equals(barline2.hashCode));
    });

    test('toString returns correct string representation', () {
      const barline = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.regular,
      );
      expect(barline.toString(), equals('Barline{location: BarlineLocation.right, style: BarlineStyle.regular, repeat: null, ending: null}'));
    });

    test('toString with repeat and ending', () {
      const repeat = Repeat(direction: RepeatDirection.backward);
      const ending = Ending(number: '1', type: EndingType.start);
      
      const barline = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.lightHeavy,
        repeat: repeat,
        ending: ending,
      );
      
      expect(barline.toString(), contains('Barline{location: BarlineLocation.right'));
      expect(barline.toString(), contains('style: BarlineStyle.lightHeavy'));
      expect(barline.toString(), contains('repeat: Repeat{direction: RepeatDirection.backward'));
      expect(barline.toString(), contains('ending: Ending{number: 1'));
    });
  });
}