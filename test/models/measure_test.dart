import 'package:musicxml_parser/src/models/measure.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/models/beam.dart';
import 'package:musicxml_parser/src/models/barline.dart';
import 'package:musicxml_parser/src/models/repeat.dart';
import 'package:musicxml_parser/src/models/ending.dart';
import 'package:test/test.dart';

void main() {
  group('Measure', () {
    test('constructor sets properties correctly', () {
      const pitch = Pitch(step: 'C', octave: 4);
      const duration = Duration(value: 480, divisions: 480);
      const note = Note(pitch: pitch, duration: duration);
      
      const measure = Measure(
        number: '1',
        notes: [note],
      );
      
      expect(measure.number, equals('1'));
      expect(measure.notes, hasLength(1));
      expect(measure.notes.first, equals(note));
      expect(measure.keySignature, isNull);
      expect(measure.timeSignature, isNull);
      expect(measure.width, isNull);
      expect(measure.beams, isEmpty);
      expect(measure.barlines, isEmpty);
    });

    test('constructor with all properties', () {
      const pitch = Pitch(step: 'C', octave: 4);
      const duration = Duration(value: 480, divisions: 480);
      const note = Note(pitch: pitch, duration: duration);
      const keySignature = KeySignature(fifths: 2);
      const timeSignature = TimeSignature(beats: 4, beatType: 4);
      const beam = Beam(
        number: 1, 
        type: 'begin',
        measureNumber: '42',
        noteIndices: [0],
      );
      const barline = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.regular,
      );
      
      const measure = Measure(
        number: '42',
        notes: [note],
        keySignature: keySignature,
        timeSignature: timeSignature,
        width: 150.0,
        beams: [beam],
        barlines: [barline],
      );
      
      expect(measure.number, equals('42'));
      expect(measure.notes, hasLength(1));
      expect(measure.notes.first, equals(note));
      expect(measure.keySignature, equals(keySignature));
      expect(measure.timeSignature, equals(timeSignature));
      expect(measure.width, equals(150.0));
      expect(measure.beams, hasLength(1));
      expect(measure.beams.first, equals(beam));
      expect(measure.barlines, hasLength(1));
      expect(measure.barlines.first, equals(barline));
    });

    test('constructor with multiple barlines', () {
      const note = Note(
        pitch: Pitch(step: 'C', octave: 4),
        duration: Duration(value: 480, divisions: 480),
      );
      
      const startBarline = Barline(
        location: BarlineLocation.left,
        style: BarlineStyle.heavyLight,
        repeat: Repeat(direction: RepeatDirection.forward),
      );
      
      const endBarline = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.lightHeavy,
        repeat: Repeat(direction: RepeatDirection.backward),
        ending: Ending(number: '1', type: EndingType.start),
      );
      
      const measure = Measure(
        number: '1',
        notes: [note],
        barlines: [startBarline, endBarline],
      );
      
      expect(measure.barlines, hasLength(2));
      expect(measure.barlines[0], equals(startBarline));
      expect(measure.barlines[1], equals(endBarline));
    });

    test('equals works correctly', () {
      const note = Note(
        pitch: Pitch(step: 'C', octave: 4),
        duration: Duration(value: 480, divisions: 480),
      );
      
      const measure1 = Measure(
        number: '1',
        notes: [note],
      );
      const measure2 = Measure(
        number: '1',
        notes: [note],
      );
      const measure3 = Measure(
        number: '2',
        notes: [note],
      );

      expect(measure1, equals(measure2));
      expect(measure1, isNot(equals(measure3)));
    });

    test('equals works correctly with barlines', () {
      const note = Note(
        pitch: Pitch(step: 'C', octave: 4),
        duration: Duration(value: 480, divisions: 480),
      );
      const barline = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.regular,
      );
      
      const measure1 = Measure(
        number: '1',
        notes: [note],
        barlines: [barline],
      );
      const measure2 = Measure(
        number: '1',
        notes: [note],
        barlines: [barline],
      );
      const measure3 = Measure(
        number: '1',
        notes: [note],
      );

      expect(measure1, equals(measure2));
      expect(measure1, isNot(equals(measure3)));
    });

    test('hashCode works correctly', () {
      const note = Note(
        pitch: Pitch(step: 'C', octave: 4),
        duration: Duration(value: 480, divisions: 480),
      );
      
      const measure1 = Measure(
        number: '1',
        notes: [note],
      );
      const measure2 = Measure(
        number: '1',
        notes: [note],
      );

      expect(measure1.hashCode, equals(measure2.hashCode));
    });

    test('toString returns correct string representation', () {
      const note = Note(
        pitch: Pitch(step: 'C', octave: 4),
        duration: Duration(value: 480, divisions: 480),
      );
      
      const measure = Measure(
        number: '1',
        notes: [note],
      );
      
      expect(measure.toString(), equals('Measure{number: 1, notes: 1, beams: 0, barlines: 0}'));
    });

    test('toString with barlines', () {
      const note = Note(
        pitch: Pitch(step: 'C', octave: 4),
        duration: Duration(value: 480, divisions: 480),
      );
      const barline = Barline(
        location: BarlineLocation.right,
        style: BarlineStyle.regular,
      );
      
      const measure = Measure(
        number: '42',
        notes: [note],
        barlines: [barline],
      );
      
      expect(measure.toString(), equals('Measure{number: 42, notes: 1, beams: 0, barlines: 1}'));
    });
  });
}