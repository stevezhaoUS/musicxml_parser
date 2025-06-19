import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/beam.dart';
import 'package:test/test.dart';

void main() {
  group('Beam', () {
    test('should create a valid beam instance', () {
      final beam = Beam(
        number: 1,
        type: 'begin',
        measureNumber: '1',
        noteIndices: [0, 1, 2],
      );

      expect(beam.number, equals(1));
      expect(beam.type, equals('begin'));
      expect(beam.measureNumber, equals('1'));
      expect(beam.noteIndices, equals([0, 1, 2]));
    });

    test('should create a validated beam instance', () {
      final beam = Beam.validated(
        number: 2,
        type: 'continue',
        measureNumber: '2',
        noteIndices: [3, 4],
      );

      expect(beam.number, equals(2));
      expect(beam.type, equals('continue'));
      expect(beam.measureNumber, equals('2'));
      expect(beam.noteIndices, equals([3, 4]));
    });

    test('should throw exception for invalid beam number', () {
      expect(
        () => Beam.validated(
          number: 0,
          type: 'begin',
          measureNumber: '1',
          noteIndices: [0, 1],
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Beam number must be positive'),
        )),
      );

      expect(
        () => Beam.validated(
          number: -1,
          type: 'begin',
          measureNumber: '1',
          noteIndices: [0, 1],
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Beam number must be positive'),
        )),
      );
    });

    test('should throw exception for invalid beam type', () {
      expect(
        () => Beam.validated(
          number: 1,
          type: 'invalid-type',
          measureNumber: '1',
          noteIndices: [0, 1],
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Invalid beam type'),
        )),
      );
    });

    test('should throw exception for empty measure number', () {
      expect(
        () => Beam.validated(
          number: 1,
          type: 'begin',
          measureNumber: '',
          noteIndices: [0, 1],
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Measure number cannot be empty'),
        )),
      );
    });

    test('should throw exception for insufficient note indices', () {
      expect(
        () => Beam.validated(
          number: 1,
          type: 'begin',
          measureNumber: '1',
          noteIndices: [0],
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('A beam must connect at least 2 notes'),
        )),
      );
    });

    test('equality and hashCode should work correctly', () {
      final beam1 = Beam(
        number: 1,
        type: 'begin',
        measureNumber: '1',
        noteIndices: [0, 1],
      );
      final beam2 = Beam(
        number: 1,
        type: 'begin',
        measureNumber: '1',
        noteIndices: [0, 1],
      );
      final beam3 = Beam(
        number: 2,
        type: 'begin',
        measureNumber: '1',
        noteIndices: [0, 1],
      );
      final beam4 = Beam(
        number: 1,
        type: 'end',
        measureNumber: '1',
        noteIndices: [0, 1],
      );
      final beam5 = Beam(
        number: 1,
        type: 'begin',
        measureNumber: '2',
        noteIndices: [0, 1],
      );
      final beam6 = Beam(
        number: 1,
        type: 'begin',
        measureNumber: '1',
        noteIndices: [1, 2],
      );

      expect(beam1, equals(beam2));
      expect(beam1.hashCode, equals(beam2.hashCode));

      expect(beam1, isNot(equals(beam3)));
      expect(beam1, isNot(equals(beam4)));
      expect(beam1, isNot(equals(beam5)));
      expect(beam1, isNot(equals(beam6)));
    });

    test('toString should return correct representation', () {
      final beam = Beam(
        number: 1,
        type: 'begin',
        measureNumber: '1',
        noteIndices: [0, 1, 2],
      );

      expect(
        beam.toString(),
        equals(
          'Beam{number: 1, type: begin, measureNumber: 1, noteIndices: [0, 1, 2]}',
        ),
      );
    });
  });
}
