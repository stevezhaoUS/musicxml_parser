import 'package:musicxml_parser/src/exceptions/invalid_musicxml_exception.dart';

/// Exception thrown when MusicXML content has structural problems.
///
/// This exception is used for errors related to the overall structure of the
/// MusicXML document, such as missing required elements, invalid element hierarchy,
/// or incorrect document format.
///
/// Example:
/// ```dart
/// throw MusicXmlStructureException(
///   'Missing required <part-list> element in score-partwise',
///   requiredElement: 'part-list',
///   parentElement: 'score-partwise',
///   line: 5
/// );
/// ```
class MusicXmlStructureException extends InvalidMusicXmlException {
  /// The required element that is missing or invalid.
  final String? requiredElement;

  /// The parent element where the structure problem occurred.
  final String? parentElement;

  /// Additional context information about the structural problem.
  final Map<String, dynamic>? context;

  /// Creates a new [MusicXmlStructureException] with the given [message].
  ///
  /// [message] - A descriptive error message
  /// [requiredElement] - The required element that is missing or invalid (optional)
  /// [parentElement] - The parent element where the problem occurred (optional)
  /// [line] - The line number where the error occurred (optional)
  /// [node] - The XML node where the error occurred (optional)
  /// [context] - Additional context information (optional)
  MusicXmlStructureException(
    String message, {
    this.requiredElement,
    this.parentElement,
    int? line,
    String? node,
    this.context,
  }) : super(message, line: line, node: node);

  @override
  String toString() {
    final buffer = StringBuffer('MusicXmlStructureException: $message');

    if (requiredElement != null) {
      buffer.write(' [required: $requiredElement');
      if (parentElement != null) {
        buffer.write(' in $parentElement');
      }
      buffer.write(']');
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
