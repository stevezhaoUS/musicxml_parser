import 'package:musicxml_parser/src/utils/musicxml_utils.dart';
import 'package:test/test.dart';

void main() {
  group('MusicXML Utils', () {
    test('toMidiNote converts pitch correctly', () {
      // Middle C (C4)
      expect(toMidiNote('C', 4), equals(60));

      // C4 sharp
      expect(toMidiNote('C', 4, 1), equals(61));

      // C4 flat
      expect(toMidiNote('C', 4, -1), equals(59));

      // A4 (concert pitch 440Hz)
      expect(toMidiNote('A', 4), equals(69));

      // Lower and higher octaves
      expect(toMidiNote('C', 0), equals(12));
      expect(toMidiNote('C', 8), equals(108));
    });

    test('fromMidiNote converts correctly with sharps', () {
      // Middle C (C4)
      final c4 = fromMidiNote(60);
      expect(c4['step'], equals('C'));
      expect(c4['octave'], equals(4));
      expect(c4['alter'], equals(0));

      // C#4 / Db4
      final cSharp4 = fromMidiNote(61);
      expect(cSharp4['step'], equals('C'));
      expect(cSharp4['octave'], equals(4));
      expect(cSharp4['alter'], equals(1));

      // Concert A (A4)
      final a4 = fromMidiNote(69);
      expect(a4['step'], equals('A'));
      expect(a4['octave'], equals(4));
      expect(a4['alter'], equals(0));
    });

    test('fromMidiNote converts correctly with flats', () {
      // Using flats instead of sharps
      final dFlat4 = fromMidiNote(61, useFlats: true);
      expect(dFlat4['step'], equals('D'));
      expect(dFlat4['octave'], equals(4));
      expect(dFlat4['alter'], equals(-1));

      final bFlat4 = fromMidiNote(70, useFlats: true);
      expect(bFlat4['step'], equals('B'));
      expect(bFlat4['octave'], equals(4));
      expect(bFlat4['alter'], equals(-1));
    });

    test('calculateDurationInSeconds works correctly', () {
      // Quarter note at 60 BPM = 1 second
      expect(calculateDurationInSeconds(1, 1), equals(1.0));

      // Quarter note at 120 BPM = 0.5 seconds
      expect(calculateDurationInSeconds(1, 1, tempo: 120.0), equals(0.5));

      // Half note at 60 BPM = 2 seconds
      expect(calculateDurationInSeconds(2, 1), equals(2.0));

      // Eighth note at 60 BPM = 0.5 seconds
      expect(calculateDurationInSeconds(1, 2), equals(0.5));
    });

    test('toMidiNote throws ArgumentError for invalid step', () {
      expect(() => toMidiNote('H', 4), throwsArgumentError);
    });
  });
}
