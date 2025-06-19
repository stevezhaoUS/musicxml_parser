import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/parser/note_parser.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';

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
              .having((e) => e.message, 'message', 'Invalid pitch step: H')
              .having((e) => e.context?['part'], 'part context', 'P1')
              .having((e) => e.context?['measure'], 'measure context', '1')),
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
              .having((e) => e.message, 'message', 'Invalid octave: -1')),
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
              .having((e) => e.message, 'message', 'Invalid octave: 10')),
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
              .having((e) => e.message, 'message', 'Invalid octave: abc')),
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
              .having((e) => e.message, 'message', 'Invalid alter value: -3')),
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
              .having((e) => e.message, 'message', 'Invalid alter value: 3')),
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
          throwsA(isA<MusicXmlValidationException>().having(
              (e) => e.message, 'message', 'Invalid alter value: sharp')),
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
        expect(result!.duration!.divisions, equals(1));

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
        expect(result!.duration!.divisions, equals(1));

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
        expect(result!.duration!.divisions, equals(1));

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
  });
}
