import 'package:test/test.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_parse_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/parser/musicxml_parser.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';

void main() {
  group('Enhanced MusicXmlParser', () {
    late MusicXmlParser parser;
    late WarningSystem warningSystem;

    setUp(() {
      warningSystem = WarningSystem();
      parser = MusicXmlParser(warningSystem: warningSystem);
    });

    test('creates parser with default warning system', () {
      final defaultParser = MusicXmlParser();
      expect(defaultParser.warningSystem, isNotNull);
    });

    test('creates parser with custom warning system', () {
      expect(parser.warningSystem, equals(warningSystem));
    });

    test('throws MusicXmlStructureException for missing root element', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<invalid-root>
</invalid-root>''';

      expect(
        () => parser.parse(xml),
        throwsA(isA<MusicXmlStructureException>()
            .having((e) => e.message, 'message',
                contains('not a valid MusicXML file'))
            .having((e) => e.requiredElement, 'requiredElement',
                'score-partwise or score-timewise')),
      );
    });

    test('throws MusicXmlParseException for malformed XML', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <unclosed-tag>
</score-partwise>''';

      expect(
        () => parser.parse(xml),
        throwsA(isA<MusicXmlParseException>().having(
            (e) => e.message, 'message', contains('XML parsing error'))),
      );
    });

    test('throws MusicXmlStructureException for score-timewise format', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-timewise>
</score-timewise>''';

      expect(
        () => parser.parse(xml),
        throwsA(isA<MusicXmlStructureException>()
            .having(
                (e) => e.message, 'message', contains('not fully implemented'))
            .having(
                (e) => e.requiredElement, 'requiredElement', 'score-partwise')
            .having((e) => e.parentElement, 'parentElement', 'score-timewise')),
      );
    });

    test('throws MusicXmlStructureException for part without id', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part>
    <measure number="1">
    </measure>
  </part>
</score-partwise>''';

      expect(
        () => parser.parse(xml),
        throwsA(isA<MusicXmlStructureException>()
            .having((e) => e.message, 'message',
                contains('missing required "id" attribute'))
            .having((e) => e.requiredElement, 'requiredElement', 'id')
            .having((e) => e.parentElement, 'parentElement', 'part')),
      );
    });

    test('parses minimal valid MusicXML', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
    </measure>
  </part>
</score-partwise>''';

      final score = parser.parse(xml);

      expect(score.parts, hasLength(1));
      expect(score.parts.first.id, equals('P1'));
      expect(score.parts.first.measures, hasLength(1));
      expect(score.parts.first.measures.first.number, equals('1'));
    });

    test('collects warnings for missing part-list', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
    </measure>
  </part>
</score-partwise>''';

      parser.parse(xml);

      expect(warningSystem.hasWarnings, isTrue);
      final warnings =
          warningSystem.getWarningsByCategory(WarningCategories.structure);
      expect(warnings, hasLength(1));
      expect(warnings.first.message, contains('Missing part-list'));
    });

    test('throws MusicXmlValidationException for invalid key signature', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
      <attributes>
        <key>
          <fifths>8</fifths>
        </key>
      </attributes>
    </measure>
  </part>
</score-partwise>''';

      expect(
        () => parser.parse(xml),
        throwsA(isA<MusicXmlValidationException>()
            .having((e) => e.rule, 'rule', 'key_signature_fifths_validation')
            .having(
                (e) => e.message, 'message', contains('out of valid range'))),
      );
    });

    test('throws MusicXmlValidationException for invalid time signature', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
      <attributes>
        <time>
          <beats>4</beats>
          <beat-type>3</beat-type>
        </time>
      </attributes>
    </measure>
  </part>
</score-partwise>''';

      expect(
        () => parser.parse(xml),
        throwsA(isA<MusicXmlValidationException>()
            .having(
                (e) => e.rule, 'rule', 'time_signature_beat_type_validation')
            .having((e) => e.message, 'message',
                contains('must be a positive power of 2'))),
      );
    });

    test('throws MusicXmlParseException for invalid divisions', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
      <attributes>
        <divisions>abc</divisions>
      </attributes>
    </measure>
  </part>
</score-partwise>''';

      expect(
        () => parser.parse(xml),
        throwsA(isA<MusicXmlParseException>()
            .having((e) => e.message, 'message',
                contains('Invalid divisions value'))
            .having((e) => e.element, 'element', 'divisions')),
      );
    });

    test('throws MusicXmlValidationException for zero divisions', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
      <attributes>
        <divisions>0</divisions>
      </attributes>
    </measure>
  </part>
</score-partwise>''';

      expect(
        () => parser.parse(xml),
        throwsA(isA<MusicXmlValidationException>()
            .having((e) => e.rule, 'rule', 'divisions_positive_validation')
            .having((e) => e.message, 'message', contains('must be positive'))),
      );
    });

    test('throws MusicXmlStructureException for non-rest note without pitch',
        () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
      <note>
        <duration>480</duration>
      </note>
    </measure>
  </part>
</score-partwise>''';

      expect(
        () => parser.parse(xml),
        throwsA(isA<MusicXmlStructureException>()
            .having(
                (e) => e.message, 'message', contains('missing pitch element'))
            .having((e) => e.requiredElement, 'requiredElement', 'pitch')
            .having((e) => e.parentElement, 'parentElement', 'note')),
      );
    });

    test('parses valid note with pitch and validation', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
      <attributes>
        <divisions>480</divisions>
      </attributes>
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>480</duration>
        <type>quarter</type>
      </note>
    </measure>
  </part>
</score-partwise>''';

      final score = parser.parse(xml);

      expect(score.parts.first.measures.first.notes, hasLength(1));
      final note = score.parts.first.measures.first.notes.first;
      expect(note.pitch?.step, equals('C'));
      expect(note.pitch?.octave, equals(4));
      expect(note.duration, isNotNull);
      expect(note.duration!.value, equals(480));
      expect(note.type, equals('quarter'));
    });

    test('collects warnings for notes without duration', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
      </note>
    </measure>
  </part>
</score-partwise>''';

      final score = parser.parse(xml);

      expect(score.parts.first.measures.first.notes, hasLength(1));
      final note = score.parts.first.measures.first.notes.first;
      expect(note.duration, isNull);
      expect(warningSystem.hasWarnings, isTrue);

      final warnings =
          warningSystem.getWarningsByCategory(WarningCategories.duration);
      expect(warnings, hasLength(1));
      expect(warnings.first.message, contains('without duration'));
    });

    test('parses rest note correctly', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
      <note>
        <rest/>
        <duration>480</duration>
      </note>
    </measure>
  </part>
</score-partwise>''';

      final score = parser.parse(xml);

      expect(score.parts.first.measures.first.notes, hasLength(1));
      final note = score.parts.first.measures.first.notes.first;
      expect(note.isRest, isTrue);
      expect(note.pitch, isNull);
      expect(note.duration, isNotNull);
      expect(note.duration!.value, equals(480));
    });
  });
}
