import 'package:musicxml_parser/src/parser/score_parser.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('ScoreParser', () {
    late ScoreParser scoreParser;
    late WarningSystem warningSystem;

    setUp(() {
      warningSystem = WarningSystem();
      scoreParser = ScoreParser(warningSystem: warningSystem);
    });

    test('parses score with basic defaults layout', () {
      final xmlString = '''
        <score-partwise version="3.1">
          <part-list>
            <score-part id="P1"><part-name>Music</part-name></score-part>
          </part-list>
          <defaults>
            <scaling>
              <millimeters>7.2319</millimeters>
              <tenths>40</tenths>
            </scaling>
            <page-layout>
              <page-height>1697</page-height>
              <page-width>1200</page-width>
              <page-margins type="both">
                <left-margin>88</left-margin>
                <right-margin>88</right-margin>
                <top-margin>88</top-margin>
                <bottom-margin>88</bottom-margin>
              </page-margins>
            </page-layout>
            <system-layout>
              <system-margins>
                <left-margin>50</left-margin>
                <right-margin>0</right-margin>
              </system-margins>
              <system-distance>120</system-distance>
              <top-system-distance>70</top-system-distance>
            </system-layout>
            <staff-layout number="1">
              <staff-distance>80</staff-distance>
            </staff-layout>
            <staff-layout number="2">
              <staff-distance>70</staff-distance>
            </staff-layout>
          </defaults>
          <part id="P1">
            <measure number="1">
              <attributes><divisions>1</divisions></attributes>
              <note><duration>4</duration><rest/></note>
            </measure>
          </part>
        </score-partwise>
      ''';
      final document = XmlDocument.parse(xmlString);
      final score = scoreParser.parse(document);

      expect(score.scaling, isNotNull);
      expect(score.scaling!.millimeters, 7.2319);
      expect(score.scaling!.tenths, 40);

      expect(score.pageLayout, isNotNull);
      expect(score.pageLayout!.pageHeight, 1697);
      expect(score.pageLayout!.pageWidth, 1200);
      expect(score.pageLayout!.pageMargins, hasLength(1));
      expect(score.pageLayout!.pageMargins[0].type, 'both');
      expect(score.pageLayout!.pageMargins[0].leftMargin, 88);

      expect(score.defaultSystemLayout, isNotNull);
      expect(score.defaultSystemLayout!.systemMargins, isNotNull);
      expect(score.defaultSystemLayout!.systemMargins!.leftMargin, 50);
      expect(score.defaultSystemLayout!.systemDistance, 120);
      expect(score.defaultSystemLayout!.topSystemDistance, 70);

      expect(score.defaultStaffLayouts, hasLength(2));
      expect(score.defaultStaffLayouts[0].staffNumber, 1);
      expect(score.defaultStaffLayouts[0].staffDistance, 80);
      expect(score.defaultStaffLayouts[1].staffNumber, 2);
      expect(score.defaultStaffLayouts[1].staffDistance, 70);
    });

    test('parses score with minimal defaults', () {
      final xmlString = '''
        <score-partwise version="3.0">
          <part-list>
            <score-part id="P1"><part-name>Music</part-name></score-part>
          </part-list>
          <defaults/>
          <part id="P1">
            <measure number="1">
              <attributes><divisions>1</divisions></attributes>
              <note><duration>4</duration><rest/></note>
            </measure>
          </part>
        </score-partwise>
      ''';
      // Ensure <defaults/> is present, otherwise defaultsElement will be null
      final document = XmlDocument.parse(xmlString);
      final score = scoreParser.parse(document);

      expect(score.scaling, isNull);
      expect(score.pageLayout, isNull);
      expect(score.defaultSystemLayout, isNull);
      expect(score.defaultStaffLayouts, isEmpty);
    });

    test('parses score without defaults element', () {
        final xmlString = '''
        <score-partwise version="3.0">
          <part-list>
            <score-part id="P1"><part-name>Music</part-name></score-part>
          </part-list>
          <part id="P1">
            <measure number="1">
              <attributes><divisions>1</divisions></attributes>
              <note><duration>4</duration><rest/></note>
            </measure>
          </part>
        </score-partwise>
      ''';
        final document = XmlDocument.parse(xmlString);
        final score = scoreParser.parse(document);

        expect(score.scaling, isNull);
        expect(score.pageLayout, isNull);
        expect(score.defaultSystemLayout, isNull);
        expect(score.defaultStaffLayouts, isEmpty);
    });

    // TODO: Add more tests for variations in page-margins (odd, even), missing sub-elements etc.
  });
}
