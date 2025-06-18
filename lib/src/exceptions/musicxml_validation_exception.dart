import 'package:musicxml_parser/src/exceptions/invalid_musicxml_exception.dart';

/// Exception thrown when MusicXML content violates musical rules or constraints.
///
/// This exception is used for errors related to musical validation, such as
/// invalid pitch ranges, incorrect measure durations, or inconsistent voice assignments.
///
/// Example:
/// ```dart
/// throw MusicXmlValidationException(
///   'Pitch octave 12 is out of valid range (0-9) at line 28',
///   rule: 'pitch_range_validation',
///   line: 28,
///   context: {'step': 'C', 'octave': 12, 'part': 'P1'}
/// );
/// ```
class MusicXmlValidationException extends InvalidMusicXmlException {
  /// The specific validation rule that was violated.
  final String? rule;

  /// Additional context information about the validation failure.
  final Map<String, dynamic>? context;

  /// Creates a new [MusicXmlValidationException] with the given [message].
  ///
  /// [message] - A descriptive error message
  /// [rule] - The validation rule that was violated (optional)
  /// [line] - The line number where the error occurred (optional)
  /// [node] - The XML node where the error occurred (optional)
  /// [context] - Additional context information (optional)
  MusicXmlValidationException(
    String message, {
    this.rule,
    int? line,
    String? node,
    this.context,
  }) : super(message, line: line, node: node);

  @override
  String toString() {
    final buffer = StringBuffer('MusicXmlValidationException: $message');

    if (rule != null) {
      buffer.write(' [rule: $rule]');
    }

    if (node != null) {
      buffer.write(' (node: $node');
      if (line != null) {
        buffer.write(', line: $line');
      }
      buffer.write(')');
    } else if (line != null) {
      buffer.write(' (line: $line)');
    }

    if (context != null && context!.isNotEmpty) {
      buffer.write(' [context: $context]');
    }

    return buffer.toString();
  }
}
