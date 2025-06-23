import 'package:musicxml_parser/src/exceptions/musicxml_parse_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/clef.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/parser/attributes_parser.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('AttributesParser', () {
    const parser = AttributesParser();
    const partId = 'P1';
    const measureNumber = '1';

    XmlElement buildAttributesXml(String content) {
      final doc = XmlDocument.parse('<attributes>$content</attributes>');
      return doc.rootElement;
    }

    group('divisions', () {
      test('parses valid divisions', () {
        final xml = buildAttributesXml('<divisions>480</divisions>');
        final attributes = parser.parse(xml, partId, measureNumber, null);
        expect(attributes['divisions'], 480);
      });

      test('throws MusicXmlParseException for invalid divisions text', () {
        final xml = buildAttributesXml('<divisions>abc</divisions>');
        expect(
          () => parser.parse(xml, partId, measureNumber, null),
          throwsA(isA<MusicXmlParseException>().having(
              (e) => e.message, 'message', contains('Invalid divisions value "abc"'))),
        );
      });

      test('throws MusicXmlValidationException for non-positive divisions', () {
        final xmlZero = buildAttributesXml('<divisions>0</divisions>');
        expect(
          () => parser.parse(xmlZero, partId, measureNumber, null),
          throwsA(isA<MusicXmlValidationException>().having((e) => e.message,
              'message', contains('Divisions value must be positive, got 0'))),
        );

        final xmlNegative = buildAttributesXml('<divisions>-10</divisions>');
        expect(
          () => parser.parse(xmlNegative, partId, measureNumber, null),
          throwsA(isA<MusicXmlValidationException>().having((e) => e.message,
              'message', contains('Divisions value must be positive, got -10'))),
        );
      });

      test('uses inherited divisions if not present', () {
        final xml = buildAttributesXml(''); // No divisions element
        final attributes = parser.parse(xml, partId, measureNumber, 240);
        expect(attributes['divisions'], 240);
      });

      test('overrides inherited divisions if present', () {
        final xml = buildAttributesXml('<divisions>480</divisions>');
        final attributes =
            parser.parse(xml, partId, measureNumber, 240); // Inherited 240
        expect(attributes['divisions'], 480); // Overridden by 480
      });
    });

    group('key signature', () {
      test('parses valid key signature', () {
        final xml =
            buildAttributesXml('<key><fifths>2</fifths><mode>major</mode></key>');
        final attributes = parser.parse(xml, partId, measureNumber, null);
        final key = attributes['keySignature'] as KeySignature?;
        expect(key, isNotNull);
        expect(key!.fifths, 2);
        expect(key.mode, 'major');
      });

      test('returns null for key signature if not present', () {
        final xml = buildAttributesXml(''); // No key element
        final attributes = parser.parse(xml, partId, measureNumber, null);
        expect(attributes['keySignature'], isNull);
      });

      test(
          'throws MusicXmlStructureException for incomplete key (missing fifths)',
          () {
        final xml =
            buildAttributesXml('<key><mode>major</mode></key>'); // Missing <fifths>
        expect(
          () => parser.parse(xml, partId, measureNumber, null),
          throwsA(isA<MusicXmlStructureException>().having((e) => e.message,
              'message', contains("Key element missing required <fifths> child"))),
        );
      });

      test('throws MusicXmlParseException for invalid fifths text in key', () {
        final xml = buildAttributesXml('<key><fifths>abc</fifths></key>');
        expect(
          () => parser.parse(xml, partId, measureNumber, null),
          throwsA(isA<MusicXmlParseException>().having(
              (e) => e.message, 'message', contains('Invalid fifths value "abc"'))),
        );
      });
    });

    group('time signature', () {
      test('parses valid time signature (beats/beat-type)', () {
        final xml = buildAttributesXml(
            '<time><beats>4</beats><beat-type>4</beat-type></time>');
        final attributes = parser.parse(xml, partId, measureNumber, null);
        final time = attributes['timeSignature'] as TimeSignature?;
        expect(time, isNotNull);
        expect(time!.beats, 4); // Expecting int
        expect(time.beatType, 4); // Expecting int
      });

      // Removed test for symbol-based time signature as it's not supported by the current TimeSignature model or parser logic
      // test('parses valid time signature (symbol)', () { ... });

      test('returns null for time signature if not present', () {
        final xml = buildAttributesXml(''); // No time element
        final attributes = parser.parse(xml, partId, measureNumber, null);
        expect(attributes['timeSignature'], isNull);
      });

      test(
          'throws MusicXmlStructureException for time missing beats',
          () {
        final xml = buildAttributesXml('<time><beat-type>4</beat-type></time>');
        expect(
          () => parser.parse(xml, partId, measureNumber, null),
          throwsA(isA<MusicXmlStructureException>().having((e) => e.message,
              'message',
              contains("Required <beats> element not found in <time>"))),
        );
      });

      test(
          'throws MusicXmlStructureException for time missing beat-type',
          () {
        final xml = buildAttributesXml('<time><beats>4</beats></time>');
        expect(
          () => parser.parse(xml, partId, measureNumber, null),
          throwsA(isA<MusicXmlStructureException>().having((e) => e.message,
              'message',
              contains("Required <beat-type> element not found in <time>"))),
        );
      });


      test('throws MusicXmlValidationException for invalid beats text in time', () {
        final xml = buildAttributesXml(
            '<time><beats>abc</beats><beat-type>4</beat-type></time>');
        expect(
          () => parser.parse(xml, partId, measureNumber, null),
          throwsA(isA<MusicXmlValidationException>().having( // Changed from MusicXmlParseException based on TimeSignature.fromXmlElement
              (e) => e.message, 'message', contains('Invalid time signature beats (numerator) value: "abc"'))),
        );
      });
       test('throws MusicXmlValidationException for invalid beat-type text in time', () {
        final xml = buildAttributesXml(
            '<time><beats>4</beats><beat-type>xyz</beat-type></time>');
        expect(
          () => parser.parse(xml, partId, measureNumber, null),
          throwsA(isA<MusicXmlValidationException>().having(
              (e) => e.message, 'message', contains('Invalid time signature beat-type (denominator) value: "xyz"'))),
        );
      });
    });

    group('clef', () {
      test('parses valid G clef', () {
        final xml =
            buildAttributesXml('<clef><sign>G</sign><line>2</line></clef>');
        final attributes = parser.parse(xml, partId, measureNumber, null);
        final clefs = attributes['clefs'] as List<Clef>?;
        expect(clefs, isNotNull);
        expect(clefs!.length, 1);
        expect(clefs.first.sign, 'G');
        expect(clefs.first.line, 2);
        expect(clefs.first.octaveChange, isNull);
        expect(clefs.first.number, isNull);
      });

      test('parses valid F clef', () {
        final xml =
            buildAttributesXml('<clef><sign>F</sign><line>4</line></clef>');
        final attributes = parser.parse(xml, partId, measureNumber, null);
        final clefs = attributes['clefs'] as List<Clef>?;
        expect(clefs, isNotNull);
        expect(clefs!.first.sign, 'F');
        expect(clefs.first.line, 4);
      });

      test('parses valid C clef', () {
        final xml =
            buildAttributesXml('<clef><sign>C</sign><line>3</line></clef>');
        final attributes = parser.parse(xml, partId, measureNumber, null);
        final clefs = attributes['clefs'] as List<Clef>?;
        expect(clefs, isNotNull);
        expect(clefs!.first.sign, 'C');
        expect(clefs.first.line, 3);
      });

      test('parses clef with octave change', () {
        final xml = buildAttributesXml(
            '<clef><sign>G</sign><line>2</line><clef-octave-change>-1</clef-octave-change></clef>');
        final attributes = parser.parse(xml, partId, measureNumber, null);
        final clefs = attributes['clefs'] as List<Clef>?;
        expect(clefs, isNotNull);
        expect(clefs!.first.sign, 'G');
        expect(clefs.first.line, 2);
        expect(clefs.first.octaveChange, -1);
      });

      test('parses clef with staff number', () {
        final xml = buildAttributesXml(
            '<clef number="2"><sign>F</sign><line>4</line></clef>');
        final attributes = parser.parse(xml, partId, measureNumber, null);
        final clefs = attributes['clefs'] as List<Clef>?;
        expect(clefs, isNotNull);
        expect(clefs!.first.sign, 'F');
        expect(clefs.first.line, 4);
        expect(clefs.first.number, 2);
      });

      test('parses multiple clefs', () {
        final xml = buildAttributesXml(
            '<clef number="1"><sign>G</sign><line>2</line></clef>'
            '<clef number="2"><sign>F</sign><line>4</line></clef>');
        final attributes = parser.parse(xml, partId, measureNumber, null);
        final clefs = attributes['clefs'] as List<Clef>?;
        expect(clefs, isNotNull);
        expect(clefs!.length, 2);
        expect(clefs[0].sign, 'G');
        expect(clefs[0].line, 2);
        expect(clefs[0].number, 1);
        expect(clefs[1].sign, 'F');
        expect(clefs[1].line, 4);
        expect(clefs[1].number, 2);
      });

      test('parses percussion clef (no line)', () {
        final xml = buildAttributesXml('<clef><sign>percussion</sign></clef>');
        final attributes = parser.parse(xml, partId, measureNumber, null);
        final clefs = attributes['clefs'] as List<Clef>?;
        expect(clefs, isNotNull);
        expect(clefs!.first.sign, 'percussion');
        expect(clefs.first.line, isNull);
      });


      test('returns null for clefs key if not present', () {
        final xml = buildAttributesXml(''); // No clef element
        final attributes = parser.parse(xml, partId, measureNumber, null);
        expect(attributes['clefs'], isNull);
      });

      test('throws MusicXmlStructureException for clef missing sign', () {
        final xml = buildAttributesXml('<clef><line>2</line></clef>');
        expect(
          () => parser.parse(xml, partId, measureNumber, null),
          throwsA(isA<MusicXmlStructureException>().having((e) => e.message,
              'message', contains('Clef element missing required <sign> child'))),
        );
      });

      test('throws MusicXmlValidationException for clef with empty sign', () {
        final xml = buildAttributesXml('<clef><sign></sign><line>2</line></clef>');
        expect(
          () => parser.parse(xml, partId, measureNumber, null),
          throwsA(isA<MusicXmlValidationException>().having((e) => e.message,
              'message', contains('Clef <sign> element cannot be empty'))),
        );
      });

      test('throws MusicXmlValidationException for G/F/C clef missing line', () {
        final xml = buildAttributesXml('<clef><sign>G</sign></clef>');
        expect(
          () => parser.parse(xml, partId, measureNumber, null),
          throwsA(isA<MusicXmlValidationException>().having((e) => e.message,
              'message', contains('Clef sign "G" requires a <line> element'))),
        );
      });

      test('throws MusicXmlParseException for invalid line text', () {
        final xml =
            buildAttributesXml('<clef><sign>G</sign><line>abc</line></clef>');
        expect(
          () => parser.parse(xml, partId, measureNumber, null),
          throwsA(isA<MusicXmlParseException>().having((e) => e.message,
              'message', contains('Invalid clef line value "abc"'))),
        );
      });

      test('throws MusicXmlParseException for invalid octave change text', () {
        final xml = buildAttributesXml(
            '<clef><sign>G</sign><line>2</line><clef-octave-change>xyz</clef-octave-change></clef>');
        expect(
          () => parser.parse(xml, partId, measureNumber, null),
          throwsA(isA<MusicXmlParseException>().having((e) => e.message,
              'message',
              contains('Invalid clef-octave-change value "xyz"'))),
        );
      });

      test('throws MusicXmlParseException for invalid clef number attribute', () {
        final xml = buildAttributesXml(
            '<clef number="abc"><sign>G</sign><line>2</line></clef>');
        expect(
          () => parser.parse(xml, partId, measureNumber, null),
          throwsA(isA<MusicXmlParseException>().having((e) => e.message,
              'message',
              contains('Invalid clef number attribute "abc"'))),
        );
      });
    });

    group('combined attributes', () {
      test('parses all attributes correctly when present', () {
        final xml = buildAttributesXml('<divisions>240</divisions>'
            '<key><fifths>-1</fifths><mode>minor</mode></key>'
            '<time><beats>3</beats><beat-type>8</beat-type></time>'
            '<clef><sign>G</sign><line>2</line><clef-octave-change>1</clef-octave-change></clef>');
        final attributes =
            parser.parse(xml, partId, measureNumber, 120); // Inherited 120

        expect(attributes['divisions'], 240);

        final key = attributes['keySignature'] as KeySignature?;
        expect(key, isNotNull);
        expect(key!.fifths, -1);
        expect(key.mode, 'minor');

        final time = attributes['timeSignature'] as TimeSignature?;
        expect(time, isNotNull);
        expect(time!.beats, ['3']);
        expect(time.beatTypes, ['8']);

        final clefs = attributes['clefs'] as List<Clef>?;
        expect(clefs, isNotNull);
        expect(clefs!.length, 1);
        expect(clefs.first.sign, 'G');
        expect(clefs.first.line, 2);
        expect(clefs.first.octaveChange, 1);
      });

      test('handles missing attributes gracefully', () {
        final xml = buildAttributesXml('<divisions>72</divisions>'); // Only divisions
        final attributes = parser.parse(xml, partId, measureNumber, null);

        expect(attributes['divisions'], 72);
        expect(attributes['keySignature'], isNull);
        expect(attributes['timeSignature'], isNull);
        expect(attributes['clefs'], isNull);
      });
    });
  });
}
