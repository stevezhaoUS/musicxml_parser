import 'package:musicxml_parser/src/models/ending.dart';
import 'package:test/test.dart';

void main() {
  group('EndingType', () {
    test('has correct enum values', () {
      expect(EndingType.values.length, equals(3));
      expect(EndingType.values, contains(EndingType.start));
      expect(EndingType.values, contains(EndingType.stop));
      expect(EndingType.values, contains(EndingType.discontinue));
    });
  });

  group('Ending', () {
    test('constructor sets properties correctly', () {
      const ending = Ending(
        number: '1',
        type: EndingType.start,
      );
      expect(ending.number, equals('1'));
      expect(ending.type, equals(EndingType.start));
      expect(ending.text, isNull);
    });

    test('constructor with text', () {
      const ending = Ending(
        number: '2',
        type: EndingType.stop,
        text: 'Second time',
      );
      expect(ending.number, equals('2'));
      expect(ending.type, equals(EndingType.stop));
      expect(ending.text, equals('Second time'));
    });

    test('constructor with multiple numbers', () {
      const ending = Ending(
        number: '1,2',
        type: EndingType.start,
      );
      expect(ending.number, equals('1,2'));
      expect(ending.type, equals(EndingType.start));
    });

    test('equals works correctly', () {
      const ending1 = Ending(
        number: '1',
        type: EndingType.start,
      );
      const ending2 = Ending(
        number: '1',
        type: EndingType.start,
      );
      const ending3 = Ending(
        number: '2',
        type: EndingType.start,
      );

      expect(ending1, equals(ending2));
      expect(ending1, isNot(equals(ending3)));
    });

    test('equals works correctly with text', () {
      const ending1 = Ending(
        number: '1',
        type: EndingType.start,
        text: 'First time',
      );
      const ending2 = Ending(
        number: '1',
        type: EndingType.start,
        text: 'First time',
      );
      const ending3 = Ending(
        number: '1',
        type: EndingType.start,
        text: 'Different text',
      );

      expect(ending1, equals(ending2));
      expect(ending1, isNot(equals(ending3)));
    });

    test('hashCode works correctly', () {
      const ending1 = Ending(
        number: '1',
        type: EndingType.start,
      );
      const ending2 = Ending(
        number: '1',
        type: EndingType.start,
      );

      expect(ending1.hashCode, equals(ending2.hashCode));
    });

    test('toString returns correct string representation', () {
      const ending = Ending(
        number: '1',
        type: EndingType.start,
      );
      expect(ending.toString(), equals('Ending{number: 1, type: EndingType.start, text: null}'));
    });

    test('toString with text', () {
      const ending = Ending(
        number: '2',
        type: EndingType.stop,
        text: 'Second time',
      );
      expect(ending.toString(), equals('Ending{number: 2, type: EndingType.stop, text: Second time}'));
    });

    test('toString with multiple numbers', () {
      const ending = Ending(
        number: '1,2,3',
        type: EndingType.discontinue,
      );
      expect(ending.toString(), equals('Ending{number: 1,2,3, type: EndingType.discontinue, text: null}'));
    });
  });
}