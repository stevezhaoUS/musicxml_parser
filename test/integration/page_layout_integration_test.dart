import 'dart:io';
import 'package:musicxml_parser/src/parser/page_layout_parser.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('Page Layout Integration Test', () {
    test('should parse page layout from real MusicXML file', () {
      // Read the test XML file
      final file = File('test_app/test_files/score.xml');
      final xmlContent = file.readAsStringSync();
      
      // Parse the XML document
      final document = XmlDocument.parse(xmlContent);
      
      // Find the page-layout element in the defaults section
      final pageLayoutElement = document.rootElement
          .findElements('defaults')
          .expand((defaults) => defaults.findElements('page-layout'))
          .singleOrNull;

      expect(pageLayoutElement, isNotNull, reason: 'page-layout element should exist in test file');

      // Parse the page-layout element
      final pageLayout = PageLayoutParser.parse(pageLayoutElement!);
      
      // Verify the parsed values match what's in the test file
      expect(pageLayout.pageHeight, equals(1697.14));
      expect(pageLayout.pageWidth, equals(1200.0));
      expect(pageLayout.pageMargins.length, equals(2));
      
      // Check even margins
      final evenMargins = pageLayout.getMarginsForType('even');
      expect(evenMargins, isNotNull);
      expect(evenMargins!.type, equals('even'));
      expect(evenMargins.leftMargin, equals(85.7143));
      expect(evenMargins.rightMargin, equals(85.7143));
      expect(evenMargins.topMargin, equals(85.7143));
      expect(evenMargins.bottomMargin, equals(85.7143));
      
      // Check odd margins
      final oddMargins = pageLayout.getMarginsForType('odd');
      expect(oddMargins, isNotNull);
      expect(oddMargins!.type, equals('odd'));
      expect(oddMargins.leftMargin, equals(85.7143));
      expect(oddMargins.rightMargin, equals(85.7143));
      expect(oddMargins.topMargin, equals(85.7143));
      expect(oddMargins.bottomMargin, equals(85.7143));
      
      // Test effective margins for different page numbers
      expect(pageLayout.getEffectiveMarginsForPage(1), equals(oddMargins));
      expect(pageLayout.getEffectiveMarginsForPage(2), equals(evenMargins));
      expect(pageLayout.getEffectiveMarginsForPage(3), equals(oddMargins));
      expect(pageLayout.getEffectiveMarginsForPage(4), equals(evenMargins));
      
      // Test that page layout is not empty
      expect(pageLayout.isEmpty, isFalse);
      expect(pageLayout.isNotEmpty, isTrue);
      
      print('✅ Successfully parsed page-layout from real MusicXML file!');
      print('   Page dimensions: ${pageLayout.pageWidth} x ${pageLayout.pageHeight}');
      print('   Margin types: ${pageLayout.pageMargins.map((m) => m.type).join(', ')}');
    });
  });
}