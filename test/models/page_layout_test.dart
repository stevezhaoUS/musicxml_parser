import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/page_layout.dart';
import 'package:musicxml_parser/src/models/page_margins.dart';
import 'package:test/test.dart';

void main() {
  group('PageLayout', () {
    test('should create a valid page layout instance', () {
      final layout = PageLayout(
        pageHeight: 1697.14,
        pageWidth: 1200.0,
        pageMargins: [
          PageMargins(
            type: 'odd',
            leftMargin: 85.0,
            rightMargin: 85.0,
            topMargin: 100.0,
            bottomMargin: 100.0,
          ),
        ],
      );

      expect(layout.pageHeight, equals(1697.14));
      expect(layout.pageWidth, equals(1200.0));
      expect(layout.pageMargins.length, equals(1));
      expect(layout.pageMargins.first.type, equals('odd'));
    });

    test('should create an empty page layout instance', () {
      const layout = PageLayout();

      expect(layout.pageHeight, isNull);
      expect(layout.pageWidth, isNull);
      expect(layout.pageMargins, isEmpty);
      expect(layout.isEmpty, isTrue);
      expect(layout.isNotEmpty, isFalse);
    });

    test('should create a validated page layout instance', () {
      final layout = PageLayout.validated(
        pageHeight: 800.0,
        pageWidth: 600.0,
        pageMargins: [
          PageMargins.validated(
            type: 'both',
            leftMargin: 50.0,
            rightMargin: 50.0,
            topMargin: 75.0,
            bottomMargin: 75.0,
          ),
        ],
      );

      expect(layout.pageHeight, equals(800.0));
      expect(layout.pageWidth, equals(600.0));
      expect(layout.pageMargins.length, equals(1));
      expect(layout.isNotEmpty, isTrue);
    });

    test('should allow optional page dimensions', () {
      final layout = PageLayout.validated(
        pageMargins: [
          PageMargins.validated(
            type: 'both',
            leftMargin: 50.0,
            rightMargin: 50.0,
            topMargin: 75.0,
            bottomMargin: 75.0,
          ),
        ],
      );

      expect(layout.pageHeight, isNull);
      expect(layout.pageWidth, isNull);
      expect(layout.pageMargins.length, equals(1));
    });

    test('should throw exception for non-positive page height', () {
      expect(
        () => PageLayout.validated(
          pageHeight: 0.0,
          pageWidth: 600.0,
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Page height must be positive'),
        )),
      );

      expect(
        () => PageLayout.validated(
          pageHeight: -100.0,
          pageWidth: 600.0,
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Page height must be positive'),
        )),
      );
    });

    test('should throw exception for non-positive page width', () {
      expect(
        () => PageLayout.validated(
          pageHeight: 800.0,
          pageWidth: 0.0,
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Page width must be positive'),
        )),
      );

      expect(
        () => PageLayout.validated(
          pageHeight: 800.0,
          pageWidth: -200.0,
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Page width must be positive'),
        )),
      );
    });

    test('should throw exception for duplicate margin types', () {
      expect(
        () => PageLayout.validated(
          pageHeight: 800.0,
          pageWidth: 600.0,
          pageMargins: [
            PageMargins.validated(
              type: 'odd',
              leftMargin: 50.0,
              rightMargin: 50.0,
              topMargin: 75.0,
              bottomMargin: 75.0,
            ),
            PageMargins.validated(
              type: 'odd',
              leftMargin: 60.0,
              rightMargin: 60.0,
              topMargin: 85.0,
              bottomMargin: 85.0,
            ),
          ],
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Duplicate page margin types found'),
        )),
      );
    });

    test('should get margins for specific type', () {
      final oddMargins = PageMargins.validated(
        type: 'odd',
        leftMargin: 50.0,
        rightMargin: 50.0,
        topMargin: 75.0,
        bottomMargin: 75.0,
      );
      final evenMargins = PageMargins.validated(
        type: 'even',
        leftMargin: 60.0,
        rightMargin: 60.0,
        topMargin: 85.0,
        bottomMargin: 85.0,
      );

      final layout = PageLayout.validated(
        pageMargins: [oddMargins, evenMargins],
      );

      expect(layout.getMarginsForType('odd'), equals(oddMargins));
      expect(layout.getMarginsForType('even'), equals(evenMargins));
      expect(layout.getMarginsForType('both'), isNull);
    });

    test('should get effective margins for page numbers', () {
      final oddMargins = PageMargins.validated(
        type: 'odd',
        leftMargin: 50.0,
        rightMargin: 50.0,
        topMargin: 75.0,
        bottomMargin: 75.0,
      );
      final evenMargins = PageMargins.validated(
        type: 'even',
        leftMargin: 60.0,
        rightMargin: 60.0,
        topMargin: 85.0,
        bottomMargin: 85.0,
      );

      final layout = PageLayout.validated(
        pageMargins: [oddMargins, evenMargins],
      );

      // Test odd page numbers
      expect(layout.getEffectiveMarginsForPage(1), equals(oddMargins));
      expect(layout.getEffectiveMarginsForPage(3), equals(oddMargins));
      expect(layout.getEffectiveMarginsForPage(5), equals(oddMargins));

      // Test even page numbers
      expect(layout.getEffectiveMarginsForPage(2), equals(evenMargins));
      expect(layout.getEffectiveMarginsForPage(4), equals(evenMargins));
      expect(layout.getEffectiveMarginsForPage(6), equals(evenMargins));
    });

    test('should fall back to "both" type margins', () {
      final bothMargins = PageMargins.validated(
        type: 'both',
        leftMargin: 55.0,
        rightMargin: 55.0,
        topMargin: 80.0,
        bottomMargin: 80.0,
      );

      final layout = PageLayout.validated(
        pageMargins: [bothMargins],
      );

      expect(layout.getEffectiveMarginsForPage(1), equals(bothMargins));
      expect(layout.getEffectiveMarginsForPage(2), equals(bothMargins));
    });

    test('should fall back to opposite type if needed', () {
      final evenMargins = PageMargins.validated(
        type: 'even',
        leftMargin: 60.0,
        rightMargin: 60.0,
        topMargin: 85.0,
        bottomMargin: 85.0,
      );

      final layout = PageLayout.validated(
        pageMargins: [evenMargins],
      );

      // For odd pages, should fall back to even margins
      expect(layout.getEffectiveMarginsForPage(1), equals(evenMargins));
      expect(layout.getEffectiveMarginsForPage(2), equals(evenMargins));
    });

    test('equality and hashCode should work correctly', () {
      final margins1 = PageMargins.validated(
        type: 'odd',
        leftMargin: 50.0,
        rightMargin: 50.0,
        topMargin: 75.0,
        bottomMargin: 75.0,
      );
      final margins2 = PageMargins.validated(
        type: 'even',
        leftMargin: 60.0,
        rightMargin: 60.0,
        topMargin: 85.0,
        bottomMargin: 85.0,
      );

      final layout1 = PageLayout(
        pageHeight: 800.0,
        pageWidth: 600.0,
        pageMargins: [margins1],
      );
      final layout2 = PageLayout(
        pageHeight: 800.0,
        pageWidth: 600.0,
        pageMargins: [margins1],
      );
      final layout3 = PageLayout(
        pageHeight: 900.0,
        pageWidth: 600.0,
        pageMargins: [margins1],
      );
      final layout4 = PageLayout(
        pageHeight: 800.0,
        pageWidth: 600.0,
        pageMargins: [margins2],
      );

      expect(layout1, equals(layout2));
      expect(layout1.hashCode, equals(layout2.hashCode));

      expect(layout1, isNot(equals(layout3)));
      expect(layout1, isNot(equals(layout4)));
    });

    test('toString should return correct representation', () {
      final margins = PageMargins.validated(
        type: 'odd',
        leftMargin: 50.0,
        rightMargin: 50.0,
        topMargin: 75.0,
        bottomMargin: 75.0,
      );

      final layout = PageLayout(
        pageHeight: 800.0,
        pageWidth: 600.0,
        pageMargins: [margins],
      );

      final expected = 'PageLayout{pageHeight: 800.0, pageWidth: 600.0, pageMargins: [${margins.toString()}]}';
      expect(layout.toString(), equals(expected));
    });
  });
}