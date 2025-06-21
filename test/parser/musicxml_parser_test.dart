import 'package:musicxml_parser/src/exceptions/invalid_musicxml_exception.dart';
import 'package:musicxml_parser/src/models/credit.dart'; // Added for Credit tests
import 'package:musicxml_parser/src/models/score.dart';
import 'package:musicxml_parser/src/parser/musicxml_parser.dart';
import 'package:test/test.dart';

void main() {
  group('MusicXmlParser', () {
    late MusicXmlParser parser;

    setUp(() {
      parser = MusicXmlParser();
    });

    test('parse simple score', () {
      const xmlString = '''
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 3.1 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
<score-partwise version="3.1">
  <work>
    <work-title>Simple Example</work-title>
  </work>
  <identification>
    <creator type="composer">Test Composer</creator>
  </identification>
  <part-list>
    <score-part id="P1">
      <part-name>Music</part-name>
    </score-part>
  </part-list>
  <part id="P1">
    <measure number="1">
      <attributes>
        <divisions>1</divisions>
        <key>
          <fifths>0</fifths>
        </key>
        <time>
          <beats>4</beats>
          <beat-type>4</beat-type>
        </time>
      </attributes>
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>1</duration>
        <type>quarter</type>
      </note>
    </measure>
  </part>
</score-partwise>
''';

      final score = parser.parse(xmlString);

      expect(score, isA<Score>());
      expect(score.title, equals('Simple Example'));
      expect(score.composer, equals('Test Composer'));
      expect(score.parts.length, equals(1));

      final part = score.parts[0];
      expect(part.id, equals('P1'));
      expect(part.name, equals('Music'));
      expect(part.measures.length, equals(1));

      final measure = part.measures[0];
      expect(measure.number, equals('1'));
      expect(measure.timeSignature?.beats, equals(4));
      expect(measure.timeSignature?.beatType, equals(4));
      expect(measure.keySignature?.fifths, equals(0));
      expect(measure.notes.length, equals(1));

      final note = measure.notes[0];
      expect(note.isRest, isFalse);
      expect(note.pitch?.step, equals('C'));
      expect(note.pitch?.octave, equals(4));
      expect(note.duration, isNotNull);
      expect(note.duration!.value, equals(1));
    });

    test('throws exception for invalid XML', () {
      const invalidXml = '<not-valid-xml>';
      expect(() => parser.parse(invalidXml),
          throwsA(isA<InvalidMusicXmlException>()));
    });

    test('throws exception for non-MusicXML content', () {
      const nonMusicXml = '<root><child>This is not MusicXML</child></root>';
      expect(() => parser.parse(nonMusicXml),
          throwsA(isA<InvalidMusicXmlException>()));
    });

    group('credit parsing', () {
      test('parses score with no <credit> elements', () {
        const xmlString = '''
          <score-partwise version="3.1">
            <part-list><score-part id="P1"><part-name>Part</part-name></score-part></part-list>
            <part id="P1"><measure number="1"><note><rest/><duration>4</duration></note></measure></part>
          </score-partwise>
        ''';
        final score = parser.parse(xmlString);
        expect(score.credits, isNull);
      });

      test('parses score with a single, simple <credit> (credit-words only)', () {
        const xmlString = '''
          <score-partwise version="3.1">
            <credit><credit-words>Copyright 2023</credit-words></credit>
            <part-list><score-part id="P1"><part-name>Part</part-name></score-part></part-list>
            <part id="P1"><measure number="1"><note><rest/><duration>4</duration></note></measure></part>
          </score-partwise>
        ''';
        final score = parser.parse(xmlString);
        expect(score.credits, isNotNull);
        expect(score.credits, hasLength(1));
        expect(score.credits![0].creditWords, equals(['Copyright 2023']));
        expect(score.credits![0].page, isNull);
        expect(score.credits![0].creditType, isNull);
      });

      test('parses score with a <credit> having page and <credit-type>', () {
        const xmlString = '''
          <score-partwise version="3.1">
            <credit page="1">
              <credit-type>title</credit-type>
              <credit-words>My Awesome Score</credit-words>
            </credit>
            <part-list><score-part id="P1"><part-name>Part</part-name></score-part></part-list>
            <part id="P1"><measure number="1"><note><rest/><duration>4</duration></note></measure></part>
          </score-partwise>
        ''';
        final score = parser.parse(xmlString);
        expect(score.credits, isNotNull);
        expect(score.credits, hasLength(1));
        final credit = score.credits![0];
        expect(credit.page, 1);
        expect(credit.creditType, 'title');
        expect(credit.creditWords, equals(['My Awesome Score']));
      });

      test('parses score with a <credit> having multiple <credit-words>', () {
        const xmlString = '''
          <score-partwise version="3.1">
            <credit>
              <credit-type>composer</credit-type>
              <credit-words>John Doe</credit-words>
              <credit-words>Arr. Jane Smith</credit-words>
            </credit>
            <part-list><score-part id="P1"><part-name>Part</part-name></score-part></part-list>
            <part id="P1"><measure number="1"><note><rest/><duration>4</duration></note></measure></part>
          </score-partwise>
        ''';
        final score = parser.parse(xmlString);
        expect(score.credits, isNotNull);
        expect(score.credits, hasLength(1));
        final credit = score.credits![0];
        expect(credit.creditType, 'composer');
        expect(credit.creditWords, equals(['John Doe', 'Arr. Jane Smith']));
      });

      test('parses score with multiple <credit> elements', () {
        const xmlString = '''
          <score-partwise version="3.1">
            <credit page="1"><credit-type>title</credit-type><credit-words>Main Title</credit-words></credit>
            <credit><credit-type>composer</credit-type><credit-words>The Composer</credit-words></credit>
            <part-list><score-part id="P1"><part-name>Part</part-name></score-part></part-list>
            <part id="P1"><measure number="1"><note><rest/><duration>4</duration></note></measure></part>
          </score-partwise>
        ''';
        final score = parser.parse(xmlString);
        expect(score.credits, isNotNull);
        expect(score.credits, hasLength(2));

        final credit1 = score.credits![0];
        expect(credit1.page, 1);
        expect(credit1.creditType, 'title');
        expect(credit1.creditWords, equals(['Main Title']));

        final credit2 = score.credits![1];
        expect(credit2.page, isNull);
        expect(credit2.creditType, 'composer');
        expect(credit2.creditWords, equals(['The Composer']));
      });

      test('parses score with an "empty" <credit> (no type or words, no page) - should be skipped', () {
        const xmlString = '''
          <score-partwise version="3.1">
            <credit></credit>
            <part-list><score-part id="P1"><part-name>Part</part-name></score-part></part-list>
            <part id="P1"><measure number="1"><note><rest/><duration>4</duration></note></measure></part>
          </score-partwise>
        ''';
        final score = parser.parse(xmlString);
        expect(score.credits, isNull);
      });

      test('parses score with <credit> having only empty <credit-type> - should be skipped', () {
        const xmlString = '''
          <score-partwise version="3.1">
            <credit><credit-type></credit-type></credit>
            <part-list><score-part id="P1"><part-name>Part</part-name></score-part></part-list>
            <part id="P1"><measure number="1"><note><rest/><duration>4</duration></note></measure></part>
          </score-partwise>
        ''';
        final score = parser.parse(xmlString);
        expect(score.credits, isNull);
      });

      test('parses score with <credit> having only page number - should be included', () {
        const xmlString = '''
          <score-partwise version="3.1">
            <credit page="3"></credit>
            <part-list><score-part id="P1"><part-name>Part</part-name></score-part></part-list>
            <part id="P1"><measure number="1"><note><rest/><duration>4</duration></note></measure></part>
          </score-partwise>
        ''';
        final score = parser.parse(xmlString);
        expect(score.credits, isNotNull);
        expect(score.credits, hasLength(1));
        expect(score.credits![0].page, equals(3));
        expect(score.credits![0].creditType, isNull);
        expect(score.credits![0].creditWords, isEmpty);
      });
    });
  });
}
