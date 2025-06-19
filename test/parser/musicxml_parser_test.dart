import 'package:musicxml_parser/src/exceptions/invalid_musicxml_exception.dart';
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
  });
}
