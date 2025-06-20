import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/page_margins.dart';

/// Represents page layout information in a MusicXML document.
/// 
/// The page-layout element contains formatting information that affects the 
/// appearance of the score on the printed page. This includes page dimensions
/// and margins.
@immutable
class PageLayout {
  /// The height of the page in tenths.
  final double? pageHeight;

  /// The width of the page in tenths.
  final double? pageWidth;

  /// The page margins for different page types (odd, even, both).
  final List<PageMargins> pageMargins;

  /// Creates a new [PageLayout] instance.
  const PageLayout({
    this.pageHeight,
    this.pageWidth,
    this.pageMargins = const [],
  });

  /// Creates a new [PageLayout] instance with validation.
  ///
  /// Throws [MusicXmlValidationException] if invalid.
  factory PageLayout.validated({
    double? pageHeight,
    double? pageWidth,
    List<PageMargins>? pageMargins,
    int? line,
    Map<String, dynamic>? context,
  }) {
    final margins = pageMargins ?? [];

    // Validate page dimensions are positive if provided
    if (pageHeight != null && pageHeight <= 0) {
      throw MusicXmlValidationException(
        'Page height must be positive, got $pageHeight',
        rule: 'page_layout_height_validation',
        line: line,
        context: {'pageHeight': pageHeight, ...?context},
      );
    }

    if (pageWidth != null && pageWidth <= 0) {
      throw MusicXmlValidationException(
        'Page width must be positive, got $pageWidth',
        rule: 'page_layout_width_validation',
        line: line,
        context: {'pageWidth': pageWidth, ...?context},
      );
    }

    // Validate that margin types are unique
    final marginTypes = margins.map((m) => m.type).toSet();
    if (marginTypes.length != margins.length) {
      throw MusicXmlValidationException(
        'Duplicate page margin types found',
        rule: 'page_layout_margins_validation',
        line: line,
        context: {'marginTypes': margins.map((m) => m.type).toList(), ...?context},
      );
    }

    return PageLayout(
      pageHeight: pageHeight,
      pageWidth: pageWidth,
      pageMargins: margins,
    );
  }

  /// Gets the page margins for a specific type (odd, even, both).
  /// Returns null if no margins are defined for that type.
  PageMargins? getMarginsForType(String type) {
    try {
      return pageMargins.firstWhere((margins) => margins.type == type);
    } catch (e) {
      return null;
    }
  }

  /// Gets the effective page margins for a specific page number.
  /// This accounts for odd/even page types and falls back to "both" if needed.
  PageMargins? getEffectiveMarginsForPage(int pageNumber) {
    final isOddPage = pageNumber % 2 == 1;
    final preferredType = isOddPage ? 'odd' : 'even';
    
    // Try to get margins for the specific page type first
    var margins = getMarginsForType(preferredType);
    if (margins != null) return margins;
    
    // Fall back to "both" if available
    margins = getMarginsForType('both');
    if (margins != null) return margins;
    
    // If no specific margins found, try the opposite type as last resort
    final fallbackType = isOddPage ? 'even' : 'odd';
    return getMarginsForType(fallbackType);
  }

  /// Returns true if the page layout has any meaningful content.
  bool get isEmpty => pageHeight == null && pageWidth == null && pageMargins.isEmpty;

  /// Returns true if the page layout has content.
  bool get isNotEmpty => !isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageLayout &&
          runtimeType == other.runtimeType &&
          pageHeight == other.pageHeight &&
          pageWidth == other.pageWidth &&
          _listEquals(pageMargins, other.pageMargins);

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        pageHeight,
        pageWidth,
        Object.hashAll(pageMargins),
      );

  @override
  String toString() =>
      'PageLayout{pageHeight: $pageHeight, pageWidth: $pageWidth, pageMargins: $pageMargins}';
}