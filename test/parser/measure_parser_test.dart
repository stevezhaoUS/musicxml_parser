import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/parser/attributes_parser.dart';
import 'package:musicxml_parser/src/parser/measure_parser.dart';
import 'package:musicxml_parser/src/parser/note_parser.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';

import 'measure_parser_test.mocks.dart';

@GenerateMocks([NoteParser, AttributesParser])
void main() {
  group('MeasureParser', () {
    late MeasureParser measureParser;
    late MockNoteParser mockNoteParser;
    late MockAttributesParser mockAttributesParser;
    late WarningSystem warningSystem;

    setUp(() {
      mockNoteParser = MockNoteParser();
      mockAttributesParser = MockAttributesParser();
      warningSystem = WarningSystem();
    });

    group('constructor', () {
      test('creates with default dependencies', () {
        final parser = MeasureParser();
        expect(parser.warningSystem, isNotNull);
      });

      test('creates with custom dependencies', () {
        measureParser = MeasureParser(
          noteParser: mockNoteParser,
          attributesParser: mockAttributesParser,
          warningSystem: warningSystem,
        );

        expect(measureParser.warningSystem, equals(warningSystem));
      });

      test('creates default note parser when not provided', () {
        final parser = MeasureParser(
          attributesParser: mockAttributesParser,
          warningSystem: warningSystem,
        );

        expect(parser.warningSystem, equals(warningSystem));
      });

      test('creates default attributes parser when not provided', () {
        final parser = MeasureParser(
          noteParser: mockNoteParser,
          warningSystem: warningSystem,
        );

        expect(parser.warningSystem, equals(warningSystem));
      });
    });

    group('parse', () {
      setUp(() {
        measureParser = MeasureParser(
          noteParser: mockNoteParser,
          attributesParser: mockAttributesParser,
          warningSystem: warningSystem,
        );
      });

      test('parses basic measure with number', () {
        final xml = XmlDocument.parse('<measure number="1"></measure>');
        final element = xml.rootElement;

        final result = measureParser.parse(element, 'P1');

        expect(result.number, equals('1'));
        expect(result.notes, isEmpty);
        expect(result.keySignature, isNull);
        expect(result.timeSignature, isNull);
        expect(result.width, isNull);
      });

      test('parses measure with width attribute', () {
        final xml =
            XmlDocument.parse('<measure number="1" width="120.5"></measure>');
        final element = xml.rootElement;

        final result = measureParser.parse(element, 'P1');

        expect(result.number, equals('1'));
        expect(result.width, equals(120.5));
      });

      test('handles invalid width attribute gracefully', () {
        final xml =
            XmlDocument.parse('<measure number="1" width="invalid"></measure>');
        final element = xml.rootElement;

        final result = measureParser.parse(element, 'P1');

        expect(result.number, equals('1'));
        expect(result.width, isNull);
      });

      test('inherits values from parameters', () {
        final xml = XmlDocument.parse('<measure number="1"></measure>');
        final element = xml.rootElement;

        final keySignature = const KeySignature(fifths: 2);
        final timeSignature = const TimeSignature(beats: 4, beatType: 4);

        final result = measureParser.parse(
          element,
          'P1',
          inheritedDivisions: 480,
          inheritedKeySignature: keySignature,
          inheritedTimeSignature: timeSignature,
        );

        expect(result.keySignature, equals(keySignature));
        expect(result.timeSignature, equals(timeSignature));
      });

      group('validation errors', () {
        test('throws exception for missing measure number', () {
          final xml = XmlDocument.parse('<measure></measure>');
          final element = xml.rootElement;

          expect(
            () => measureParser.parse(element, 'P1'),
            throwsA(isA<MusicXmlValidationException>()
                .having(
                    (e) => e.message, 'message', 'Measure number is required')
                .having((e) => e.context?['part'], 'part context', 'P1')),
          );
        });

        test('throws exception for empty measure number', () {
          final xml = XmlDocument.parse('<measure number=""></measure>');
          final element = xml.rootElement;

          expect(
            () => measureParser.parse(element, 'P1'),
            throwsA(isA<MusicXmlValidationException>().having(
                (e) => e.message, 'message', 'Measure number is required')),
          );
        });

        test('throws exception for invalid measure number (non-numeric)', () {
          final xml = XmlDocument.parse('<measure number="abc"></measure>');
          final element = xml.rootElement;

          expect(
            () => measureParser.parse(element, 'P1'),
            throwsA(isA<MusicXmlValidationException>()
                .having(
                    (e) => e.message, 'message', 'Invalid measure number: abc')
                .having((e) => e.context?['part'], 'part context', 'P1')
                .having(
                    (e) => e.context?['measure'], 'measure context', 'abc')),
          );
        });

        test('throws exception for invalid measure number (zero)', () {
          final xml = XmlDocument.parse('<measure number="0"></measure>');
          final element = xml.rootElement;

          expect(
            () => measureParser.parse(element, 'P1'),
            throwsA(isA<MusicXmlValidationException>().having(
                (e) => e.message, 'message', 'Invalid measure number: 0')),
          );
        });

        test('throws exception for invalid measure number (negative)', () {
          final xml = XmlDocument.parse('<measure number="-1"></measure>');
          final element = xml.rootElement;

          expect(
            () => measureParser.parse(element, 'P1'),
            throwsA(isA<MusicXmlValidationException>().having(
                (e) => e.message, 'message', 'Invalid measure number: -1')),
          );
        });
      });

      group('attributes processing', () {
        test('processes attributes and updates divisions', () {
          final xml = XmlDocument.parse('''
            <measure number="1">
              <attributes>
                <divisions>480</divisions>
              </attributes>
            </measure>
          ''');
          final element = xml.rootElement;

          when(mockAttributesParser.parse(any, any, any, any))
              .thenReturn({'divisions': 480});

          final result = measureParser.parse(element, 'P1');

          expect(result.number, equals('1'));
          verify(mockAttributesParser.parse(any, 'P1', '1', null)).called(1);
        });

        test('processes attributes and updates key signature', () {
          final xml = XmlDocument.parse('''
            <measure number="1">
              <attributes>
                <key>
                  <fifths>2</fifths>
                </key>
              </attributes>
            </measure>
          ''');
          final element = xml.rootElement;
          final keySignature = const KeySignature(fifths: 2);

          when(mockAttributesParser.parse(any, any, any, any))
              .thenReturn({'keySignature': keySignature});

          final result = measureParser.parse(element, 'P1');

          expect(result.keySignature, equals(keySignature));
          verify(mockAttributesParser.parse(any, 'P1', '1', null)).called(1);
        });

        test('processes attributes and updates time signature', () {
          final xml = XmlDocument.parse('''
            <measure number="1">
              <attributes>
                <time>
                  <beats>3</beats>
                  <beat-type>4</beat-type>
                </time>
              </attributes>
            </measure>
          ''');
          final element = xml.rootElement;
          final timeSignature = const TimeSignature(beats: 3, beatType: 4);

          when(mockAttributesParser.parse(any, any, any, any))
              .thenReturn({'timeSignature': timeSignature});

          final result = measureParser.parse(element, 'P1');

          expect(result.timeSignature, equals(timeSignature));
          verify(mockAttributesParser.parse(any, 'P1', '1', null)).called(1);
        });

        test('processes multiple attributes elements', () {
          final xml = XmlDocument.parse('''
            <measure number="1">
              <attributes>
                <divisions>480</divisions>
              </attributes>
              <attributes>
                <key>
                  <fifths>1</fifths>
                </key>
              </attributes>
            </measure>
          ''');
          final element = xml.rootElement;
          final keySignature = const KeySignature(fifths: 1);

          var callCount = 0;
          when(mockAttributesParser.parse(any, any, any, any)).thenAnswer((_) {
            callCount++;
            return callCount == 1
                ? {'divisions': 480}
                : {'keySignature': keySignature};
          });

          final result = measureParser.parse(element, 'P1');

          expect(result.keySignature, equals(keySignature));
          verify(mockAttributesParser.parse(any, 'P1', '1', any)).called(2);
        });

        test('uses inherited divisions in attributes parsing', () {
          final xml = XmlDocument.parse('''
            <measure number="1">
              <attributes>
                <key>
                  <fifths>0</fifths>
                </key>
              </attributes>
            </measure>
          ''');
          final element = xml.rootElement;

          when(mockAttributesParser.parse(any, any, any, any)).thenReturn({});

          measureParser.parse(element, 'P1', inheritedDivisions: 240);

          verify(mockAttributesParser.parse(any, 'P1', '1', 240)).called(1);
        });
      });

      group('note processing', () {
        test('processes notes and adds them to measure', () {
          final xml = XmlDocument.parse('''
            <measure number="1">
              <note>
                <pitch>
                  <step>C</step>
                  <octave>4</octave>
                </pitch>
                <duration>480</duration>
              </note>
            </measure>
          ''');
          final element = xml.rootElement;

          final note = const Note(
            pitch: const Pitch(step: 'C', octave: 4),
            duration: const Duration(value: 480, divisions: 480),
            isRest: false,
          );

          when(mockNoteParser.parse(any, any, any, any)).thenReturn(note);

          final result = measureParser.parse(element, 'P1');

          expect(result.notes, hasLength(1));
          expect(result.notes.first, equals(note));
          verify(mockNoteParser.parse(any, null, 'P1', '1')).called(1);
        });

        test('processes multiple notes', () {
          final xml = XmlDocument.parse('''
            <measure number="1">
              <note>
                <pitch>
                  <step>C</step>
                  <octave>4</octave>
                </pitch>
                <duration>480</duration>
              </note>
              <note>
                <rest/>
                <duration>480</duration>
              </note>
            </measure>
          ''');
          final element = xml.rootElement;

          final note1 = const Note(
            pitch: const Pitch(step: 'C', octave: 4),
            duration: const Duration(value: 480, divisions: 480),
            isRest: false,
          );

          final note2 = const Note(
            pitch: null,
            duration: const Duration(value: 480, divisions: 480),
            isRest: true,
          );

          var callCount = 0;
          when(mockNoteParser.parse(any, any, any, any)).thenAnswer((_) {
            callCount++;
            return callCount == 1 ? note1 : note2;
          });

          final result = measureParser.parse(element, 'P1');

          expect(result.notes, hasLength(2));
          expect(result.notes[0], equals(note1));
          expect(result.notes[1], equals(note2));
          verify(mockNoteParser.parse(any, null, 'P1', '1')).called(2);
        });

        test('filters out null notes', () {
          final xml = XmlDocument.parse('''
            <measure number="1">
              <note>
                <pitch>
                  <step>C</step>
                  <octave>4</octave>
                </pitch>
                <duration>480</duration>
              </note>
              <note>
                <!-- Invalid note that returns null -->
              </note>
            </measure>
          ''');
          final element = xml.rootElement;

          final note = const Note(
            pitch: const Pitch(step: 'C', octave: 4),
            duration: const Duration(value: 480, divisions: 480),
            isRest: false,
          );

          var callCount = 0;
          when(mockNoteParser.parse(any, any, any, any)).thenAnswer((_) {
            callCount++;
            return callCount == 1 ? note : null;
          });

          final result = measureParser.parse(element, 'P1');

          expect(result.notes, hasLength(1));
          expect(result.notes.first, equals(note));
          verify(mockNoteParser.parse(any, null, 'P1', '1')).called(2);
        });

        test('passes divisions to note parser', () {
          final xml = XmlDocument.parse('''
            <measure number="1">
              <attributes>
                <divisions>240</divisions>
              </attributes>
              <note>
                <pitch>
                  <step>C</step>
                  <octave>4</octave>
                </pitch>
                <duration>240</duration>
              </note>
            </measure>
          ''');
          final element = xml.rootElement;

          final note = const Note(
            pitch: const Pitch(step: 'C', octave: 4),
            duration: const Duration(value: 240, divisions: 240),
            isRest: false,
          );

          when(mockAttributesParser.parse(any, any, any, any))
              .thenReturn({'divisions': 240});
          when(mockNoteParser.parse(any, any, any, any)).thenReturn(note);

          measureParser.parse(element, 'P1');

          verify(mockNoteParser.parse(any, 240, 'P1', '1')).called(1);
        });
      });

      group('edge cases', () {
        test('handles empty measure', () {
          final xml = XmlDocument.parse('<measure number="1"></measure>');
          final element = xml.rootElement;

          final result = measureParser.parse(element, 'P1');

          expect(result.number, equals('1'));
          expect(result.notes, isEmpty);
          expect(result.keySignature, isNull);
          expect(result.timeSignature, isNull);
        });

        test('ignores unknown child elements', () {
          final xml = XmlDocument.parse('''
            <measure number="1">
              <unknown-element>Some content</unknown-element>
              <another-unknown/>
            </measure>
          ''');
          final element = xml.rootElement;

          final result = measureParser.parse(element, 'P1');

          expect(result.number, equals('1'));
          expect(result.notes, isEmpty);
          // Should not throw any exceptions
        });

        test(
            'handles mixed content with attributes, notes, and unknown elements',
            () {
          final xml = XmlDocument.parse('''
            <measure number="1">
              <unknown-element/>
              <attributes>
                <divisions>480</divisions>
              </attributes>
              <note>
                <pitch>
                  <step>C</step>
                  <octave>4</octave>
                </pitch>
                <duration>480</duration>
              </note>
              <direction>
                <direction-type>
                  <dynamics>
                    <f/>
                  </dynamics>
                </direction-type>
              </direction>
            </measure>
          ''');
          final element = xml.rootElement;

          final note = const Note(
            pitch: const Pitch(step: 'C', octave: 4),
            duration: const Duration(value: 480, divisions: 480),
            isRest: false,
          );

          when(mockAttributesParser.parse(any, any, any, any))
              .thenReturn({'divisions': 480});
          when(mockNoteParser.parse(any, any, any, any)).thenReturn(note);

          final result = measureParser.parse(element, 'P1');

          expect(result.number, equals('1'));
          expect(result.notes, hasLength(1));
          expect(result.notes.first, equals(note));
          verify(mockAttributesParser.parse(any, 'P1', '1', null)).called(1);
          verify(mockNoteParser.parse(any, 480, 'P1', '1')).called(1);
        });
      });

      group('complex scenarios', () {
        test('processes measure with all elements and inheritance', () {
          final xml = XmlDocument.parse('''
            <measure number="42" width="150.0">
              <attributes>
                <divisions>960</divisions>
                <key>
                  <fifths>3</fifths>
                </key>
                <time>
                  <beats>6</beats>
                  <beat-type>8</beat-type>
                </time>
              </attributes>
              <note>
                <pitch>
                  <step>A</step>
                  <octave>4</octave>
                </pitch>
                <duration>480</duration>
              </note>
              <note>
                <rest/>
                <duration>480</duration>
              </note>
            </measure>
          ''');
          final element = xml.rootElement;

          final inheritedKey = const KeySignature(fifths: 1);
          final inheritedTime = const TimeSignature(beats: 4, beatType: 4);
          final newKey = const KeySignature(fifths: 3);
          final newTime = const TimeSignature(beats: 6, beatType: 8);

          final note1 = const Note(
            pitch: const Pitch(step: 'A', octave: 4),
            duration: const Duration(value: 480, divisions: 960),
            isRest: false,
          );

          final note2 = const Note(
            pitch: null,
            duration: const Duration(value: 480, divisions: 960),
            isRest: true,
          );

          when(mockAttributesParser.parse(any, any, any, any)).thenReturn({
            'divisions': 960,
            'keySignature': newKey,
            'timeSignature': newTime,
          });

          var callCount = 0;
          when(mockNoteParser.parse(any, any, any, any)).thenAnswer((_) {
            callCount++;
            return callCount == 1 ? note1 : note2;
          });

          final result = measureParser.parse(
            element,
            'P1',
            inheritedDivisions: 480,
            inheritedKeySignature: inheritedKey,
            inheritedTimeSignature: inheritedTime,
          );

          expect(result.number, equals('42'));
          expect(result.width, equals(150.0));
          expect(result.notes, hasLength(2));
          expect(
              result.keySignature, equals(newKey)); // Updated from attributes
          expect(
              result.timeSignature, equals(newTime)); // Updated from attributes

          verify(mockAttributesParser.parse(any, 'P1', '42', 480)).called(1);
          verify(mockNoteParser.parse(any, 960, 'P1', '42')).called(2);
        });
      });
    });
  });
}
