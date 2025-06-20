import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';

/// Represents page margins in a MusicXML document.
/// 
/// Page margins define the whitespace around the printable area of a page.
/// There can be separate margins for odd and even pages.
@immutable
class PageMargins {
  /// The type of page these margins apply to (e.g., "odd", "even", "both").
  final String type;

  /// The left margin in tenths.
  final double leftMargin;

  /// The right margin in tenths.
  final double rightMargin;

  /// The top margin in tenths.
  final double topMargin;

  /// The bottom margin in tenths.
  final double bottomMargin;

  /// Creates a new [PageMargins] instance.
  const PageMargins({
    required this.type,
    required this.leftMargin,
    required this.rightMargin,
    required this.topMargin,
    required this.bottomMargin,
  });

  /// Creates a new [PageMargins] instance with validation.
  ///
  /// Throws [MusicXmlValidationException] if invalid.
  factory PageMargins.validated({
    required String type,
    required double leftMargin,
    required double rightMargin,
    required double topMargin,
    required double bottomMargin,
    int? line,
    Map<String, dynamic>? context,
  }) {
    // Validate type
    const validTypes = ['odd', 'even', 'both'];
    if (!validTypes.contains(type)) {
      throw MusicXmlValidationException(
        'Invalid page margins type: $type. Expected one of: $validTypes',
        rule: 'page_margins_type_validation',
        line: line,
        context: {'type': type, ...?context},
      );
    }

    // Validate that margins are non-negative
    if (leftMargin < 0) {
      throw MusicXmlValidationException(
        'Left margin must be non-negative, got $leftMargin',
        rule: 'page_margins_value_validation',
        line: line,
        context: {'leftMargin': leftMargin, ...?context},
      );
    }

    if (rightMargin < 0) {
      throw MusicXmlValidationException(
        'Right margin must be non-negative, got $rightMargin',
        rule: 'page_margins_value_validation',
        line: line,
        context: {'rightMargin': rightMargin, ...?context},
      );
    }

    if (topMargin < 0) {
      throw MusicXmlValidationException(
        'Top margin must be non-negative, got $topMargin',
        rule: 'page_margins_value_validation',
        line: line,
        context: {'topMargin': topMargin, ...?context},
      );
    }

    if (bottomMargin < 0) {
      throw MusicXmlValidationException(
        'Bottom margin must be non-negative, got $bottomMargin',
        rule: 'page_margins_value_validation',
        line: line,
        context: {'bottomMargin': bottomMargin, ...?context},
      );
    }

    return PageMargins(
      type: type,
      leftMargin: leftMargin,
      rightMargin: rightMargin,
      topMargin: topMargin,
      bottomMargin: bottomMargin,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageMargins &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          leftMargin == other.leftMargin &&
          rightMargin == other.rightMargin &&
          topMargin == other.topMargin &&
          bottomMargin == other.bottomMargin;

  @override
  int get hashCode => Object.hash(
        type,
        leftMargin,
        rightMargin,
        topMargin,
        bottomMargin,
      );

  @override
  String toString() =>
      'PageMargins{type: $type, leftMargin: $leftMargin, rightMargin: $rightMargin, topMargin: $topMargin, bottomMargin: $bottomMargin}';
}