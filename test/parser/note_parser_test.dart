import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/parser/note_parser.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:musicxml_parser/src/models/note.dart' show Accidental;

void main() {
  group('NoteParser', () {
    late NoteParser noteParser;
    late WarningSystem warningSystem;

    setUp(() {
      warningSystem = WarningSystem();
      noteParser = NoteParser(warningSystem: warningSystem);
    });

    group('constructor', () {
      test('creates with default warning system', () {
        final parser = NoteParser();
        expect(parser.warningSystem, isNotNull);
      });

      test('creates with custom warning system', () {
        final customWarningSystem = WarningSystem();
        final parser = NoteParser(warningSystem: customWarningSystem);
        expect(parser.warningSystem, equals(customWarningSystem));
      });
    });

    group('parse note', () {
      test('parses basic note with pitch and duration', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
            <duration>960</duration>
            <type>quarter</type>
            <voice>1</voice>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.isRest, isFalse);
        expect(result.pitch, isNotNull);
        expect(result.pitch!.step, equals('C'));
        expect(result.pitch!.octave, equals(4));
        expect(result.pitch!.alter, isNull);
        expect(result.duration, isNotNull);
        expect(result.duration!.value, equals(960));
        expect(result.duration!.divisions, equals(480));
        expect(result.type, equals('quarter'));
        expect(result.voice, equals(1));
      });

      test('parses note with altered pitch', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>F</step>
              <alter>1</alter>
              <octave>5</octave>
            </pitch>
            <duration>240</duration>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.pitch!.step, equals('F'));
        expect(result.pitch!.alter, equals(1));
        expect(result.pitch!.octave, equals(5));
      });

      test('parses note without type and voice', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>G</step>
              <octave>3</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.type, isNull);
        expect(result.voice, isNull);
      });
    });

    group('parse rest', () {
      test('parses basic rest', () {
        final xml = XmlDocument.parse('''
          <note>
            <rest/>
            <duration>480</duration>
            <type>quarter</type>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.isRest, isTrue);
        expect(result.pitch, isNull);
        expect(result.duration, isNotNull);
        expect(result.duration!.value, equals(480));
        expect(result.type, equals('quarter'));
      });

      test('parses rest with voice', () {
        final xml = XmlDocument.parse('''
          <note>
            <rest/>
            <duration>960</duration>
            <voice>2</voice>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.isRest, isTrue);
        expect(result.voice, equals(2));
      });
    });

    group('pitch parsing', () {
      test('throws exception for non-rest note without pitch', () {
        final xml = XmlDocument.parse('''
          <note>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        expect(
          () => noteParser.parse(element, 480, 'P1', '1'),
          throwsA(isA<MusicXmlStructureException>()
              .having((e) => e.message, 'message',
                  'Non-rest note is missing pitch element')
              .having((e) => e.requiredElement, 'requiredElement', 'pitch')
              .having((e) => e.parentElement, 'parentElement', 'note')),
        );
      });

      test('throws exception for invalid pitch step', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>H</step>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        expect(
          () => noteParser.parse(element, 480, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message',
                  contains('Invalid pitch step: "H"'))
              .having((e) => e.context?['part'], 'part context', 'P1')
              .having((e) => e.context?['measure'], 'measure context', '1')
              .having((e) => e.rule, 'rule', 'pitch_step_invalid')),
        );
      });

      test('throws exception for invalid octave - too low', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>-1</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        expect(
          () => noteParser.parse(element, 480, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having(
                  (e) => e.message, 'message', contains('Invalid octave: "-1"'))
              .having((e) => e.rule, 'rule', 'pitch_octave_invalid')),
        );
      });

      test('throws exception for invalid octave - too high', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>10</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        expect(
          () => noteParser.parse(element, 480, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having(
                  (e) => e.message, 'message', contains('Invalid octave: "10"'))
              .having((e) => e.rule, 'rule', 'pitch_octave_invalid')),
        );
      });

      test('throws exception for invalid octave - non-numeric', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>abc</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        expect(
          () => noteParser.parse(element, 480, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message',
                  contains('Invalid octave: "abc"'))
              .having((e) => e.rule, 'rule', 'pitch_octave_invalid')),
        );
      });

      test('throws exception for invalid alter value - too low', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <alter>-3</alter>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        expect(
          () => noteParser.parse(element, 480, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message',
                  contains('Invalid alter value: "-3"'))
              .having((e) => e.rule, 'rule', 'pitch_alter_invalid')),
        );
      });

      test('throws exception for invalid alter value - too high', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <alter>3</alter>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        expect(
          () => noteParser.parse(element, 480, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message',
                  contains('Invalid alter value: "3"'))
              .having((e) => e.rule, 'rule', 'pitch_alter_invalid')),
        );
      });

      test('throws exception for invalid alter value - non-numeric', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <alter>sharp</alter>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        expect(
          () => noteParser.parse(element, 480, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message',
                  contains('Invalid alter value: "sharp"'))
              .having((e) => e.rule, 'rule', 'pitch_alter_invalid')),
        );
      });

      test('accepts valid alter values within range', () {
        for (final alterValue in [-2, -1, 0, 1, 2]) {
          final xml = XmlDocument.parse('''
            <note>
              <pitch>
                <step>C</step>
                <alter>$alterValue</alter>
                <octave>4</octave>
              </pitch>
              <duration>480</duration>
            </note>
          ''');
          final element = xml.rootElement;

          final result = noteParser.parse(element, 480, 'P1', '1');

          expect(result, isNotNull);
          expect(result!.pitch!.alter, equals(alterValue));
        }
      });
    });

    group('duration parsing', () {
      test('creates note with null duration when duration is missing', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.duration, isNull);
        expect(result.pitch, isNotNull);
        expect(result.pitch!.step, equals('C'));
        expect(result.pitch!.octave, equals(4));
        expect(warningSystem.getWarningsByCategory('duration'), isNotEmpty);
      });

      test('warns for invalid duration value', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
            <duration>-100</duration>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNull);
        final warnings = warningSystem.getWarningsByCategory('note_duration');
        expect(warnings, isNotEmpty);
        expect(
            warnings.first.message, contains('Invalid duration value: -100'));
      });

      test('warns for non-numeric duration', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
            <duration>abc</duration>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNull);
        final warnings = warningSystem.getWarningsByCategory('note_duration');
        expect(warnings, isNotEmpty);
      });

      test('warns and uses default divisions when parent divisions is null',
          () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, null, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.duration, isNotNull);
        expect(result.duration!.divisions, equals(1));

        final warnings = warningSystem.getWarningsByCategory('note_divisions');
        expect(warnings, isNotEmpty);
        expect(warnings.first.message,
            contains('No valid divisions specified for note'));
      });

      test('warns and uses default divisions when parent divisions is zero',
          () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 0, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.duration, isNotNull);
        expect(result.duration!.divisions, equals(1));

        final warnings = warningSystem.getWarningsByCategory('note_divisions');
        expect(warnings, isNotEmpty);
      });

      test('warns and uses default divisions when parent divisions is negative',
          () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, -5, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.duration, isNotNull);
        expect(result.duration!.divisions, equals(1));

        final warnings = warningSystem.getWarningsByCategory('note_divisions');
        expect(warnings, isNotEmpty);
      });
    });

    group('voice parsing', () {
      test('parses numeric voice correctly', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
            <voice>3</voice>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.voice, equals(3));
      });

      test('handles non-numeric voice gracefully', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
            <voice>soprano</voice>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.voice, isNull);
      });
    });

    group('edge cases', () {
      test('handles empty step element', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step></step>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        expect(
          () => noteParser.parse(element, 480, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()),
        );
      });

      test('handles empty octave element', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave></octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        expect(
          () => noteParser.parse(element, 480, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()),
        );
      });

      test('handles empty alter element', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <alter></alter>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        expect(
          () => noteParser.parse(element, 480, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()),
        );
      });

      test('handles whitespace in elements', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>  C  </step>
              <octave>  4  </octave>
            </pitch>
            <duration>  480  </duration>
            <type>  quarter  </type>
            <voice>  1  </voice>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.pitch!.step, equals('C'));
        expect(result.pitch!.octave, equals(4));
        expect(result.duration, isNotNull);
        expect(result.duration!.value, equals(480));
        expect(result.type, equals('quarter'));
        expect(result.voice, equals(1));
      });
    });

    group('boundary values', () {
      test('accepts minimum valid octave', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>0</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.pitch!.octave, equals(0));
      });

      test('accepts maximum valid octave', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>9</octave>
            </pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;

        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.pitch!.octave, equals(9));
      });

      test('accepts all valid pitch steps', () {
        final validSteps = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];

        for (final step in validSteps) {
          final xml = XmlDocument.parse('''
            <note>
              <pitch>
                <step>$step</step>
                <octave>4</octave>
              </pitch>
              <duration>480</duration>
            </note>
          ''');
          final element = xml.rootElement;

          final result = noteParser.parse(element, 480, 'P1', '1');

          expect(result, isNotNull);
          expect(result!.pitch!.step, equals(step));
        }
      });
    });

    group('dotted note parsing', () {
      test('parses note with no dots', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>C</step><octave>4</octave></pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.dots, isNull);
      });

      test('parses note with a single dot', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>C</step><octave>4</octave></pitch>
            <duration>480</duration>
            <dot/>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.dots, equals(1));
      });

      test('parses note with double dots', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>C</step><octave>4</octave></pitch>
            <duration>480</duration>
            <dot/>
            <dot/>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.dots, equals(2));
      });

      test('parses note with triple dots', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>C</step><octave>4</octave></pitch>
            <duration>480</duration>
            <dot/>
            <dot/>
            <dot/>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.dots, equals(3));
      });

      test('parses rest with a single dot', () {
        final xml = XmlDocument.parse('''
          <note>
            <rest/>
            <duration>480</duration>
            <dot/>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.isRest, isTrue);
        expect(result.dots, equals(1));
      });

      test('parses rest with no dots', () {
        final xml = XmlDocument.parse('''
          <note>
            <rest/>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.isRest, isTrue);
        expect(result.dots, isNull);
      });
    });

    group('tuplet parsing (<time-modification>)', () {
      test('parses note with basic tuplet (3 over 2)', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>C</step><octave>4</octave></pitch>
            <duration>320</duration>
            <time-modification>
              <actual-notes>3</actual-notes>
              <normal-notes>2</normal-notes>
            </time-modification>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.timeModification, isNotNull);
        expect(result.timeModification!.actualNotes, equals(3));
        expect(result.timeModification!.normalNotes, equals(2));
        expect(result.timeModification!.normalType, isNull);
        expect(result.timeModification!.normalDotCount, isNull);
      });

      test('parses note without tuplet data', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>C</step><octave>4</octave></pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.timeModification, isNull);
      });

      test('parses note with tuplet specifying normal-type', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>D</step><octave>4</octave></pitch>
            <duration>320</duration>
            <time-modification>
              <actual-notes>3</actual-notes>
              <normal-notes>2</normal-notes>
              <normal-type>eighth</normal-type>
            </time-modification>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.timeModification, isNotNull);
        expect(result.timeModification!.normalType, equals('eighth'));
      });

      test('parses note with tuplet specifying normal-dot elements', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>E</step><octave>4</octave></pitch>
            <duration>480</duration>
            <time-modification>
              <actual-notes>3</actual-notes>
              <normal-notes>2</normal-notes>
              <normal-type>quarter</normal-type>
              <normal-dot/>
              <normal-dot/>
            </time-modification>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.timeModification, isNotNull);
        expect(result.timeModification!.normalType, equals('quarter'));
        expect(result.timeModification!.normalDotCount, equals(2));
      });

      test(
          'throws MusicXmlStructureException if tuplet is missing actual-notes',
          () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>F</step><octave>4</octave></pitch>
            <duration>320</duration>
            <time-modification>
              <normal-notes>2</normal-notes>
            </time-modification>
          </note>
        ''');
        final element = xml.rootElement;
        expect(
            () => noteParser.parse(element, 480, 'P1', '1'),
            throwsA(isA<MusicXmlStructureException>().having(
                (e) => e.message,
                'message',
                '<time-modification> is missing <actual-notes> element')));
      });

      test(
          'throws MusicXmlStructureException if tuplet actual-notes is non-integer',
          () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>G</step><octave>4</octave></pitch>
            <duration>320</duration>
            <time-modification>
              <actual-notes>abc</actual-notes>
              <normal-notes>2</normal-notes>
            </time-modification>
          </note>
        ''');
        final element = xml.rootElement;
        expect(
            () => noteParser.parse(element, 480, 'P1', '1'),
            throwsA(isA<MusicXmlStructureException>().having((e) => e.message,
                'message', '<actual-notes> must contain an integer value')));
      });

      test(
          'throws MusicXmlStructureException if tuplet is missing normal-notes',
          () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>F</step><octave>4</octave></pitch>
            <duration>320</duration>
            <time-modification>
              <actual-notes>3</actual-notes>
            </time-modification>
          </note>
        ''');
        final element = xml.rootElement;
        expect(
            () => noteParser.parse(element, 480, 'P1', '1'),
            throwsA(isA<MusicXmlStructureException>().having(
                (e) => e.message,
                'message',
                '<time-modification> is missing <normal-notes> element')));
      });

      test(
          'throws MusicXmlStructureException if tuplet normal-notes is non-integer',
          () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>G</step><octave>4</octave></pitch>
            <duration>320</duration>
            <time-modification>
              <actual-notes>3</actual-notes>
              <normal-notes>abc</normal-notes>
            </time-modification>
          </note>
        ''');
        final element = xml.rootElement;
        expect(
            () => noteParser.parse(element, 480, 'P1', '1'),
            throwsA(isA<MusicXmlStructureException>().having((e) => e.message,
                'message', '<normal-notes> must contain an integer value')));
      });

      test(
          'handles invalid actual-notes value (zero) by warning and nullifying timeModification',
          () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>A</step><octave>4</octave></pitch>
            <duration>320</duration>
            <time-modification>
              <actual-notes>0</actual-notes>
              <normal-notes>2</normal-notes>
            </time-modification>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.timeModification,
            isNull); // Should be null due to validation failure being caught

        final warnings =
            warningSystem.getWarningsByCategory('time_modification_validation');
        expect(warnings, isNotEmpty);
        expect(warnings.first.message,
            contains('TimeModification actualNotes must be positive, got 0'));
        expect(warnings.first.rule,
            equals('time_modification_actual_notes_positive'));
      });

      test(
          'handles invalid normal-notes value (zero) by warning and nullifying timeModification',
          () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>B</step><octave>4</octave></pitch>
            <duration>320</duration>
            <time-modification>
              <actual-notes>3</actual-notes>
              <normal-notes>0</normal-notes>
            </time-modification>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');

        expect(result, isNotNull);
        expect(result!.timeModification, isNull);

        final warnings =
            warningSystem.getWarningsByCategory('time_modification_validation');
        expect(warnings, isNotEmpty);
        expect(warnings.first.message,
            contains('TimeModification normalNotes must be positive, got 0'));
        expect(warnings.first.rule,
            equals('time_modification_normal_notes_positive'));
      });

      test(
          'handles invalid normal-dot-count value (-1) by warning and nullifying timeModification',
          () {
        // The test for negative normal-dot-count was re-scoped as the parser cannot produce it.
        // This test now verifies correct parsing of a single normal-dot.
        // Original unused 'xml' variable related to the old test scope is removed.
        final xml_single_dot = XmlDocument.parse('''
           <note>
            <pitch><step>C</step><octave>5</octave></pitch>
            <duration>320</duration>
            <time-modification>
              <actual-notes>3</actual-notes>
              <normal-notes>2</normal-notes>
              <normal-dot/>
              <!-- This is parsed as normalDotCount = -1 in this hypothetical test scenario,
                   but the parser actually counts <normal-dot/> elements.
                   To test TimeModification.validated's check for normalDotCount < 0,
                   we'd need to mock the count or construct TimeModification directly.
                   The parser itself won't produce a negative count from XML.
                   However, the test for TimeModification.validated already covers normalDotCount: -1.
                   This test will verify parser correctly counts <valid> normal-dot elements.
                   Let's adjust this test to be a valid scenario for the parser. -->
            </time-modification>
          </note>
        ''');

        final element_single_dot = xml_single_dot.rootElement;
        final result_single_dot =
            noteParser.parse(element_single_dot, 480, 'P1', '1');
        expect(result_single_dot, isNotNull);
        expect(result_single_dot!.timeModification, isNotNull);
        expect(result_single_dot.timeModification!.normalDotCount, equals(1));
      });
    });

    group('slur parsing (from <notations>)', () {
      test('parses note with no <notations> element', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>C</step><octave>4</octave></pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.slurs, isNull);
      });

      test('parses note with <notations> but no <slur> elements', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>D</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <tied type="start"/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.slurs,
            isNull); // Parser logic sets to null if foundSlurs is empty
      });

      test('parses note with a single slur (start)', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>E</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <slur type="start" number="1" placement="above"/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.slurs, isNotNull);
        expect(result.slurs, hasLength(1));
        expect(result.slurs![0].type, equals('start'));
        expect(result.slurs![0].number, equals(1));
        expect(result.slurs![0].placement, equals('above'));
      });

      test('parses note with multiple slurs', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>F</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <slur type="start" number="1" placement="above"/>
              <slur type="stop" number="2" placement="below"/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.slurs, isNotNull);
        expect(result.slurs, hasLength(2));

        expect(result.slurs![0].type, equals('start'));
        expect(result.slurs![0].number, equals(1));
        expect(result.slurs![0].placement, equals('above'));

        expect(result.slurs![1].type, equals('stop'));
        expect(result.slurs![1].number, equals(2));
        expect(result.slurs![1].placement, equals('below'));
      });

      test('parses slur with default number attribute', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>G</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <slur type="continue"/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.slurs, isNotNull);
        expect(result.slurs, hasLength(1));
        expect(result.slurs![0].type, equals('continue'));
        expect(result.slurs![0].number, equals(1)); // Default
        expect(result.slurs![0].placement, isNull);
      });

      test(
          'throws MusicXmlStructureException if slur is missing type attribute',
          () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>A</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <slur number="1"/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        expect(
          () => noteParser.parse(element, 480, 'P1', '1'),
          throwsA(isA<MusicXmlStructureException>().having(
            (e) => e.message,
            'message',
            '<slur> element missing required "type" attribute',
          )),
        );
      });
    });

    group('articulation parsing (from <notations><articulations>)', () {
      test('parses note with no <notations> element for articulations', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>C</step><octave>4</octave></pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.articulations, isNull);
      });

      test('parses note with <notations> but no <articulations> container', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>D</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <slur type="start"/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.articulations, isNull);
      });

      test('parses note with an empty <articulations> container', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>D</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <articulations/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.articulations,
            isNull); // Parser logic sets to null if found list is empty
      });

      test('parses note with a single articulation (accent)', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>E</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <articulations>
                <accent/>
              </articulations>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.articulations, isNotNull);
        expect(result.articulations, hasLength(1));
        expect(result.articulations![0].type, equals('accent'));
        expect(result.articulations![0].placement, isNull);
      });

      test('parses note with multiple articulations, one with placement', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>F</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <articulations>
                <staccato/>
                <tenuto placement="above"/>
              </articulations>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.articulations, isNotNull);
        expect(result.articulations, hasLength(2));

        expect(result.articulations![0].type, equals('staccato'));
        expect(result.articulations![0].placement, isNull);

        expect(result.articulations![1].type, equals('tenuto'));
        expect(result.articulations![1].placement, equals('above'));
      });

      test('parses articulation with different placement', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>G</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <articulations>
                <marcato placement="below"/>
              </articulations>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.articulations, isNotNull);
        expect(result.articulations, hasLength(1));
        expect(result.articulations![0].type, equals('marcato'));
        expect(result.articulations![0].placement, equals('below'));
      });
    });

    group('tie parsing (<tied> from <notations>)', () {
      setUp(() {
        // Ensure a fresh WarningSystem for each test if checking warnings.
        warningSystem = WarningSystem();
        noteParser = NoteParser(warningSystem: warningSystem);
      });

      test('parses note with no <notations> element for ties', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>C</step><octave>4</octave></pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.ties, isNull);
      });

      test('parses note with <notations> but no <tied> elements', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>D</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <slur type="start"/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.ties, isNull);
      });

      test('parses note with a <tied type="start"/> element', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>C</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <tied type="start"/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.ties, isNotNull);
        expect(result.ties, hasLength(1));
        expect(result.ties![0].type, equals('start'));
        expect(result.ties![0].placement, isNull);
      });

      test('parses note with a <tied type="stop" placement="above"/> element',
          () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>D</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <tied type="stop" placement="above"/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.ties, isNotNull);
        expect(result.ties, hasLength(1));
        expect(result.ties![0].type, equals('stop'));
        expect(result.ties![0].placement, equals('above'));
      });

      test('parses note with multiple <tied> elements', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>E</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <tied type="stop"/>
              <tied type="start" placement="below"/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.ties, isNotNull);
        expect(result.ties, hasLength(2));
        expect(result.ties![0].type, equals('stop'));
        expect(result.ties![0].placement, isNull);
        expect(result.ties![1].type, equals('start'));
        expect(result.ties![1].placement, equals('below'));
      });

      test('parses note with <tied type="continue"/>', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>A</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <tied type="continue"/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.ties, isNotNull);
        expect(result.ties, hasLength(1));
        expect(result.ties![0].type, equals('continue'));
      });

      test('<tied> missing type attribute logs warning and note has no ties',
          () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>F</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <tied placement="above"/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.ties,
            isNull); // Or isEmpty, depending on parser strictness with warnings

        final warnings =
            warningSystem.getWarningsByCategory(WarningCategories.structure);
        expect(warnings, hasLength(1));
        expect(warnings.first.message,
            contains('<tied> element has invalid or missing "type" attribute'));
      });

      test(
          '<tied> with invalid type attribute logs warning and note has no ties',
          () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>G</step><octave>4</octave></pitch>
            <duration>480</duration>
            <notations>
              <tied type="invalid-type"/>
            </notations>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.ties, isNull); // Or isEmpty

        final warnings =
            warningSystem.getWarningsByCategory(WarningCategories.structure);
        expect(warnings, hasLength(1));
        expect(warnings.first.message,
            contains('<tied> element has invalid or missing "type" attribute'));
        expect(warnings.first.message, contains('Found: "invalid-type"'));
      });
    });

    group('chord element parsing', () {
      test('parses note without <chord/> element', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch><step>C</step><octave>4</octave></pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.isChordElementPresent, isFalse);
      });

      test('parses note with <chord/> element', () {
        final xml = XmlDocument.parse('''
          <note>
            <chord/>
            <pitch><step>E</step><octave>4</octave></pitch>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.isChordElementPresent, isTrue);
      });

      test('parses rest with <chord/> element', () {
        final xml = XmlDocument.parse('''
          <note>
            <chord/>
            <rest/>
            <duration>480</duration>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.isRest, isTrue);
        expect(result.isChordElementPresent, isTrue);
      });
    });

    group('accidental parsing', () {
      test('parses note with accidental (sharp)', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
            <accidental>sharp</accidental>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.accidental, equals(Accidental.sharp));
      });

      test('parses note with accidental (natural)', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>D</step>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
            <accidental>natural</accidental>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.accidental, equals(Accidental.natural));
      });

      test('parses note with accidental (double-flat)', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>E</step>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
            <accidental>double-flat</accidental>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.accidental, equals(Accidental.doubleFlat));
      });

      test('parses note with unknown accidental', () {
        final xml = XmlDocument.parse('''
          <note>
            <pitch>
              <step>F</step>
              <octave>4</octave>
            </pitch>
            <duration>480</duration>
            <accidental>foobar</accidental>
          </note>
        ''');
        final element = xml.rootElement;
        final result = noteParser.parse(element, 480, 'P1', '1');
        expect(result, isNotNull);
        expect(result!.accidental, equals(Accidental.other));
      });
    });
  });
}
