import 'package:musicxml_parser/src/parser/barline_parser.dart';
import 'package:musicxml_parser/src/models/barline.dart';
import 'package:musicxml_parser/src/models/repeat.dart';
import 'package:musicxml_parser/src/models/ending.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('BarlineParser', () {
    late BarlineParser parser;

    setUp(() {
      parser = const BarlineParser();
    });

    group('parse', () {
      test('parses simple barline with location and style', () {
        final xml = XmlDocument.parse('''
          <barline location="right">
            <bar-style>regular</bar-style>
          </barline>
        ''');
        final element = xml.rootElement;

        final result = parser.parse(element, 'P1', '1');

        expect(result.location, equals(BarlineLocation.right));
        expect(result.style, equals(BarlineStyle.regular));
        expect(result.repeat, isNull);
        expect(result.ending, isNull);
      });

      test('parses barline with default style when not specified', () {
        final xml = XmlDocument.parse('''
          <barline location="left">
          </barline>
        ''');
        final element = xml.rootElement;

        final result = parser.parse(element, 'P1', '1');

        expect(result.location, equals(BarlineLocation.left));
        expect(result.style, equals(BarlineStyle.regular));
      });

      test('parses all barline locations', () {
        for (final location in ['left', 'right', 'middle']) {
          final xml = XmlDocument.parse('''
            <barline location="$location">
            </barline>
          ''');
          final element = xml.rootElement;

          final result = parser.parse(element, 'P1', '1');

          final expectedLocation = location == 'left'
              ? BarlineLocation.left
              : location == 'right'
                  ? BarlineLocation.right
                  : BarlineLocation.middle;
          expect(result.location, equals(expectedLocation));
        }
      });

      test('parses all barline styles', () {
        final styleMap = {
          'regular': BarlineStyle.regular,
          'light-heavy': BarlineStyle.lightHeavy,
          'heavy-light': BarlineStyle.heavyLight,
          'light-light': BarlineStyle.lightLight,
          'heavy-heavy': BarlineStyle.heavyHeavy,
          'dashed': BarlineStyle.dashed,
          'dotted': BarlineStyle.dotted,
          'none': BarlineStyle.none,
        };

        for (final entry in styleMap.entries) {
          final xml = XmlDocument.parse('''
            <barline location="right">
              <bar-style>${entry.key}</bar-style>
            </barline>
          ''');
          final element = xml.rootElement;

          final result = parser.parse(element, 'P1', '1');

          expect(result.style, equals(entry.value));
        }
      });

      test('parses barline with repeat', () {
        final xml = XmlDocument.parse('''
          <barline location="right">
            <bar-style>light-heavy</bar-style>
            <repeat direction="backward" times="2"/>
          </barline>
        ''');
        final element = xml.rootElement;

        final result = parser.parse(element, 'P1', '1');

        expect(result.location, equals(BarlineLocation.right));
        expect(result.style, equals(BarlineStyle.lightHeavy));
        expect(result.repeat, isNotNull);
        expect(result.repeat!.direction, equals(RepeatDirection.backward));
        expect(result.repeat!.times, equals(2));
      });

      test('parses barline with repeat without times', () {
        final xml = XmlDocument.parse('''
          <barline location="left">
            <bar-style>heavy-light</bar-style>
            <repeat direction="forward"/>
          </barline>
        ''');
        final element = xml.rootElement;

        final result = parser.parse(element, 'P1', '1');

        expect(result.repeat, isNotNull);
        expect(result.repeat!.direction, equals(RepeatDirection.forward));
        expect(result.repeat!.times, isNull);
      });

      test('parses barline with ending', () {
        final xml = XmlDocument.parse('''
          <barline location="right">
            <ending number="1" type="start">1.</ending>
          </barline>
        ''');
        final element = xml.rootElement;

        final result = parser.parse(element, 'P1', '1');

        expect(result.ending, isNotNull);
        expect(result.ending!.number, equals('1'));
        expect(result.ending!.type, equals(EndingType.start));
        expect(result.ending!.text, equals('1.'));
      });

      test('parses barline with ending without text', () {
        final xml = XmlDocument.parse('''
          <barline location="right">
            <ending number="2" type="stop"></ending>
          </barline>
        ''');
        final element = xml.rootElement;

        final result = parser.parse(element, 'P1', '1');

        expect(result.ending, isNotNull);
        expect(result.ending!.number, equals('2'));
        expect(result.ending!.type, equals(EndingType.stop));
        expect(result.ending!.text, isNull);
      });

      test('parses barline with both repeat and ending', () {
        final xml = XmlDocument.parse('''
          <barline location="right">
            <bar-style>light-heavy</bar-style>
            <repeat direction="backward"/>
            <ending number="1,2" type="discontinue">1st, 2nd time</ending>
          </barline>
        ''');
        final element = xml.rootElement;

        final result = parser.parse(element, 'P1', '1');

        expect(result.location, equals(BarlineLocation.right));
        expect(result.style, equals(BarlineStyle.lightHeavy));
        expect(result.repeat, isNotNull);
        expect(result.repeat!.direction, equals(RepeatDirection.backward));
        expect(result.ending, isNotNull);
        expect(result.ending!.number, equals('1,2'));
        expect(result.ending!.type, equals(EndingType.discontinue));
        expect(result.ending!.text, equals('1st, 2nd time'));
      });
    });

    group('validation errors', () {
      test('throws exception for missing location', () {
        final xml = XmlDocument.parse('''
          <barline>
            <bar-style>regular</bar-style>
          </barline>
        ''');
        final element = xml.rootElement;

        expect(
          () => parser.parse(element, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message', 'Barline location is required')
              .having((e) => e.context?['part'], 'part context', 'P1')
              .having((e) => e.context?['measure'], 'measure context', '1')),
        );
      });

      test('throws exception for invalid location', () {
        final xml = XmlDocument.parse('''
          <barline location="invalid">
          </barline>
        ''');
        final element = xml.rootElement;

        expect(
          () => parser.parse(element, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message', 'Invalid barline location: invalid')
              .having((e) => e.context?['location'], 'location context', 'invalid')),
        );
      });

      test('throws exception for invalid style', () {
        final xml = XmlDocument.parse('''
          <barline location="right">
            <bar-style>invalid-style</bar-style>
          </barline>
        ''');
        final element = xml.rootElement;

        expect(
          () => parser.parse(element, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message', 'Invalid barline style: invalid-style')
              .having((e) => e.context?['style'], 'style context', 'invalid-style')),
        );
      });

      test('throws exception for repeat without direction', () {
        final xml = XmlDocument.parse('''
          <barline location="right">
            <repeat times="2"/>
          </barline>
        ''');
        final element = xml.rootElement;

        expect(
          () => parser.parse(element, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message', 'Repeat direction is required')),
        );
      });

      test('throws exception for invalid repeat direction', () {
        final xml = XmlDocument.parse('''
          <barline location="right">
            <repeat direction="invalid"/>
          </barline>
        ''');
        final element = xml.rootElement;

        expect(
          () => parser.parse(element, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message', 'Invalid repeat direction: invalid')
              .having((e) => e.context?['direction'], 'direction context', 'invalid')),
        );
      });

      test('throws exception for invalid repeat times', () {
        final xml = XmlDocument.parse('''
          <barline location="right">
            <repeat direction="backward" times="0"/>
          </barline>
        ''');
        final element = xml.rootElement;

        expect(
          () => parser.parse(element, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message', 'Invalid repeat times: 0')
              .having((e) => e.context?['times'], 'times context', '0')),
        );
      });

      test('throws exception for ending without number', () {
        final xml = XmlDocument.parse('''
          <barline location="right">
            <ending type="start"/>
          </barline>
        ''');
        final element = xml.rootElement;

        expect(
          () => parser.parse(element, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message', 'Ending number is required')),
        );
      });

      test('throws exception for ending without type', () {
        final xml = XmlDocument.parse('''
          <barline location="right">
            <ending number="1"/>
          </barline>
        ''');
        final element = xml.rootElement;

        expect(
          () => parser.parse(element, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message', 'Ending type is required')),
        );
      });

      test('throws exception for invalid ending type', () {
        final xml = XmlDocument.parse('''
          <barline location="right">
            <ending number="1" type="invalid"/>
          </barline>
        ''');
        final element = xml.rootElement;

        expect(
          () => parser.parse(element, 'P1', '1'),
          throwsA(isA<MusicXmlValidationException>()
              .having((e) => e.message, 'message', 'Invalid ending type: invalid')
              .having((e) => e.context?['type'], 'type context', 'invalid')),
        );
      });
    });
  });
}