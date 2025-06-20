import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/page_margins.dart';
import 'package:test/test.dart';

void main() {
  group('PageMargins', () {
    test('should create a valid page margins instance', () {
      final margins = PageMargins(
        type: 'odd',
        leftMargin: 85.0,
        rightMargin: 85.0,
        topMargin: 100.0,
        bottomMargin: 100.0,
      );

      expect(margins.type, equals('odd'));
      expect(margins.leftMargin, equals(85.0));
      expect(margins.rightMargin, equals(85.0));
      expect(margins.topMargin, equals(100.0));
      expect(margins.bottomMargin, equals(100.0));
    });

    test('should create a validated page margins instance', () {
      final margins = PageMargins.validated(
        type: 'even',
        leftMargin: 90.0,
        rightMargin: 90.0,
        topMargin: 110.0,
        bottomMargin: 110.0,
      );

      expect(margins.type, equals('even'));
      expect(margins.leftMargin, equals(90.0));
      expect(margins.rightMargin, equals(90.0));
      expect(margins.topMargin, equals(110.0));
      expect(margins.bottomMargin, equals(110.0));
    });

    test('should accept valid margin types', () {
      for (final type in ['odd', 'even', 'both']) {
        expect(
          () => PageMargins.validated(
            type: type,
            leftMargin: 50.0,
            rightMargin: 50.0,
            topMargin: 50.0,
            bottomMargin: 50.0,
          ),
          returnsNormally,
        );
      }
    });

    test('should throw exception for invalid margin type', () {
      expect(
        () => PageMargins.validated(
          type: 'invalid-type',
          leftMargin: 85.0,
          rightMargin: 85.0,
          topMargin: 100.0,
          bottomMargin: 100.0,
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Invalid page margins type'),
        )),
      );
    });

    test('should throw exception for negative left margin', () {
      expect(
        () => PageMargins.validated(
          type: 'odd',
          leftMargin: -10.0,
          rightMargin: 85.0,
          topMargin: 100.0,
          bottomMargin: 100.0,
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Left margin must be non-negative'),
        )),
      );
    });

    test('should throw exception for negative right margin', () {
      expect(
        () => PageMargins.validated(
          type: 'odd',
          leftMargin: 85.0,
          rightMargin: -5.0,
          topMargin: 100.0,
          bottomMargin: 100.0,
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Right margin must be non-negative'),
        )),
      );
    });

    test('should throw exception for negative top margin', () {
      expect(
        () => PageMargins.validated(
          type: 'odd',
          leftMargin: 85.0,
          rightMargin: 85.0,
          topMargin: -20.0,
          bottomMargin: 100.0,
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Top margin must be non-negative'),
        )),
      );
    });

    test('should throw exception for negative bottom margin', () {
      expect(
        () => PageMargins.validated(
          type: 'odd',
          leftMargin: 85.0,
          rightMargin: 85.0,
          topMargin: 100.0,
          bottomMargin: -15.0,
        ),
        throwsA(isA<MusicXmlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Bottom margin must be non-negative'),
        )),
      );
    });

    test('should accept zero margins', () {
      expect(
        () => PageMargins.validated(
          type: 'both',
          leftMargin: 0.0,
          rightMargin: 0.0,
          topMargin: 0.0,
          bottomMargin: 0.0,
        ),
        returnsNormally,
      );
    });

    test('equality and hashCode should work correctly', () {
      final margins1 = PageMargins(
        type: 'odd',
        leftMargin: 85.0,
        rightMargin: 85.0,
        topMargin: 100.0,
        bottomMargin: 100.0,
      );
      final margins2 = PageMargins(
        type: 'odd',
        leftMargin: 85.0,
        rightMargin: 85.0,
        topMargin: 100.0,
        bottomMargin: 100.0,
      );
      final margins3 = PageMargins(
        type: 'even',
        leftMargin: 85.0,
        rightMargin: 85.0,
        topMargin: 100.0,
        bottomMargin: 100.0,
      );
      final margins4 = PageMargins(
        type: 'odd',
        leftMargin: 90.0,
        rightMargin: 85.0,
        topMargin: 100.0,
        bottomMargin: 100.0,
      );

      expect(margins1, equals(margins2));
      expect(margins1.hashCode, equals(margins2.hashCode));

      expect(margins1, isNot(equals(margins3)));
      expect(margins1, isNot(equals(margins4)));
    });

    test('toString should return correct representation', () {
      final margins = PageMargins(
        type: 'odd',
        leftMargin: 85.0,
        rightMargin: 85.0,
        topMargin: 100.0,
        bottomMargin: 100.0,
      );

      expect(
        margins.toString(),
        equals(
          'PageMargins{type: odd, leftMargin: 85.0, rightMargin: 85.0, topMargin: 100.0, bottomMargin: 100.0}',
        ),
      );
    });
  });
}