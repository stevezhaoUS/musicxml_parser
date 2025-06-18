import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:test/test.dart';

void main() {
  group('Pitch', () {
    test('constructor sets properties correctly', () {
      const pitch = Pitch(step: 'C', octave: 4, alter: 1);
      expect(pitch.step, equals('C'));
      expect(pitch.octave, equals(4));
      expect(pitch.alter, equals(1));
    });

    test('equals works correctly', () {
      const pitch1 = Pitch(step: 'C', octave: 4, alter: 1);
      const pitch2 = Pitch(step: 'C', octave: 4, alter: 1);
      const pitch3 = Pitch(step: 'D', octave: 4, alter: 1);

      expect(pitch1, equals(pitch2));
      expect(pitch1, isNot(equals(pitch3)));
    });

    test('toString returns correct string representation', () {
      const pitch = Pitch(step: 'C', octave: 4, alter: 1);
      expect(pitch.toString(), equals('Pitch{step: C, octave: 4, alter: 1}'));
    });
  });
}
