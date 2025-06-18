import 'package:test/test.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';

void main() {
  group('MusicXmlValidationException', () {
    test('creates exception with message only', () {
      final exception = MusicXmlValidationException('Validation error');

      expect(exception.message, equals('Validation error'));
      expect(exception.rule, isNull);
      expect(exception.line, isNull);
      expect(exception.node, isNull);
      expect(exception.context, isNull);
    });

    test('creates exception with rule', () {
      final exception = MusicXmlValidationException(
        'Pitch out of range',
        rule: 'pitch_range_validation',
      );

      expect(exception.message, equals('Pitch out of range'));
      expect(exception.rule, equals('pitch_range_validation'));
    });

    test('creates exception with full context', () {
      final context = {'step': 'C', 'octave': 12};
      final exception = MusicXmlValidationException(
        'Pitch out of range',
        rule: 'pitch_range_validation',
        line: 28,
        node: 'pitch',
        context: context,
      );

      expect(exception.message, equals('Pitch out of range'));
      expect(exception.rule, equals('pitch_range_validation'));
      expect(exception.line, equals(28));
      expect(exception.node, equals('pitch'));
      expect(exception.context, equals(context));
    });

    test('toString includes rule', () {
      final exception = MusicXmlValidationException(
        'Test error',
        rule: 'test_rule',
      );

      expect(exception.toString(),
          contains('MusicXmlValidationException: Test error'));
      expect(exception.toString(), contains('[rule: test_rule]'));
    });

    test('toString includes node and line', () {
      final exception = MusicXmlValidationException(
        'Test error',
        line: 42,
        node: 'pitch',
      );

      expect(exception.toString(),
          contains('MusicXmlValidationException: Test error'));
      expect(exception.toString(), contains('(node: pitch, line: 42)'));
    });

    test('toString includes context', () {
      final exception = MusicXmlValidationException(
        'Test error',
        context: {'measure': 5},
      );

      expect(exception.toString(),
          contains('MusicXmlValidationException: Test error'));
      expect(exception.toString(), contains('[context: {measure: 5}]'));
    });

    test('toString with all elements', () {
      final exception = MusicXmlValidationException(
        'Complex error',
        rule: 'complex_rule',
        line: 42,
        node: 'note',
        context: {'voice': 1},
      );

      final result = exception.toString();
      expect(result, contains('MusicXmlValidationException: Complex error'));
      expect(result, contains('[rule: complex_rule]'));
      expect(result, contains('(node: note, line: 42)'));
      expect(result, contains('[context: {voice: 1}]'));
    });

    test('inherits from InvalidMusicXmlException', () {
      final exception = MusicXmlValidationException('Test error');

      expect(exception, isA<Exception>());
    });
  });
}
