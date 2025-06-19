import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:musicxml_parser/src/parser/attributes_parser.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_parse_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';

void main() {
  group('AttributesParser', () {
    late AttributesParser parser;
    late WarningSystem warningSystem;

    setUp(() {
      warningSystem = WarningSystem();
      parser = AttributesParser(warningSystem: warningSystem);
    });

    group('constructor', () {
      test('creates parser with custom warning system', () {
        expect(parser.warningSystem, equals(warningSystem));
      });

      test('creates parser with default warning system', () {
        final defaultParser = AttributesParser();
        expect(defaultParser.warningSystem, isNotNull);
        expect(defaultParser.warningSystem, isNot(equals(warningSystem)));
      });
    });

    group('parse method', () {
      test('parses empty attributes element', () {
        const xmlStr = '<attributes></attributes>';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', null);

        expect(result, isA<Map<String, dynamic>>());
        expect(result['divisions'], isNull);
        expect(result['keySignature'], isNull);
        expect(result['timeSignature'], isNull);
      });

      test('preserves current divisions when no divisions element present', () {
        const xmlStr = '<attributes></attributes>';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', 480);

        expect(result['divisions'], equals(480));
        expect(result['keySignature'], isNull);
        expect(result['timeSignature'], isNull);
      });

      test('parses valid divisions element', () {
        const xmlStr = '''
          <attributes>
            <divisions>480</divisions>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', null);

        expect(result['divisions'], equals(480));
        expect(result['keySignature'], isNull);
        expect(result['timeSignature'], isNull);
      });

      test('parses valid key signature element', () {
        const xmlStr = '''
          <attributes>
            <key>
              <fifths>2</fifths>
              <mode>major</mode>
            </key>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', null);

        expect(result['divisions'], isNull);
        expect(result['keySignature'], isA<KeySignature>());
        expect((result['keySignature'] as KeySignature).fifths, equals(2));
        expect((result['keySignature'] as KeySignature).mode, equals('major'));
        expect(result['timeSignature'], isNull);
      });

      test('parses valid time signature element', () {
        const xmlStr = '''
          <attributes>
            <time>
              <beats>4</beats>
              <beat-type>4</beat-type>
            </time>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', null);

        expect(result['divisions'], isNull);
        expect(result['keySignature'], isNull);
        expect(result['timeSignature'], isA<TimeSignature>());
        expect((result['timeSignature'] as TimeSignature).beats, equals(4));
        expect((result['timeSignature'] as TimeSignature).beatType, equals(4));
      });

      test('parses all attributes together', () {
        const xmlStr = '''
          <attributes>
            <divisions>240</divisions>
            <key>
              <fifths>-1</fifths>
              <mode>minor</mode>
            </key>
            <time>
              <beats>3</beats>
              <beat-type>8</beat-type>
            </time>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', null);

        expect(result['divisions'], equals(240));
        expect(result['keySignature'], isA<KeySignature>());
        expect((result['keySignature'] as KeySignature).fifths, equals(-1));
        expect((result['keySignature'] as KeySignature).mode, equals('minor'));
        expect(result['timeSignature'], isA<TimeSignature>());
        expect((result['timeSignature'] as TimeSignature).beats, equals(3));
        expect((result['timeSignature'] as TimeSignature).beatType, equals(8));
      });

      test('throws MusicXmlParseException for invalid divisions text', () {
        const xmlStr = '''
          <attributes>
            <divisions>invalid</divisions>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlParseException>()
              .having((e) => e.message, 'message',
                  contains('Invalid divisions value "invalid"'))
              .having((e) => e.element, 'element', 'divisions')
              .having((e) => e.context, 'context', contains('part'))
              .having((e) => e.context, 'context', contains('measure'))),
        );
      });

      test('throws MusicXmlValidationException for zero divisions', () {
        const xmlStr = '''
          <attributes>
            <divisions>0</divisions>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message',
                  contains('Divisions value must be positive, got 0'))
              .having((e) => e.rule, 'rule', 'divisions_positive_validation')
              .having((e) => e.context, 'context', contains('divisions'))),
        );
      });

      test('throws MusicXmlValidationException for negative divisions', () {
        const xmlStr = '''
          <attributes>
            <divisions>-100</divisions>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message',
                  contains('Divisions value must be positive, got -100'))
              .having((e) => e.rule, 'rule', 'divisions_positive_validation')),
        );
      });
    });

    group('key signature parsing', () {
      test('parses key signature with fifths only', () {
        const xmlStr = '''
          <attributes>
            <key>
              <fifths>3</fifths>
            </key>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', null);

        expect(result['keySignature'], isA<KeySignature>());
        expect((result['keySignature'] as KeySignature).fifths, equals(3));
        expect((result['keySignature'] as KeySignature).mode, isNull);
      });

      test('parses key signature with negative fifths', () {
        const xmlStr = '''
          <attributes>
            <key>
              <fifths>-5</fifths>
              <mode>major</mode>
            </key>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', null);

        expect(result['keySignature'], isA<KeySignature>());
        expect((result['keySignature'] as KeySignature).fifths, equals(-5));
        expect((result['keySignature'] as KeySignature).mode, equals('major'));
      });

      test('throws MusicXmlValidationException for missing fifths', () {
        const xmlStr = '''
          <attributes>
            <key>
              <mode>major</mode>
            </key>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message',
                  contains('Invalid key signature fifths value: null'))
              .having((e) => e.context, 'context', contains('part'))
              .having((e) => e.context, 'context', contains('measure'))),
        );
      });

      test('throws MusicXmlValidationException for invalid fifths text', () {
        const xmlStr = '''
          <attributes>
            <key>
              <fifths>invalid</fifths>
            </key>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlValidationException>().having(
              (e) => e.message,
              'message',
              contains('Invalid key signature fifths value: invalid'))),
        );
      });

      test('throws validation error for fifths out of range', () {
        const xmlStr = '''
          <attributes>
            <key>
              <fifths>10</fifths>
            </key>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlValidationException>()),
        );
      });
    });

    group('time signature parsing', () {
      test('parses valid time signature', () {
        const xmlStr = '''
          <attributes>
            <time>
              <beats>6</beats>
              <beat-type>8</beat-type>
            </time>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', null);

        expect(result['timeSignature'], isA<TimeSignature>());
        expect((result['timeSignature'] as TimeSignature).beats, equals(6));
        expect((result['timeSignature'] as TimeSignature).beatType, equals(8));
      });

      test('throws MusicXmlValidationException for missing beats', () {
        const xmlStr = '''
          <attributes>
            <time>
              <beat-type>4</beat-type>
            </time>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlValidationException>()
              .having(
                  (e) => e.message,
                  'message',
                  contains(
                      'Invalid time signature beats (numerator) value: null'))
              .having((e) => e.context, 'context', contains('part'))
              .having((e) => e.context, 'context', contains('measure'))),
        );
      });

      test('throws MusicXmlValidationException for invalid beats text', () {
        const xmlStr = '''
          <attributes>
            <time>
              <beats>invalid</beats>
              <beat-type>4</beat-type>
            </time>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlValidationException>().having(
              (e) => e.message,
              'message',
              contains(
                  'Invalid time signature beats (numerator) value: invalid'))),
        );
      });

      test('throws MusicXmlValidationException for zero beats', () {
        const xmlStr = '''
          <attributes>
            <time>
              <beats>0</beats>
              <beat-type>4</beat-type>
            </time>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlValidationException>().having(
              (e) => e.message,
              'message',
              contains('Invalid time signature beats (numerator) value: 0'))),
        );
      });

      test('throws MusicXmlValidationException for negative beats', () {
        const xmlStr = '''
          <attributes>
            <time>
              <beats>-2</beats>
              <beat-type>4</beat-type>
            </time>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlValidationException>().having(
              (e) => e.message,
              'message',
              contains('Invalid time signature beats (numerator) value: -2'))),
        );
      });

      test('throws MusicXmlValidationException for missing beat-type', () {
        const xmlStr = '''
          <attributes>
            <time>
              <beats>4</beats>
            </time>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlValidationException>().having(
              (e) => e.message,
              'message',
              contains(
                  'Invalid time signature beat-type (denominator) value: null'))),
        );
      });

      test('throws MusicXmlValidationException for invalid beat-type text', () {
        const xmlStr = '''
          <attributes>
            <time>
              <beats>4</beats>
              <beat-type>invalid</beat-type>
            </time>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlValidationException>().having(
              (e) => e.message,
              'message',
              contains(
                  'Invalid time signature beat-type (denominator) value: invalid'))),
        );
      });

      test('throws MusicXmlValidationException for zero beat-type', () {
        const xmlStr = '''
          <attributes>
            <time>
              <beats>4</beats>
              <beat-type>0</beat-type>
            </time>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlValidationException>().having(
              (e) => e.message,
              'message',
              contains(
                  'Invalid time signature beat-type (denominator) value: 0'))),
        );
      });

      test('throws validation error for non-power-of-2 beat-type', () {
        const xmlStr = '''
          <attributes>
            <time>
              <beats>4</beats>
              <beat-type>3</beat-type>
            </time>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'P1', '1', null),
          throwsA(isA<MusicXmlValidationException>().having(
              (e) => e.rule, 'rule', 'time_signature_beat_type_validation')),
        );
      });
    });

    group('edge cases and boundary conditions', () {
      test('handles whitespace in divisions element', () {
        const xmlStr = '''
          <attributes>
            <divisions>  240  </divisions>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', null);

        expect(result['divisions'], equals(240));
      });

      test('handles whitespace in key signature elements', () {
        const xmlStr = '''
          <attributes>
            <key>
              <fifths>  2  </fifths>
              <mode>  major  </mode>
            </key>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', null);

        expect(result['keySignature'], isA<KeySignature>());
        expect((result['keySignature'] as KeySignature).fifths, equals(2));
        expect((result['keySignature'] as KeySignature).mode, equals('major'));
      });

      test('handles whitespace in time signature elements', () {
        const xmlStr = '''
          <attributes>
            <time>
              <beats>  4  </beats>
              <beat-type>  4  </beat-type>
            </time>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', null);

        expect(result['timeSignature'], isA<TimeSignature>());
        expect((result['timeSignature'] as TimeSignature).beats, equals(4));
        expect((result['timeSignature'] as TimeSignature).beatType, equals(4));
      });

      test('handles maximum valid divisions value', () {
        const xmlStr = '''
          <attributes>
            <divisions>1440</divisions>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', null);

        expect(result['divisions'], equals(1440));
      });

      test('handles boundary values for key signature fifths', () {
        const xmlStr = '''
          <attributes>
            <key>
              <fifths>7</fifths>
            </key>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        final result = parser.parse(element, 'P1', '1', null);

        expect(result['keySignature'], isA<KeySignature>());
        expect((result['keySignature'] as KeySignature).fifths, equals(7));
      });

      test('handles various valid beat types (powers of 2)', () {
        final beatTypes = [1, 2, 4, 8, 16, 32];

        for (final beatType in beatTypes) {
          final xmlStr = '''
            <attributes>
              <time>
                <beats>4</beats>
                <beat-type>$beatType</beat-type>
              </time>
            </attributes>
          ''';
          final element = XmlDocument.parse(xmlStr).rootElement;

          final result = parser.parse(element, 'P1', '1', null);

          expect(result['timeSignature'], isA<TimeSignature>());
          expect((result['timeSignature'] as TimeSignature).beatType,
              equals(beatType));
        }
      });

      test('maintains context information in all error messages', () {
        const xmlStr = '''
          <attributes>
            <divisions>invalid</divisions>
          </attributes>
        ''';
        final element = XmlDocument.parse(xmlStr).rootElement;

        expect(
          () => parser.parse(element, 'TestPart', '42', null),
          throwsA(isA<MusicXmlParseException>()
              .having((e) => e.context!['part'], 'part', 'TestPart')
              .having((e) => e.context!['measure'], 'measure', '42')),
        );
      });
    });
  });
}
