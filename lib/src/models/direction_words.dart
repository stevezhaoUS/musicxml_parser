import 'package:meta/meta.dart';

/// Represents a textual direction from a <words> element within a <direction>.
@immutable
class WordsDirection {
  /// The text content of the <words> element.
  final String text;

  // TODO: Add attributes from <words> element like:
  // final String? fontFamily;
  // final String? fontSize;
  // final double? defaultX;
  // final double? defaultY;
  // final String? halign;
  // final String? valign;
  // etc.

  /// Creates a new [WordsDirection] instance.
  const WordsDirection({
    required this.text,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordsDirection &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'WordsDirection{text: "$text"}';
}
