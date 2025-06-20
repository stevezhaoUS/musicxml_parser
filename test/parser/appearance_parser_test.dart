import 'package:musicxml_parser/src/models/line_width.dart';
import 'package:musicxml_parser/src/models/note_size.dart';
import 'package:musicxml_parser/src/parser/appearance_parser.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('AppearanceParser', () {
    late AppearanceParser parser;
    late WarningSystem warningSystem;

    setUp(() {
      warningSystem = WarningSystem();
      parser = AppearanceParser(warningSystem: warningSystem);
    });

    test('parses empty appearance element', () {
      final xml = '<appearance></appearance>';
      final element = XmlDocument.parse(xml).rootElement;
      
      final appearance = parser.parse(element);
      
      expect(appearance.lineWidths, isEmpty);
      expect(appearance.noteSizes, isEmpty);
    });

    test('parses line-width elements correctly', () {
      final xml = '''
        <appearance>
          <line-width type="staff">1.1</line-width>
          <line-width type="stem">1.0</line-width>
          <line-width type="heavy barline">5.5</line-width>
        </appearance>
      ''';
      final element = XmlDocument.parse(xml).rootElement;
      
      final appearance = parser.parse(element);
      
      expect(appearance.lineWidths, hasLength(3));
      expect(appearance.lineWidths[0], equals(const LineWidth(type: 'staff', value: 1.1)));
      expect(appearance.lineWidths[1], equals(const LineWidth(type: 'stem', value: 1.0)));
      expect(appearance.lineWidths[2], equals(const LineWidth(type: 'heavy barline', value: 5.5)));
    });

    test('parses note-size elements correctly', () {
      final xml = '''
        <appearance>
          <note-size type="cue">70</note-size>
          <note-size type="grace">70</note-size>
          <note-size type="grace-cue">49</note-size>
        </appearance>
      ''';
      final element = XmlDocument.parse(xml).rootElement;
      
      final appearance = parser.parse(element);
      
      expect(appearance.noteSizes, hasLength(3));
      expect(appearance.noteSizes[0], equals(const NoteSize(type: 'cue', value: 70.0)));
      expect(appearance.noteSizes[1], equals(const NoteSize(type: 'grace', value: 70.0)));
      expect(appearance.noteSizes[2], equals(const NoteSize(type: 'grace-cue', value: 49.0)));
    });

    test('parses complete appearance element from example', () {
      final xml = '''
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
      ''';
      final element = XmlDocument.parse(xml).rootElement;
      
      final appearance = parser.parse(element);
      
      expect(appearance.lineWidths, hasLength(19));
      expect(appearance.noteSizes, hasLength(3));
      
      // Check some specific values
      expect(appearance.lineWidths[0], equals(const LineWidth(type: 'light barline', value: 1.8)));
      expect(appearance.lineWidths[1], equals(const LineWidth(type: 'heavy barline', value: 5.5)));
      expect(appearance.noteSizes[0], equals(const NoteSize(type: 'cue', value: 70.0)));
      expect(appearance.noteSizes[2], equals(const NoteSize(type: 'grace-cue', value: 49.0)));
    });

    test('handles line-width without type attribute', () {
      final xml = '''
        <appearance>
          <line-width>1.1</line-width>
        </appearance>
      ''';
      final element = XmlDocument.parse(xml).rootElement;
      
      final appearance = parser.parse(element);
      
      expect(appearance.lineWidths, isEmpty);
      expect(warningSystem.getWarnings(), hasLength(1));
      expect(warningSystem.getWarnings()[0].message, contains('missing type attribute'));
    });

    test('handles line-width without value', () {
      final xml = '''
        <appearance>
          <line-width type="staff"></line-width>
        </appearance>
      ''';
      final element = XmlDocument.parse(xml).rootElement;
      
      final appearance = parser.parse(element);
      
      expect(appearance.lineWidths, isEmpty);
      expect(warningSystem.getWarnings(), hasLength(1));
      expect(warningSystem.getWarnings()[0].message, contains('has no value'));
    });

    test('handles line-width with invalid numeric value', () {
      final xml = '''
        <appearance>
          <line-width type="staff">not-a-number</line-width>
        </appearance>
      ''';
      final element = XmlDocument.parse(xml).rootElement;
      
      final appearance = parser.parse(element);
      
      expect(appearance.lineWidths, isEmpty);
      expect(warningSystem.getWarnings(), hasLength(1));
      expect(warningSystem.getWarnings()[0].message, contains('invalid numeric value'));
    });

    test('handles note-size without type attribute', () {
      final xml = '''
        <appearance>
          <note-size>70</note-size>
        </appearance>
      ''';
      final element = XmlDocument.parse(xml).rootElement;
      
      final appearance = parser.parse(element);
      
      expect(appearance.noteSizes, isEmpty);
      expect(warningSystem.getWarnings(), hasLength(1));
      expect(warningSystem.getWarnings()[0].message, contains('missing type attribute'));
    });

    test('handles note-size without value', () {
      final xml = '''
        <appearance>
          <note-size type="cue"></note-size>
        </appearance>
      ''';
      final element = XmlDocument.parse(xml).rootElement;
      
      final appearance = parser.parse(element);
      
      expect(appearance.noteSizes, isEmpty);
      expect(warningSystem.getWarnings(), hasLength(1));
      expect(warningSystem.getWarnings()[0].message, contains('has no value'));
    });

    test('handles note-size with invalid numeric value', () {
      final xml = '''
        <appearance>
          <note-size type="cue">not-a-number</note-size>
        </appearance>
      ''';
      final element = XmlDocument.parse(xml).rootElement;
      
      final appearance = parser.parse(element);
      
      expect(appearance.noteSizes, isEmpty);
      expect(warningSystem.getWarnings(), hasLength(1));
      expect(warningSystem.getWarnings()[0].message, contains('invalid numeric value'));
    });

    test('handles mixed valid and invalid elements', () {
      final xml = '''
        <appearance>
          <line-width type="staff">1.1</line-width>
          <line-width>invalid</line-width>
          <note-size type="cue">70</note-size>
          <note-size type="grace">not-a-number</note-size>
        </appearance>
      ''';
      final element = XmlDocument.parse(xml).rootElement;
      
      final appearance = parser.parse(element);
      
      expect(appearance.lineWidths, hasLength(1));
      expect(appearance.noteSizes, hasLength(1));
      expect(warningSystem.getWarnings(), hasLength(2));
    });

    test('handles decimal values correctly', () {
      final xml = '''
        <appearance>
          <line-width type="slur tip">0.5</line-width>
          <note-size type="grace-cue">49.5</note-size>
        </appearance>
      ''';
      final element = XmlDocument.parse(xml).rootElement;
      
      final appearance = parser.parse(element);
      
      expect(appearance.lineWidths[0].value, equals(0.5));
      expect(appearance.noteSizes[0].value, equals(49.5));
    });
  });
}