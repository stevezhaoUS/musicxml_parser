import 'package:musicxml_parser/src/models/repeat.dart';
import 'package:test/test.dart';

void main() {
  group('RepeatDirection', () {
    test('has correct enum values', () {
      expect(RepeatDirection.values.length, equals(2));
      expect(RepeatDirection.values, contains(RepeatDirection.forward));
      expect(RepeatDirection.values, contains(RepeatDirection.backward));
    });
  });

  group('Repeat', () {
    test('constructor sets properties correctly', () {
      const repeat = Repeat(direction: RepeatDirection.forward);
      expect(repeat.direction, equals(RepeatDirection.forward));
      expect(repeat.times, isNull);
    });

    test('constructor with times', () {
      const repeat = Repeat(
        direction: RepeatDirection.backward,
        times: 3,
      );
      expect(repeat.direction, equals(RepeatDirection.backward));
      expect(repeat.times, equals(3));
    });

    test('equals works correctly', () {
      const repeat1 = Repeat(direction: RepeatDirection.forward);
      const repeat2 = Repeat(direction: RepeatDirection.forward);
      const repeat3 = Repeat(direction: RepeatDirection.backward);

      expect(repeat1, equals(repeat2));
      expect(repeat1, isNot(equals(repeat3)));
    });

    test('equals works correctly with times', () {
      const repeat1 = Repeat(
        direction: RepeatDirection.backward,
        times: 2,
      );
      const repeat2 = Repeat(
        direction: RepeatDirection.backward,
        times: 2,
      );
      const repeat3 = Repeat(
        direction: RepeatDirection.backward,
        times: 3,
      );

      expect(repeat1, equals(repeat2));
      expect(repeat1, isNot(equals(repeat3)));
    });

    test('hashCode works correctly', () {
      const repeat1 = Repeat(direction: RepeatDirection.forward);
      const repeat2 = Repeat(direction: RepeatDirection.forward);

      expect(repeat1.hashCode, equals(repeat2.hashCode));
    });

    test('toString returns correct string representation', () {
      const repeat = Repeat(direction: RepeatDirection.forward);
      expect(repeat.toString(), equals('Repeat{direction: RepeatDirection.forward, times: null}'));
    });

    test('toString with times', () {
      const repeat = Repeat(
        direction: RepeatDirection.backward,
        times: 3,
      );
      expect(repeat.toString(), equals('Repeat{direction: RepeatDirection.backward, times: 3}'));
    });
  });
}