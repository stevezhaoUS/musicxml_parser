import 'package:musicxml_parser/src/models/barline.dart';
import 'package:musicxml_parser/src/models/repeat.dart';
import 'package:musicxml_parser/src/models/ending.dart';
import 'package:musicxml_parser/src/models/measure.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:test/test.dart';

void main() {
  group('Documentation Examples', () {
    test('basic barline creation works', () {
      // Create a simple barline
      const barline = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.regular,
      );

      expect(barline.location, equals(BarlineLocation.right));
      expect(barline.style, equals(BarlineStyle.regular));
    });

    test('complex barline with repeat and ending works', () {
      // Create a barline with repeat and ending
      final complexBarline = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.lightHeavy,
        repeat: const Repeat(direction: RepeatDirection.backward, times: 2),
        ending: const Ending(number: '1', type: EndingType.start, text: '1st time'),
      );

      expect(complexBarline.location, equals(BarlineLocation.right));
      expect(complexBarline.style, equals(BarlineStyle.lightHeavy));
      expect(complexBarline.repeat?.direction, equals(RepeatDirection.backward));
      expect(complexBarline.repeat?.times, equals(2));
      expect(complexBarline.ending?.number, equals('1'));
      expect(complexBarline.ending?.type, equals(EndingType.start));
      expect(complexBarline.ending?.text, equals('1st time'));
    });

    test('repeat examples work', () {
      // Start repeat (forward)
      const startRepeat = Repeat(direction: RepeatDirection.forward);

      // End repeat (backward) with specific number of times
      const endRepeat = Repeat(direction: RepeatDirection.backward, times: 3);

      expect(startRepeat.direction, equals(RepeatDirection.forward));
      expect(startRepeat.times, isNull);
      expect(endRepeat.direction, equals(RepeatDirection.backward));
      expect(endRepeat.times, equals(3));
    });

    test('ending examples work', () {
      // First ending
      const firstEnding = Ending(
        number: '1',
        type: EndingType.start,
        text: '1st time',
      );

      // Second ending
      const secondEnding = Ending(
        number: '2',
        type: EndingType.stop,
      );

      // Multiple endings (1st and 2nd time)
      const multipleEnding = Ending(
        number: '1,2',
        type: EndingType.start,
        text: '1st, 2nd time',
      );

      expect(firstEnding.number, equals('1'));
      expect(firstEnding.type, equals(EndingType.start));
      expect(firstEnding.text, equals('1st time'));

      expect(secondEnding.number, equals('2'));
      expect(secondEnding.type, equals(EndingType.stop));
      expect(secondEnding.text, isNull);

      expect(multipleEnding.number, equals('1,2'));
      expect(multipleEnding.type, equals(EndingType.start));
      expect(multipleEnding.text, equals('1st, 2nd time'));
    });

    test('measure integration works', () {
      const note = Note(
        pitch: Pitch(step: 'C', octave: 4),
        duration: Duration(value: 480, divisions: 480),
      );

      final measure = Measure(
        number: '1',
        notes: [note],
        barlines: [
          const Barline(
            location: BarlineLocation.right,
            style: BarlineStyle.regular,
          ),
        ],
      );

      expect(measure.barlines.length, equals(1));
      final barline = measure.barlines.first;
      expect(barline.location, equals(BarlineLocation.right));
      expect(barline.style, equals(BarlineStyle.regular));
    });

    test('all barline locations are covered', () {
      // Test all supported barline locations
      final locations = [
        BarlineLocation.left,
        BarlineLocation.right,
        BarlineLocation.middle,
      ];

      expect(locations.length, equals(3));
      expect(BarlineLocation.values, containsAll(locations));
    });

    test('all barline styles are covered', () {
      // Test all supported barline styles
      final styles = [
        BarlineStyle.regular,
        BarlineStyle.lightHeavy,
        BarlineStyle.heavyLight,
        BarlineStyle.lightLight,
        BarlineStyle.heavyHeavy,
        BarlineStyle.dashed,
        BarlineStyle.dotted,
        BarlineStyle.none,
      ];

      expect(styles.length, equals(8));
      expect(BarlineStyle.values, containsAll(styles));
    });

    test('all repeat directions are covered', () {
      // Test all supported repeat directions
      final directions = [
        RepeatDirection.forward,
        RepeatDirection.backward,
      ];

      expect(directions.length, equals(2));
      expect(RepeatDirection.values, containsAll(directions));
    });

    test('all ending types are covered', () {
      // Test all supported ending types
      final types = [
        EndingType.start,
        EndingType.stop,
        EndingType.discontinue,
      ];

      expect(types.length, equals(3));
      expect(EndingType.values, containsAll(types));
    });
  });
}