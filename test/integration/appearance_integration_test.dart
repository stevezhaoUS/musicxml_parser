import 'package:musicxml_parser/musicxml_parser.dart';
import 'package:test/test.dart';

void main() {
  group('Appearance integration tests', () {
    test('parses appearance element in a complete MusicXML document', () {
      final musicXmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE score-partwise PUBLIC
    "-//Recordare//DTD MusicXML 3.1 Partwise//EN"
    "http://www.musicxml.org/dtds/partwise.dtd">
<score-partwise version="3.1">
  <appearance>
    <line-width type="light barline">1.8</line-width>
    <line-width type="heavy barline">5.5</line-width>
    <line-width type="beam">5</line-width>
    <line-width type="bracket">4.5</line-width>
    <line-width type="dashes">1</line-width>
    <line-width type="enclosure">1</line-width>
    <line-width type="ending">1.1</line-width>
    <line-width type="extend">1</line-width>
    <line-width type="leger">1.6</line-width>
    <line-width type="pedal">1.1</line-width>
    <line-width type="octave shift">1.1</line-width>
    <line-width type="slur middle">2.1</line-width>
    <line-width type="slur tip">0.5</line-width>
    <line-width type="staff">1.1</line-width>
    <line-width type="stem">1</line-width>
    <line-width type="tie middle">2.1</line-width>
    <line-width type="tie tip">0.5</line-width>
    <line-width type="tuplet bracket">1</line-width>
    <line-width type="wedge">1.2</line-width>
    <note-size type="cue">70</note-size>
    <note-size type="grace">70</note-size>
    <note-size type="grace-cue">49</note-size>
  </appearance>
  <part-list>
    <score-part id="P1">
      <part-name>Test Part</part-name>
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
        <duration>4</duration>
        <type>whole</type>
      </note>
    </measure>
  </part>
</score-partwise>''';

      final parser = MusicXmlParser();
      final score = parser.parse(musicXmlContent);

      // Verify the score was parsed successfully
      expect(score.parts, hasLength(1));
      expect(score.parts[0].id, equals('P1'));

      // Verify the appearance was parsed
      expect(score.appearance, isNotNull);
      final appearance = score.appearance!;

      // Verify line widths
      expect(appearance.lineWidths, hasLength(19));
      expect(appearance.lineWidths[0], equals(const LineWidth(type: 'light barline', value: 1.8)));
      expect(appearance.lineWidths[1], equals(const LineWidth(type: 'heavy barline', value: 5.5)));
      expect(appearance.lineWidths[2], equals(const LineWidth(type: 'beam', value: 5.0)));
      expect(appearance.lineWidths[12], equals(const LineWidth(type: 'slur tip', value: 0.5)));
      expect(appearance.lineWidths[13], equals(const LineWidth(type: 'staff', value: 1.1)));
      expect(appearance.lineWidths[14], equals(const LineWidth(type: 'stem', value: 1.0)));
      expect(appearance.lineWidths[18], equals(const LineWidth(type: 'wedge', value: 1.2)));

      // Verify note sizes
      expect(appearance.noteSizes, hasLength(3));
      expect(appearance.noteSizes[0], equals(const NoteSize(type: 'cue', value: 70.0)));
      expect(appearance.noteSizes[1], equals(const NoteSize(type: 'grace', value: 70.0)));
      expect(appearance.noteSizes[2], equals(const NoteSize(type: 'grace-cue', value: 49.0)));
    });

    test('parses MusicXML document without appearance element', () {
      final musicXmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE score-partwise PUBLIC
    "-//Recordare//DTD MusicXML 3.1 Partwise//EN"
    "http://www.musicxml.org/dtds/partwise.dtd">
<score-partwise version="3.1">
  <part-list>
    <score-part id="P1">
      <part-name>Test Part</part-name>
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
        <duration>4</duration>
        <type>whole</type>
      </note>
    </measure>
  </part>
</score-partwise>''';

      final parser = MusicXmlParser();
      final score = parser.parse(musicXmlContent);

      // Verify the score was parsed successfully
      expect(score.parts, hasLength(1));
      expect(score.parts[0].id, equals('P1'));

      // Verify the appearance is null when not present
      expect(score.appearance, isNull);
    });

    test('parses MusicXML document with empty appearance element', () {
      final musicXmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE score-partwise PUBLIC
    "-//Recordare//DTD MusicXML 3.1 Partwise//EN"
    "http://www.musicxml.org/dtds/partwise.dtd">
<score-partwise version="3.1">
  <appearance>
  </appearance>
  <part-list>
    <score-part id="P1">
      <part-name>Test Part</part-name>
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
        <duration>4</duration>
        <type>whole</type>
      </note>
    </measure>
  </part>
</score-partwise>''';

      final parser = MusicXmlParser();
      final score = parser.parse(musicXmlContent);

      // Verify the score was parsed successfully
      expect(score.parts, hasLength(1));
      expect(score.parts[0].id, equals('P1'));

      // Verify the appearance is present but empty
      expect(score.appearance, isNotNull);
      final appearance = score.appearance!;
      expect(appearance.lineWidths, isEmpty);
      expect(appearance.noteSizes, isEmpty);
    });
  });
}