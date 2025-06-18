/// Exception thrown when an invalid MusicXML file is encountered.
class InvalidMusicXmlException implements Exception {
  /// The error message.
  final String message;

  /// The node where the error occurred, if available.
  final String? node;

  /// The line number where the error occurred, if available.
  final int? line;

  /// Creates a new [InvalidMusicXmlException] with the given [message].
  InvalidMusicXmlException(this.message, {this.node, this.line});

  @override
  String toString() {
    final buffer = StringBuffer('InvalidMusicXmlException: $message');
    if (node != null) {
      buffer.write(' (node: $node');
      if (line != null) {
        buffer.write(', line: $line');
      }
      buffer.write(')');
    } else if (line != null) {
      buffer.write(' (line: $line)');
    }
    return buffer.toString();
  }
}
