import 'package:meta/meta.dart';

/// Represents page margins in a MusicXML document.
@immutable
class PageMargins {
  /// The left margin in tenths.
  final double leftMargin;

  /// The right margin in tenths.
  final double rightMargin;

  /// The top margin in tenths.
  final double topMargin;

  /// The bottom margin in tenths.
  final double bottomMargin;

  /// The type of margin (even or odd).
  final String? type;

  /// Creates a new [PageMargins] instance.
  const PageMargins({
    required this.leftMargin,
    required this.rightMargin,
    required this.topMargin,
    required this.bottomMargin,
    this.type,
  });
}

/// Represents page layout information in a MusicXML document.
@immutable
class PageLayout {
  /// The page height in tenths.
  final double? pageHeight;

  /// The page width in tenths.
  final double? pageWidth;

  /// The margins for even-numbered pages.
  final PageMargins? evenMargins;

  /// The margins for odd-numbered pages.
  final PageMargins? oddMargins;

  /// Creates a new [PageLayout] instance.
  const PageLayout({
    this.pageHeight,
    this.pageWidth,
    this.evenMargins,
    this.oddMargins,
  });
}

/// Represents scaling information in a MusicXML document.
@immutable
class Scaling {
  /// The number of millimeters per unit.
  final double millimeters;

  /// The number of tenths per unit.
  final double tenths;

  /// Creates a new [Scaling] instance.
  const Scaling({
    required this.millimeters,
    required this.tenths,
  });
}
