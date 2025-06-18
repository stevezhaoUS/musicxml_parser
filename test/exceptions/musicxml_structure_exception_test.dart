import 'package:test/test.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';

void main() {
  group('MusicXmlStructureException', () {
    test('creates exception with message only', () {
      final exception = MusicXmlStructureException('Structure error');

      expect(exception.message, equals('Structure error'));
      expect(exception.requiredElement, isNull);
      expect(exception.parentElement, isNull);
      expect(exception.line, isNull);
      expect(exception.node, isNull);
      expect(exception.context, isNull);
    });

    test('creates exception with required element', () {
      final exception = MusicXmlStructureException(
        'Missing required element',
        requiredElement: 'part-list',
      );

      expect(exception.message, equals('Missing required element'));
      expect(exception.requiredElement, equals('part-list'));
    });

    test('creates exception with parent element', () {
      final exception = MusicXmlStructureException(
        'Missing element',
        requiredElement: 'part-list',
        parentElement: 'score-partwise',
      );

      expect(exception.message, equals('Missing element'));
      expect(exception.requiredElement, equals('part-list'));
      expect(exception.parentElement, equals('score-partwise'));
    });

    test('creates exception with full context', () {
      final context = {'score': 'example.xml'};
      final exception = MusicXmlStructureException(
        'Structure problem',
        requiredElement: 'part-list',
        parentElement: 'score-partwise',
        line: 5,
        node: 'score-partwise',
        context: context,
      );

      expect(exception.message, equals('Structure problem'));
      expect(exception.requiredElement, equals('part-list'));
      expect(exception.parentElement, equals('score-partwise'));
      expect(exception.line, equals(5));
      expect(exception.node, equals('score-partwise'));
      expect(exception.context, equals(context));
    });

    test('toString includes required element', () {
      final exception = MusicXmlStructureException(
        'Test error',
        requiredElement: 'part-list',
      );

      expect(exception.toString(),
          contains('MusicXmlStructureException: Test error'));
      expect(exception.toString(), contains('[required: part-list]'));
    });

    test('toString includes required and parent elements', () {
      final exception = MusicXmlStructureException(
        'Test error',
        requiredElement: 'part-list',
        parentElement: 'score-partwise',
      );

      expect(exception.toString(),
          contains('MusicXmlStructureException: Test error'));
      expect(exception.toString(),
          contains('[required: part-list in score-partwise]'));
    });

    test('toString includes node and line', () {
      final exception = MusicXmlStructureException(
        'Test error',
        line: 42,
        node: 'score-partwise',
      );

      expect(exception.toString(),
          contains('MusicXmlStructureException: Test error'));
      expect(
          exception.toString(), contains('(node: score-partwise, line: 42)'));
    });

    test('toString includes context', () {
      final exception = MusicXmlStructureException(
        'Test error',
        context: {'file': 'test.xml'},
      );

      expect(exception.toString(),
          contains('MusicXmlStructureException: Test error'));
      expect(exception.toString(), contains('[context: {file: test.xml}]'));
    });

    test('toString with all elements', () {
      final exception = MusicXmlStructureException(
        'Complex error',
        requiredElement: 'part-list',
        parentElement: 'score-partwise',
        line: 42,
        node: 'score-partwise',
        context: {'file': 'test.xml'},
      );

      final result = exception.toString();
      expect(result, contains('MusicXmlStructureException: Complex error'));
      expect(result, contains('[required: part-list in score-partwise]'));
      expect(result, contains('(node: score-partwise, line: 42)'));
      expect(result, contains('[context: {file: test.xml}]'));
    });

    test('inherits from InvalidMusicXmlException', () {
      final exception = MusicXmlStructureException('Test error');

      expect(exception, isA<Exception>());
    });
  });
}
