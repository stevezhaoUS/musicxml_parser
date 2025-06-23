import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart'; // Added for backup/forward tests
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/clef.dart';
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/models/direction.dart'; // Added for Direction model
import 'package:musicxml_parser/src/models/direction_type_elements.dart'; // Added for Segno, Coda, Dynamics
import 'package:musicxml_parser/src/models/direction_words.dart'; // Corrected import for WordsDirection
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

      // Default behavior for mockAttributesParser to avoid null issues on 'clefs'
      when(mockAttributesParser.parse(any, any, any, any)).thenReturn({
        'divisions': 1, // Default divisions
        // Ensure 'clefs' is handled, even if it's null or an empty list by default
        // 'clefs': <Clef>[], // Example if you want to default to an empty list
      });
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
         // Reset specific mock behaviors for each test if necessary
        when(mockAttributesParser.parse(any, any, any, any)).thenReturn({
            'divisions': 1, // Default divisions
        });
        when(mockNoteParser.parse(any,any,any,any)).thenReturn(null); // Default no notes
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
        expect(result.clefs, isNull);
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
        final clefs = [const Clef(sign: 'G', line: 2)];


        final result = measureParser.parse(
          element,
          'P1',
          inheritedDivisions: 480,
          inheritedKeySignature: keySignature,
          inheritedTimeSignature: timeSignature,
          inheritedClefs: clefs,
        );

        expect(result.keySignature, equals(keySignature));
        expect(result.timeSignature, equals(timeSignature));
        expect(result.clefs, equals(clefs));
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
              .thenReturn({'keySignature': keySignature, 'divisions': 1});

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
              .thenReturn({'timeSignature': timeSignature, 'divisions': 1});

          final result = measureParser.parse(element, 'P1');

          expect(result.timeSignature, equals(timeSignature));
          verify(mockAttributesParser.parse(any, 'P1', '1', null)).called(1);
        });

        test('processes attributes and updates clefs', () {
          final xml = XmlDocument.parse('''
            <measure number="1">
              <attributes>
                <clef><sign>G</sign><line>2</line></clef>
              </attributes>
            </measure>
          ''');
          final element = xml.rootElement;
          final clefs = [const Clef(sign: 'G', line: 2)];

          when(mockAttributesParser.parse(any, any, any, any))
              .thenReturn({'clefs': clefs, 'divisions': 1});

          final result = measureParser.parse(element, 'P1');

          expect(result.clefs, equals(clefs));
          verify(mockAttributesParser.parse(any, 'P1', '1', null)).called(1);
        });

        test('overrides inherited clef with new clef from attributes', () {
          final inheritedClefs = [const Clef(sign: 'F', line: 4, number: 1)];
          final newClefs = [const Clef(sign: 'G', line: 2, number: 1)];
          final xml = XmlDocument.parse('''
            <measure number="1">
              <attributes>
                <clef number="1"><sign>G</sign><line>2</line></clef>
              </attributes>
            </measure>
          ''');
          final element = xml.rootElement;

          when(mockAttributesParser.parse(any, any, any, any))
              .thenReturn({'clefs': newClefs, 'divisions': 1});

          final result = measureParser.parse(
            element,
            'P1',
            inheritedClefs: inheritedClefs
          );

          expect(result.clefs, isNotNull);
          expect(result.clefs, equals(newClefs));
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
                : {'keySignature': keySignature, 'divisions': 480};
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

          when(mockAttributesParser.parse(any, any, any, 240)).thenReturn({'divisions': 240});

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
            duration: const Duration(value: 480, divisions: 1), // Assuming default divisions 1 from mock
            isRest: false,
          );

          // Ensure attributes parser returns some divisions
          when(mockAttributesParser.parse(any, any, any, any)).thenReturn({'divisions': 1});
          when(mockNoteParser.parse(any, 1, 'P1', '1')).thenReturn(note);


          final result = measureParser.parse(element, 'P1');

          expect(result.notes, hasLength(1));
          expect(result.notes.first, equals(note));
          verify(mockNoteParser.parse(any, 1, 'P1', '1')).called(1);
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
            duration: const Duration(value: 480, divisions: 1),
            isRest: false,
          );

          final note2 = const Note(
            pitch: null,
            duration: const Duration(value: 480, divisions: 1),
            isRest: true,
          );

          when(mockAttributesParser.parse(any, any, any, any)).thenReturn({'divisions': 1});
          var callCount = 0;
          when(mockNoteParser.parse(any, 1, 'P1', '1')).thenAnswer((_) {
            callCount++;
            return callCount == 1 ? note1 : note2;
          });

          final result = measureParser.parse(element, 'P1');

          expect(result.notes, hasLength(2));
          expect(result.notes[0], equals(note1));
          expect(result.notes[1], equals(note2));
          verify(mockNoteParser.parse(any, 1, 'P1', '1')).called(2);
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
            duration: const Duration(value: 480, divisions: 1),
            isRest: false,
          );

          when(mockAttributesParser.parse(any, any, any, any)).thenReturn({'divisions': 1});
          var callCount = 0;
          when(mockNoteParser.parse(any, 1, 'P1', '1')).thenAnswer((_) {
            callCount++;
            return callCount == 1 ? note : null;
          });

          final result = measureParser.parse(element, 'P1');

          expect(result.notes, hasLength(1));
          expect(result.notes.first, equals(note));
          verify(mockNoteParser.parse(any, 1, 'P1', '1')).called(2);
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
          when(mockNoteParser.parse(any, 240, 'P1', '1')).thenReturn(note);

          measureParser.parse(element, 'P1');

          verify(mockNoteParser.parse(any, 240, 'P1', '1')).called(1);
        });
      });

      group('edge cases', () {
        test('handles empty measure', () {
          final xml = XmlDocument.parse('<measure number="1"></measure>');
          final element = xml.rootElement;
          // Ensure mockAttributesParser.parse returns a map that includes 'divisions'
          when(mockAttributesParser.parse(any, any, any, any)).thenReturn({'divisions': null});


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
          when(mockAttributesParser.parse(any, any, any, any)).thenReturn({'divisions': null});


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
          when(mockNoteParser.parse(any, 480, 'P1', '1')).thenReturn(note);

          final result = measureParser.parse(element, 'P1');

          expect(result.number, equals('1'));
          expect(result.notes, hasLength(1));
          expect(result.notes.first, equals(note));
          verify(mockAttributesParser.parse(any, 'P1', '1', null)).called(1);
          verify(mockNoteParser.parse(any, 480, 'P1', '1')).called(1);
        });
      });

      group('complex scenarios', () {
        test('processes measure with all elements and inheritance including clef', () {
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
                <clef number="1"><sign>G</sign><line>2</line></clef>
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
          final inheritedClefs = [const Clef(sign: 'F', line: 4, number: 1)];
          final newKey = const KeySignature(fifths: 3);
          final newTime = const TimeSignature(beats: 6, beatType: 8);
          final newClefs = [const Clef(sign: 'G', line: 2, number: 1)];


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
            'clefs': newClefs,
          });

          var callCount = 0;
          when(mockNoteParser.parse(any, 960, 'P1', '42')).thenAnswer((_) {
            callCount++;
            return callCount == 1 ? note1 : note2;
          });

          final result = measureParser.parse(
            element,
            'P1',
            inheritedDivisions: 480,
            inheritedKeySignature: inheritedKey,
            inheritedTimeSignature: inheritedTime,
            inheritedClefs: inheritedClefs,
          );

          expect(result.number, equals('42'));
          expect(result.width, equals(150.0));
          expect(result.notes, hasLength(2));
          expect(result.keySignature, equals(newKey));
          expect(result.timeSignature, equals(newTime));
          expect(result.clefs, equals(newClefs));


          verify(mockAttributesParser.parse(any, 'P1', '42', 480)).called(1);
          verify(mockNoteParser.parse(any, 960, 'P1', '42')).called(2);
        });
      });
    });

    group('backup and forward parsing', () {
      setUp(() {
        warningSystem = WarningSystem();
        mockNoteParser = MockNoteParser();
        mockAttributesParser = MockAttributesParser();

        measureParser = MeasureParser(
          noteParser: mockNoteParser,
          attributesParser: mockAttributesParser,
          warningSystem: warningSystem,
        );

        when(mockAttributesParser.parse(any, any, any, any)).thenReturn({
          'divisions': 1
        });
        when(mockNoteParser.parse(any, any, any, any)).thenAnswer((invocation) {
          final argElement = invocation.positionalArguments[0] as XmlElement;
          final pitchElement = argElement.findElements('pitch').firstOrNull;
          if (pitchElement != null) {
            final step =
                pitchElement.findElements('step').firstOrNull?.innerText;
            final octave = int.tryParse(
                pitchElement.findElements('octave').firstOrNull?.innerText ??
                    "4");
            return Note(
                pitch: Pitch(step: step ?? 'C', octave: octave ?? 4),
                duration: Duration(value: 1, divisions: 1),
                isRest: false);
          } else if (argElement.findElements('rest').isNotEmpty) {
            return Note(
                duration: Duration(value: 1, divisions: 1), isRest: true);
          }
          return null;
        });
      });

      test('parses measure with <backup> element and logs warning', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <attributes><divisions>1</divisions></attributes>
            <note><pitch><step>C</step><octave>4</octave></pitch><duration>4</duration></note>
            <backup><duration>2</duration></backup>
            <note><pitch><step>D</step><octave>4</octave></pitch><duration>2</duration></note>
          </measure>
        ''');
        final element = xml.rootElement;

        final result = measureParser.parse(element, 'P1');

        expect(result.notes, hasLength(2));
        expect(result.notes[0].pitch!.step, 'C');
        expect(result.notes[1].pitch!.step, 'D');

        final warnings =
            warningSystem.getWarningsByCategory('partial_processing');
        expect(warnings, hasLength(1));
        expect(warnings.first.message,
            contains('Encountered <backup> with duration 2'));
        expect(warnings.first.context?['element'], 'backup');
        expect(warnings.first.context?['duration'], 2);
      });

      test('parses measure with <forward> element and logs warning', () {
        final xml = XmlDocument.parse('''
          <measure number="2">
            <attributes><divisions>1</divisions></attributes>
            <note><pitch><step>E</step><octave>4</octave></pitch><duration>2</duration></note>
            <forward><duration>2</duration></forward>
            <note><pitch><step>F</step><octave>4</octave></pitch><duration>2</duration></note>
          </measure>
        ''');
        final element = xml.rootElement;

        final result = measureParser.parse(element, 'P1');

        expect(result.notes, hasLength(2));
        expect(result.notes[0].pitch!.step, 'E');
        expect(result.notes[1].pitch!.step, 'F');

        final warnings =
            warningSystem.getWarningsByCategory('partial_processing');
        expect(warnings, hasLength(1));
        expect(warnings.first.message,
            contains('Encountered <forward> with duration 2'));
        expect(warnings.first.context?['element'], 'forward');
        expect(warnings.first.context?['duration'], 2);
      });

      test('<backup> missing <duration> throws MusicXmlStructureException', () {
        final xml = XmlDocument.parse('''
          <measure number="3">
            <attributes><divisions>1</divisions></attributes>
            <backup></backup>
          </measure>
        ''');
        final element = xml.rootElement;

        expect(
            () => measureParser.parse(element, 'P1'),
            throwsA(isA<MusicXmlStructureException>().having(
                (e) => e.message,
                'message',
                contains(
                    '<backup> element missing required <duration> child.'))));
      });

      test(
          '<forward> with invalid <duration> (non-integer) throws MusicXmlStructureException',
          () {
        final xml = XmlDocument.parse('''
          <measure number="4">
            <attributes><divisions>1</divisions></attributes>
            <forward><duration>abc</duration></forward>
          </measure>
        ''');
        final element = xml.rootElement;

        expect(
            () => measureParser.parse(element, 'P1'),
            throwsA(isA<MusicXmlStructureException>().having(
                (e) => e.message,
                'message',
                'Invalid or missing duration value for <forward>.')));
      });

      test(
          '<backup> with negative <duration> throws MusicXmlStructureException',
          () {
        final xml = XmlDocument.parse('''
          <measure number="5">
            <attributes><divisions>1</divisions></attributes>
            <backup><duration>-1</duration></backup>
          </measure>
        ''');
        final element = xml.rootElement;

        expect(
            () => measureParser.parse(element, 'P1'),
            throwsA(isA<MusicXmlStructureException>().having((e) => e.message,
                'message', 'Invalid or missing duration value for <backup>.')));
      });
      test('<forward> with zero <duration> is allowed and logs warning', () {
        final xml = XmlDocument.parse('''
          <measure number="6">
            <attributes><divisions>1</divisions></attributes>
            <forward><duration>0</duration></forward>
          </measure>
        ''');
        final element = xml.rootElement;

        final result = measureParser.parse(element, 'P1');
        expect(result.notes, isEmpty);

        final warnings =
            warningSystem.getWarningsByCategory('partial_processing');
        expect(warnings, hasLength(1));
        expect(warnings.first.message,
            contains('Encountered <forward> with duration 0'));
        expect(warnings.first.context?['element'], 'forward');
        expect(warnings.first.context?['duration'], 0);
      });
    });

    group('barline and ending parsing', () {
      setUp(() {
        warningSystem = WarningSystem();
        mockNoteParser = MockNoteParser();
        mockAttributesParser = MockAttributesParser();
        measureParser = MeasureParser(
            noteParser: mockNoteParser,
            attributesParser: mockAttributesParser,
            warningSystem: warningSystem);

        when(mockAttributesParser.parse(any, any, any, any))
            .thenReturn({'divisions': 1});
        when(mockNoteParser.parse(any, any, any, any)).thenAnswer(
            (_) => null);
      });

      test('parses measure with no explicit barlines or endings', () {
        final xml = XmlDocument.parse(
            '<measure number="1"><note><duration>4</duration></note></measure>');
        when(mockNoteParser.parse(any, any, any, any)).thenReturn(
            Note(duration: Duration(value: 4, divisions: 1), isRest: true));
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.barlines, isNull);
        expect(result.ending, isNull);
      });

      test('parses simple barline', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <barline location="right">
              <bar-style>light-heavy</bar-style>
            </barline>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.barlines, isNotNull);
        expect(result.barlines, hasLength(1));
        expect(result.barlines![0].location, 'right');
        expect(result.barlines![0].barStyle, 'light-heavy');
        expect(result.barlines![0].repeatDirection, isNull);
        expect(result.barlines![0].times, isNull);
      });

      test('parses forward repeat barline', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <barline location="right">
              <bar-style>heavy-light</bar-style>
              <repeat direction="forward"/>
            </barline>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.barlines, isNotNull);
        expect(result.barlines, hasLength(1));
        expect(result.barlines![0].barStyle, 'heavy-light');
        expect(result.barlines![0].repeatDirection, 'forward');
      });

      test('parses backward repeat barline with times', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <barline location="left">
              <repeat direction="backward" times="2"/>
            </barline>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.barlines, isNotNull);
        expect(result.barlines, hasLength(1));
        expect(result.barlines![0].location, 'left');
        expect(result.barlines![0].repeatDirection, 'backward');
        expect(result.barlines![0].times, 2);
      });

      test('parses multiple barlines', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <barline location="left"><bar-style>heavy-light</bar-style><repeat direction="forward"/></barline>
            <note><pitch><step>C</step><octave>4</octave></pitch><duration>4</duration></note>
            <barline location="right"><bar-style>light-heavy</bar-style><repeat direction="backward"/></barline>
          </measure>
        ''');
        when(mockNoteParser.parse(any, any, any, any)).thenReturn(Note(
            pitch: Pitch(step: 'C', octave: 4),
            duration: Duration(value: 4, divisions: 1),
            isRest: false));
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.barlines, isNotNull);
        expect(result.barlines, hasLength(2));
        expect(result.barlines![0].location, 'left');
        expect(result.barlines![0].repeatDirection, 'forward');
        expect(result.barlines![1].location, 'right');
        expect(result.barlines![1].repeatDirection, 'backward');
      });

      test('parses ending with attributes (MusicXML 3.0+ style)', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <ending number="1" type="start" print-object="no"/>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.ending, isNotNull);
        expect(result.ending!.number, '1');
        expect(result.ending!.type, 'start');
        expect(result.ending!.printObject, 'no');
      });

      test('parses ending with text number (MusicXML 2.0 style)', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <ending type="stop">2</ending>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.ending, isNotNull);
        expect(result.ending!.number, '2');
        expect(result.ending!.type, 'stop');
        expect(result.ending!.printObject, 'yes'); // Default
      });

      test('parses ending with default print-object', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <ending number="1,3" type="discontinue"/>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.ending, isNotNull);
        expect(result.ending!.number, '1,3');
        expect(result.ending!.type, 'discontinue');
        expect(result.ending!.printObject, 'yes');
      });

      test('handles invalid ending (missing type), logs warning', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <ending number="1"/>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.ending, isNull);
        final warnings =
            warningSystem.getWarningsByCategory(WarningCategories.structure);
        expect(warnings, hasLength(1));
        expect(warnings.first.message, contains('Incomplete <ending> element'));
      });

      test('handles invalid ending (missing number), logs warning', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <ending type="start"/>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.ending, isNull);
        final warnings =
            warningSystem.getWarningsByCategory(WarningCategories.structure);
        expect(warnings, hasLength(1));
        expect(warnings.first.message, contains('Incomplete <ending> element'));
      });
    });

    group('words direction parsing', () {
      setUp(() {
        warningSystem = WarningSystem();
        mockNoteParser = MockNoteParser();
        mockAttributesParser = MockAttributesParser();
        measureParser = MeasureParser(
            noteParser: mockNoteParser,
            attributesParser: mockAttributesParser,
            warningSystem: warningSystem);

        when(mockAttributesParser.parse(any, any, any, any))
            .thenReturn({'divisions': 1});
        when(mockNoteParser.parse(any, any, any, any)).thenAnswer((_) => null);
      });

      test('parses direction with single words element', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction>
              <direction-type>
                <words>Allegro</words>
              </direction-type>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, hasLength(1));
        expect(result.directions[0].directionTypes, hasLength(1));
        expect(result.directions[0].directionTypes[0], isA<WordsDirection>());
        expect((result.directions[0].directionTypes[0] as WordsDirection).text, 'Allegro');
      });

      test(
          'parses direction with multiple words elements in one direction-type',
          () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction>
              <direction-type>
                <words>Vivace</words>
                <words>assai</words>
              </direction-type>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, hasLength(1));
        expect(result.directions[0].directionTypes, hasLength(2));
        expect(result.directions[0].directionTypes[0], isA<WordsDirection>());
        expect((result.directions[0].directionTypes[0] as WordsDirection).text, 'Vivace');
        expect(result.directions[0].directionTypes[1], isA<WordsDirection>());
        expect((result.directions[0].directionTypes[1] as WordsDirection).text, 'assai');
      });

      test('parses multiple direction elements with words', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction>
              <direction-type>
                <words>Andante</words>
              </direction-type>
            </direction>
            <note><duration>4</duration></note>
            <direction>
              <direction-type>
                <words>Fine</words>
              </direction-type>
            </direction>
          </measure>
        ''');
        when(mockNoteParser.parse(any, any, any, any)).thenReturn(
            Note(duration: Duration(value: 4, divisions: 1), isRest: true));
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, hasLength(2));
        expect(result.directions[0].directionTypes, hasLength(1));
        expect((result.directions[0].directionTypes[0] as WordsDirection).text, 'Andante');
        expect(result.directions[1].directionTypes, hasLength(1));
        expect((result.directions[1].directionTypes[0] as WordsDirection).text, 'Fine');
      });

      test('handles empty words element and logs warning, processes valid one', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction>
              <direction-type>
                <words></words>
              </direction-type>
            </direction>
            <direction>
              <direction-type>
                <words>Non-empty</words>
              </direction-type>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');

        expect(result.directions, isA<List<Direction>>(), reason: "result.directions should be List<Direction>");
        expect(result.directions.length, 2, reason: "Should parse two <direction> elements into Measure.directions. Actual: ${result.directions.length}");

        if (result.directions.length == 2) {
          expect(result.directions[0], isA<Direction>(), reason: "First element in Measure.directions should be a Direction object");
          expect(result.directions[0].directionTypes, isNotEmpty, reason: "First Direction object should have directionTypes");
          if (result.directions[0].directionTypes.isNotEmpty) {
            expect(result.directions[0].directionTypes[0], isA<WordsDirection>(), reason: "First Direction's type should be WordsDirection");
            expect((result.directions[0].directionTypes[0] as WordsDirection).text, isEmpty, reason: "First WordsDirection should have empty text");
          }

          expect(result.directions[1], isA<Direction>(), reason: "Second element in Measure.directions should be a Direction object");
          expect(result.directions[1].directionTypes, isNotEmpty, reason: "Second Direction object should have directionTypes");
          if (result.directions[1].directionTypes.isNotEmpty) {
            expect(result.directions[1].directionTypes[0], isA<WordsDirection>(), reason: "Second Direction's type should be WordsDirection");
            expect((result.directions[1].directionTypes[0] as WordsDirection).text, 'Non-empty', reason: "Second WordsDirection should have 'Non-empty' text");
          }
        }

        final validDirections = result.directions.where((d) => d.directionTypes.any((dt) => dt is WordsDirection && (dt as WordsDirection).text.isNotEmpty)).toList();
        expect(validDirections, hasLength(1), reason: "validDirections should filter to 1 item containing the 'Non-empty' direction. Actual length: ${validDirections.length}");

        final warnings =
            warningSystem.getWarningsByCategory(WarningCategories.structure);
        expect(warnings, hasLength(1), reason: "Should have exactly one warning for the empty <words> element. Actual warnings count: ${warnings.length}. Warnings: ${warnings.map((w)=>w.message).toList()}");
        if (warnings.isNotEmpty) {
          expect(warnings.first.message, contains('Empty <words> element'));
        }
      });

      test('ignores direction without words element, parses one with words', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction>
              <direction-type>
                <dynamics><f/></dynamics>
              </direction-type>
            </direction>
            <direction>
              <direction-type>
                <words>Tempo</words>
              </direction-type>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        final wordsDirections = result.directions
            .expand((d) => d.directionTypes)
            .whereType<WordsDirection>()
            .toList();
        expect(wordsDirections, hasLength(1));
        expect(wordsDirections[0].text, 'Tempo');
      });

      test('parses words mixed with other measure elements', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <attributes><divisions>1</divisions></attributes>
            <direction>
              <direction-type>
                <words>Largo</words>
              </direction-type>
            </direction>
            <note><pitch><step>C</step><octave>4</octave></pitch><duration>4</duration></note>
            <barline location="right"><bar-style>light-heavy</bar-style></barline>
            <direction>
              <direction-type>
                <words>rit.</words>
              </direction-type>
            </direction>
          </measure>
        ''');
        when(mockNoteParser.parse(any, any, any, any)).thenReturn(Note(
            pitch: Pitch(step: 'C', octave: 4),
            duration: Duration(value: 4, divisions: 1),
            isRest: false));
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');

        final allWords = result.directions.expand((d) => d.directionTypes).whereType<WordsDirection>().toList();
        expect(allWords, hasLength(2));
        expect(allWords[0].text, 'Largo');
        expect(allWords[1].text, 'rit.');
        expect(result.notes, hasLength(1));
        expect(result.barlines, isNotNull);
        expect(result.barlines, hasLength(1));
      });

      test(
          'parses words within multiple direction-type elements in one direction',
          () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction>
              <direction-type>
                <words>Slow</words>
              </direction-type>
              <direction-type>
                <words> جدا </words>
              </direction-type>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, hasLength(1));
        expect(result.directions[0].directionTypes, hasLength(2));
        expect((result.directions[0].directionTypes[0] as WordsDirection).text, 'Slow');
        expect((result.directions[0].directionTypes[1] as WordsDirection).text, 'جدا');
      });

      test('parses words with various text content including spaces', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction>
              <direction-type>
                <words>  Tempo  Primo  </words>
              </direction-type>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, hasLength(1));
        expect(result.directions[0].directionTypes, hasLength(1));
        expect((result.directions[0].directionTypes[0] as WordsDirection).text,
            'Tempo  Primo');
      });
    });

    group('print object parsing', () {
      setUp(() {
        warningSystem = WarningSystem();
        mockNoteParser = MockNoteParser();
        mockAttributesParser = MockAttributesParser();
        measureParser = MeasureParser(
            noteParser: mockNoteParser,
            attributesParser: mockAttributesParser,
            warningSystem: warningSystem);

        when(mockAttributesParser.parse(any, any, any, any))
            .thenReturn({'divisions': 1});
        when(mockNoteParser.parse(any, any, any, any)).thenReturn(null);
      });

      test('parses print element with new-page and new-system attributes', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <print new-page="yes" new-system="yes" page-number="2" blank-page="1"/>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');

        expect(result.printObject, isNotNull);
        expect(result.printObject!.newPage, isTrue);
        expect(result.printObject!.newSystem, isTrue);
        expect(result.printObject!.pageNumber, "2");
        expect(result.printObject!.blankPage, 1);
      });

      test('parses print element with local page-layout', () {
        final xml = XmlDocument.parse('''
          <measure number="2">
            <print new-page="yes">
              <page-layout>
                <page-height>1500</page-height>
                <page-width>1100</page-width>
              </page-layout>
            </print>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');

        expect(result.printObject, isNotNull);
        expect(result.printObject!.newPage, isTrue);
        expect(result.printObject!.localPageLayout, isNotNull);
        expect(result.printObject!.localPageLayout!.pageHeight, 1500);
        expect(result.printObject!.localPageLayout!.pageWidth, 1100);
      });

      test('parses print element with local system-layout', () {
        final xml = XmlDocument.parse('''
          <measure number="3">
            <print new-system="yes">
              <system-layout>
                <system-margins><left-margin>70</left-margin></system-margins>
                <system-distance>100</system-distance>
              </system-layout>
            </print>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');

        expect(result.printObject, isNotNull);
        expect(result.printObject!.newSystem, isTrue);
        expect(result.printObject!.localSystemLayout, isNotNull);
        expect(result.printObject!.localSystemLayout!.systemMargins!.leftMargin,
            70);
        expect(result.printObject!.localSystemLayout!.systemDistance, 100);
      });

      test('parses print element with local staff-layouts', () {
        final xml = XmlDocument.parse('''
          <measure number="4">
            <print>
              <staff-layout number="1"><staff-distance>90</staff-distance></staff-layout>
              <staff-layout number="2"><staff-distance>85</staff-distance></staff-layout>
            </print>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');

        expect(result.printObject, isNotNull);
        expect(result.printObject!.localStaffLayouts, hasLength(2));
        expect(result.printObject!.localStaffLayouts[0].staffNumber, 1);
        expect(result.printObject!.localStaffLayouts[0].staffDistance, 90);
        expect(result.printObject!.localStaffLayouts[1].staffNumber, 2);
        expect(result.printObject!.localStaffLayouts[1].staffDistance, 85);
      });

      test('parses measure with no print element', () {
        final xml = XmlDocument.parse('<measure number="5"></measure>');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.printObject, isNull);
      });

      test('parses empty print element', () {
        final xml = XmlDocument.parse('<measure number="6"><print/></measure>');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');

        expect(result.printObject, isNotNull);
        expect(result.printObject!.newPage, isFalse);
        expect(result.printObject!.newSystem, isFalse);
        expect(result.printObject!.localPageLayout, isNull);
        expect(result.printObject!.localSystemLayout, isNull);
        expect(result.printObject!.localStaffLayouts, isEmpty);
      });

      test(
          'parses print element with mixed content (attributes and local layouts)',
          () {
        final xmlString = '''
        <measure number="7">
          <print new-page="yes" new-system="no">
            <page-layout><page-width>1000</page-width></page-layout>
            <staff-layout number="1"><staff-distance>75</staff-distance></staff-layout>
          </print>
          <note><rest/><duration>4</duration></note>
        </measure>
        ''';
        when(mockNoteParser.parse(any, any, any, any)).thenReturn(
            Note(duration: Duration(value: 4, divisions: 1), isRest: true));
        final element = XmlDocument.parse(xmlString).rootElement;
        final result = measureParser.parse(element, 'P1');

        expect(result.printObject, isNotNull);
        expect(result.printObject!.newPage, isTrue);
        expect(result.printObject!.newSystem, isFalse);
        expect(result.printObject!.localPageLayout, isNotNull);
        expect(result.printObject!.localPageLayout!.pageWidth, 1000);
        expect(result.printObject!.localSystemLayout, isNull);
        expect(result.printObject!.localStaffLayouts, hasLength(1));
        expect(result.printObject!.localStaffLayouts[0].staffDistance, 75);
        expect(result.notes, hasLength(1));
      });
    });

    group('Direction element parsing', () {
      setUp(() {
        warningSystem = WarningSystem();
        mockNoteParser = MockNoteParser();
        mockAttributesParser = MockAttributesParser();
        measureParser = MeasureParser(
            noteParser: mockNoteParser,
            attributesParser: mockAttributesParser,
            warningSystem: warningSystem);

        when(mockAttributesParser.parse(any, any, any, any))
            .thenReturn({'divisions': 1});
        when(mockNoteParser.parse(any, any, any, any)).thenReturn(null);
      });

      test('parses direction with Segno element', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction>
              <direction-type>
                <segno smufl="segnoSmufl" default-x="10" color="#FF0000"/>
              </direction-type>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, hasLength(1));
        final direction = result.directions[0];
        expect(direction.directionTypes, hasLength(1));
        final segno = direction.directionTypes[0] as Segno;
        expect(segno.smufl, 'segnoSmufl');
        expect(segno.defaultX, 10);
        expect(segno.color, '#FF0000');
      });

      test('parses direction with Coda element and direction attributes', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction placement="above" id="dir-coda1">
              <direction-type>
                <coda font-family="Arial" font-size="12" relative-y="-5"/>
              </direction-type>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, hasLength(1));
        final direction = result.directions[0];
        expect(direction.placement, 'above');
        expect(direction.id, 'dir-coda1');
        expect(direction.directionTypes, hasLength(1));
        final coda = direction.directionTypes[0] as Coda;
        expect(coda.fontFamily, 'Arial');
        expect(coda.fontSize, '12');
        expect(coda.relativeY, -5);
      });

      test('parses direction with Dynamics element (single value)', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction>
              <direction-type>
                <dynamics placement="below" default-y="20">
                  <f/>
                </dynamics>
              </direction-type>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, hasLength(1));
        final direction = result.directions[0];
        expect(direction.directionTypes, hasLength(1));
        final dynamics = direction.directionTypes[0] as Dynamics;
        expect(dynamics.values, equals(['f']));
        expect(dynamics.placement, 'below');
        expect(dynamics.defaultY, 20);
      });

      test('parses direction with Offset element', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction>
              <direction-type><words>Offset Text</words></direction-type>
              <offset sound="yes">120.5</offset>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, hasLength(1));
        final direction = result.directions[0];
        expect(direction.offset, isNotNull);
        expect(direction.offset!.value, 120.5);
        expect(direction.offset!.sound, isTrue);
        expect(direction.directionTypes, hasLength(1));
        expect((direction.directionTypes[0] as WordsDirection).text, 'Offset Text');
      });

      test('parses direction with Staff element', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction>
              <direction-type><words>Staff Text</words></direction-type>
              <staff>2</staff>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, hasLength(1));
        final direction = result.directions[0];
        expect(direction.staff, isNotNull);
        expect(direction.staff!.value, 2);
      });

      test('parses direction with Sound element', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction>
              <direction-type><words>Sound Text</words></direction-type>
              <sound tempo="120" dynamics="80" pizzicato="yes"/>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, hasLength(1));
        final direction = result.directions[0];
        expect(direction.sound, isNotNull);
        expect(direction.sound!.tempo, 120);
        expect(direction.sound!.dynamics, 80);
        expect(direction.sound!.pizzicato, isTrue);
      });

      test('parses direction with all optional elements (offset, staff, sound) and attributes', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction placement="below" directive="yes" system="other" id="dir-full">
              <direction-type>
                <words>Full Direction</words>
              </direction-type>
              <direction-type>
                <segno smufl="segnoIcon"/>
              </direction-type>
              <offset>240</offset>
              <staff>1</staff>
              <sound tempo="90" fine="Fine Text"/>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, hasLength(1));
        final direction = result.directions[0];

        expect(direction.placement, 'below');
        expect(direction.directive, 'yes');
        expect(direction.system, 'other');
        expect(direction.id, 'dir-full');

        expect(direction.directionTypes, hasLength(2));
        expect((direction.directionTypes[0] as WordsDirection).text, 'Full Direction');
        expect((direction.directionTypes[1] as Segno).smufl, 'segnoIcon');

        expect(direction.offset, isNotNull);
        expect(direction.offset!.value, 240);
        expect(direction.offset!.sound, isFalse);

        expect(direction.staff, isNotNull);
        expect(direction.staff!.value, 1);

        expect(direction.sound, isNotNull);
        expect(direction.sound!.tempo, 90);
        expect(direction.sound!.fine, 'Fine Text');
      });

      test('returns null for direction with no direction-type and logs warning', () {
          final xml = XmlDocument.parse('''
          <measure number="1">
            <direction>
              <offset>100</offset>
            </direction>
          </measure>
        ''');
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, isEmpty);

        final warnings = warningSystem.getWarningsByCategory(WarningCategories.structure);
        expect(warnings, hasLength(1));
        expect(warnings.first.message, contains('Direction element without any <direction-type> children. Skipping this direction.'));
      });

      test('parses multiple direction elements with various contents', () {
        final xml = XmlDocument.parse('''
          <measure number="1">
            <direction id="d1">
              <direction-type><words>First</words></direction-type>
              <staff>1</staff>
            </direction>
            <note><rest/><duration>4</duration></note>
            <direction id="d2">
              <direction-type><dynamics><p/></dynamics></direction-type>
              <sound tempo="60"/>
            </direction>
             <direction id="d3">
              <direction-type><segno/></direction-type>
              <offset>10</offset>
            </direction>
          </measure>
        ''');
         when(mockNoteParser.parse(any, any, any, any)).thenReturn(
            Note(duration: Duration(value: 4, divisions: 1), isRest: true));
        final element = xml.rootElement;
        final result = measureParser.parse(element, 'P1');
        expect(result.directions, hasLength(3));

        final dir1 = result.directions[0];
        expect(dir1.id, 'd1');
        expect(dir1.directionTypes, hasLength(1));
        expect((dir1.directionTypes[0] as WordsDirection).text, 'First');
        expect(dir1.staff?.value, 1);
        expect(dir1.offset, isNull);
        expect(dir1.sound, isNull);

        final dir2 = result.directions[1];
        expect(dir2.id, 'd2');
        expect(dir2.directionTypes, hasLength(1));
        expect((dir2.directionTypes[0] as Dynamics).values, equals(['p']));
        expect(dir2.sound?.tempo, 60);
        expect(dir2.staff, isNull);
        expect(dir2.offset, isNull);

        final dir3 = result.directions[2];
        expect(dir3.id, 'd3');
        expect(dir3.directionTypes, hasLength(1));
        expect(dir3.directionTypes[0], isA<Segno>());
        expect(dir3.offset?.value, 10);
        expect(dir3.staff, isNull);
        expect(dir3.sound, isNull);
      });
    });
  });
}
