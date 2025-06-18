import 'package:test/test.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_parse_exception.dart';

void main() {
  group('MusicXmlParseException', () {
    test('creates exception with message only', () {
      final exception = MusicXmlParseException('Test error message');

      expect(exception.message, equals('Test error message'));
      expect(exception.line, isNull);
      expect(exception.element, isNull);
      expect(exception.context, isNull);
    });

    test('creates exception with line number', () {
      final exception = MusicXmlParseException(
        'Test error message',
        line: 42,
      );

      expect(exception.message, equals('Test error message'));
      expect(exception.line, equals(42));
      expect(exception.element, isNull);
      expect(exception.context, isNull);
    });

    test('creates exception with element', () {
      final exception = MusicXmlParseException(
        'Test error message',
        element: 'pitch',
      );

      expect(exception.message, equals('Test error message'));
      expect(exception.line, isNull);
      expect(exception.element, equals('pitch'));
      expect(exception.context, isNull);
    });

    test('creates exception with full context', () {
      final context = {'measure': 5, 'part': 'P1'};
      final exception = MusicXmlParseException(
        'Test error message',
        line: 42,
        element: 'pitch',
        context: context,
      );

      expect(exception.message, equals('Test error message'));
      expect(exception.line, equals(42));
      expect(exception.element, equals('pitch'));
      expect(exception.context, equals(context));
    });

    test('toString includes message only', () {
      final exception = MusicXmlParseException('Test error');

      expect(
          exception.toString(), equals('MusicXmlParseException: Test error'));
    });

    test('toString includes element and line', () {
      final exception = MusicXmlParseException(
        'Test error',
        line: 42,
        element: 'pitch',
      );

      expect(
          exception.toString(), contains('MusicXmlParseException: Test error'));
      expect(exception.toString(), contains('(element: pitch, line: 42)'));
    });

    test('toString includes context', () {
      final exception = MusicXmlParseException(
        'Test error',
        context: {'measure': 5},
      );

      expect(
          exception.toString(), contains('MusicXmlParseException: Test error'));
      expect(exception.toString(), contains('[context: {measure: 5}]'));
    });

    test('toString with line only', () {
      final exception = MusicXmlParseException(
        'Test error',
        line: 42,
      );

      expect(
          exception.toString(), contains('MusicXmlParseException: Test error'));
      expect(exception.toString(), contains('(line: 42)'));
    });

    test('inherits from InvalidMusicXmlException', () {
      final exception = MusicXmlParseException('Test error');

      expect(exception, isA<Exception>());
    });
  });
}
