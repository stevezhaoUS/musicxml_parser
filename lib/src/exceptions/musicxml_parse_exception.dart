import 'package:musicxml_parser/src/exceptions/invalid_musicxml_exception.dart';

/// Exception thrown when parsing MusicXML content fails.
/// 
/// This exception is used for errors that occur during the parsing process,
/// such as malformed XML, unexpected elements, or missing required attributes.
/// 
/// Example:
/// ```dart
/// throw MusicXmlParseException(
///   'Invalid pitch step "H" at line 42, element <pitch>. Expected: C, D, E, F, G, A, B',
///   line: 42,
///   element: 'pitch',
///   context: {'measure': 5, 'part': 'P1'}
/// );
/// ```
class MusicXmlParseException extends InvalidMusicXmlException {
  /// The XML element where the error occurred.
  final String? element;
  
  /// Additional context information about where the error occurred.
  final Map<String, dynamic>? context;

  /// Creates a new [MusicXmlParseException] with the given [message].
  /// 
  /// [message] - A descriptive error message
  /// [line] - The line number where the error occurred (optional)
  /// [element] - The XML element where the error occurred (optional)
  /// [context] - Additional context information (optional)
  MusicXmlParseException(
    String message, {
    int? line,
    this.element,
    this.context,
  }) : super(message, line: line, node: element);

  @override
  String toString() {
    final buffer = StringBuffer('MusicXmlParseException: $message');
    
    if (element != null) {
      buffer.write(' (element: $element');
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
