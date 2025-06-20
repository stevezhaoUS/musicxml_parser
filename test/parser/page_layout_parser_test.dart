import 'package:musicxml_parser/src/exceptions/musicxml_parse_exception.dart';
import 'package:musicxml_parser/src/models/page_layout.dart';
import 'package:musicxml_parser/src/models/page_margins.dart';
import 'package:musicxml_parser/src/parser/page_layout_parser.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('PageLayoutParser', () {
    test('should parse complete page layout', () {
      final xml = '''
        <page-layout>
          <page-height>1697.14</page-height>
          <page-width>1200</page-width>
          <page-margins type="even">
            <left-margin>85.7143</left-margin>
            <right-margin>85.7143</right-margin>
            <top-margin>85.7143</top-margin>
            <bottom-margin>85.7143</bottom-margin>
          </page-margins>
          <page-margins type="odd">
            <left-margin>85.7143</left-margin>
            <right-margin>85.7143</right-margin>
            <top-margin>85.7143</top-margin>
            <bottom-margin>85.7143</bottom-margin>
          </page-margins>
        </page-layout>
      ''';

      final document = XmlDocument.parse(xml);
      final element = document.rootElement;
      final layout = PageLayoutParser.parse(element);

      expect(layout.pageHeight, equals(1697.14));
      expect(layout.pageWidth, equals(1200.0));
      expect(layout.pageMargins.length, equals(2));
      
      final evenMargins = layout.getMarginsForType('even');
      expect(evenMargins, isNotNull);
      expect(evenMargins!.leftMargin, equals(85.7143));
      expect(evenMargins.rightMargin, equals(85.7143));
      expect(evenMargins.topMargin, equals(85.7143));
      expect(evenMargins.bottomMargin, equals(85.7143));

      final oddMargins = layout.getMarginsForType('odd');
      expect(oddMargins, isNotNull);
      expect(oddMargins!.leftMargin, equals(85.7143));
    });

    test('should parse page layout with only dimensions', () {
      final xml = '''
        <page-layout>
          <page-height>800</page-height>
          <page-width>600</page-width>
        </page-layout>
      ''';

      final document = XmlDocument.parse(xml);
      final element = document.rootElement;
      final layout = PageLayoutParser.parse(element);

      expect(layout.pageHeight, equals(800.0));
      expect(layout.pageWidth, equals(600.0));
      expect(layout.pageMargins, isEmpty);
    });

    test('should parse page layout with only margins', () {
      final xml = '''
        <page-layout>
          <page-margins type="both">
            <left-margin>50</left-margin>
            <right-margin>50</right-margin>
            <top-margin>75</top-margin>
            <bottom-margin>75</bottom-margin>
          </page-margins>
        </page-layout>
      ''';

      final document = XmlDocument.parse(xml);
      final element = document.rootElement;
      final layout = PageLayoutParser.parse(element);

      expect(layout.pageHeight, isNull);
      expect(layout.pageWidth, isNull);
      expect(layout.pageMargins.length, equals(1));
      
      final margins = layout.getMarginsForType('both');
      expect(margins, isNotNull);
      expect(margins!.type, equals('both'));
    });

    test('should parse empty page layout', () {
      final xml = '<page-layout></page-layout>';

      final document = XmlDocument.parse(xml);
      final element = document.rootElement;
      final layout = PageLayoutParser.parse(element);

      expect(layout.pageHeight, isNull);
      expect(layout.pageWidth, isNull);
      expect(layout.pageMargins, isEmpty);
      expect(layout.isEmpty, isTrue);
    });

    test('should parse page margins with default type', () {
      final xml = '''
        <page-layout>
          <page-margins>
            <left-margin>40</left-margin>
            <right-margin>40</right-margin>
            <top-margin>60</top-margin>
            <bottom-margin>60</bottom-margin>
          </page-margins>
        </page-layout>
      ''';

      final document = XmlDocument.parse(xml);
      final element = document.rootElement;
      final layout = PageLayoutParser.parse(element);

      expect(layout.pageMargins.length, equals(1));
      
      final margins = layout.pageMargins.first;
      expect(margins.type, equals('both')); // Default type
      expect(margins.leftMargin, equals(40.0));
      expect(margins.rightMargin, equals(40.0));
      expect(margins.topMargin, equals(60.0));
      expect(margins.bottomMargin, equals(60.0));
    });

    test('should parse page margins with missing margin elements', () {
      final xml = '''
        <page-layout>
          <page-margins type="odd">
            <left-margin>30</left-margin>
            <top-margin>50</top-margin>
          </page-margins>
        </page-layout>
      ''';

      final document = XmlDocument.parse(xml);
      final element = document.rootElement;
      final layout = PageLayoutParser.parse(element);

      expect(layout.pageMargins.length, equals(1));
      
      final margins = layout.pageMargins.first;
      expect(margins.type, equals('odd'));
      expect(margins.leftMargin, equals(30.0));
      expect(margins.rightMargin, equals(0.0)); // Default to 0
      expect(margins.topMargin, equals(50.0));
      expect(margins.bottomMargin, equals(0.0)); // Default to 0
    });

    test('should handle decimal values correctly', () {
      final xml = '''
        <page-layout>
          <page-height>1234.56</page-height>
          <page-width>987.65</page-width>
          <page-margins type="even">
            <left-margin>12.34</left-margin>
            <right-margin>56.78</right-margin>
            <top-margin>90.12</top-margin>
            <bottom-margin>34.56</bottom-margin>
          </page-margins>
        </page-layout>
      ''';

      final document = XmlDocument.parse(xml);
      final element = document.rootElement;
      final layout = PageLayoutParser.parse(element);

      expect(layout.pageHeight, equals(1234.56));
      expect(layout.pageWidth, equals(987.65));
      
      final margins = layout.getMarginsForType('even');
      expect(margins!.leftMargin, equals(12.34));
      expect(margins.rightMargin, equals(56.78));
      expect(margins.topMargin, equals(90.12));
      expect(margins.bottomMargin, equals(34.56));
    });

    test('should throw exception for invalid page height', () {
      final xml = '''
        <page-layout>
          <page-height>invalid</page-height>
        </page-layout>
      ''';

      final document = XmlDocument.parse(xml);
      final element = document.rootElement;

      expect(
        () => PageLayoutParser.parse(element),
        throwsA(isA<MusicXmlParseException>().having(
          (e) => e.message,
          'message',
          contains('Invalid page height value'),
        )),
      );
    });

    test('should throw exception for invalid page width', () {
      final xml = '''
        <page-layout>
          <page-width>not-a-number</page-width>
        </page-layout>
      ''';

      final document = XmlDocument.parse(xml);
      final element = document.rootElement;

      expect(
        () => PageLayoutParser.parse(element),
        throwsA(isA<MusicXmlParseException>().having(
          (e) => e.message,
          'message',
          contains('Invalid page width value'),
        )),
      );
    });

    test('should handle negative margin values by setting to zero', () {
      final xml = '''
        <page-layout>
          <page-margins type="both">
            <left-margin>-10</left-margin>
            <right-margin>50</right-margin>
            <top-margin>75</top-margin>
            <bottom-margin>75</bottom-margin>
          </page-margins>
        </page-layout>
      ''';

      final document = XmlDocument.parse(xml);
      final element = document.rootElement;

      expect(
        () => PageLayoutParser.parse(element),
        throwsA(isA<MusicXmlParseException>().having(
          (e) => e.message,
          'message',
          contains('Left margin cannot be negative'),
        )),
      );
    });

    test('should handle whitespace in values', () {
      final xml = '''
        <page-layout>
          <page-height>  800.5  </page-height>
          <page-width>
            600.25
          </page-width>
          <page-margins type="both">
            <left-margin>  50.0  </left-margin>
            <right-margin>
              50.0
            </right-margin>
            <top-margin>75.0</top-margin>
            <bottom-margin>75.0</bottom-margin>
          </page-margins>
        </page-layout>
      ''';

      final document = XmlDocument.parse(xml);
      final element = document.rootElement;
      final layout = PageLayoutParser.parse(element);

      expect(layout.pageHeight, equals(800.5));
      expect(layout.pageWidth, equals(600.25));
      
      final margins = layout.getMarginsForType('both');
      expect(margins!.leftMargin, equals(50.0));
      expect(margins.rightMargin, equals(50.0));
    });

    test('should parse with line and context information', () {
      final xml = '''
        <page-layout>
          <page-height>800</page-height>
          <page-width>600</page-width>
        </page-layout>
      ''';

      final document = XmlDocument.parse(xml);
      final element = document.rootElement;
      final layout = PageLayoutParser.parse(
        element,
        line: 42,
        context: {'source': 'test'},
      );

      expect(layout.pageHeight, equals(800.0));
      expect(layout.pageWidth, equals(600.0));
    });
  });
}