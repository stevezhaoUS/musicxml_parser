import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

@immutable
class PageMargins {
  final String? type; // "odd", "even", "both"
  final double? leftMargin;
  final double? rightMargin;
  final double? topMargin;
  final double? bottomMargin;

  const PageMargins({
    this.type,
    this.leftMargin,
    this.rightMargin,
    this.topMargin,
    this.bottomMargin,
  });

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
  int get hashCode =>
      type.hashCode ^
      leftMargin.hashCode ^
      rightMargin.hashCode ^
      topMargin.hashCode ^
      bottomMargin.hashCode;

  @override
  String toString() {
    return 'PageMargins{type: $type, leftMargin: $leftMargin, rightMargin: $rightMargin, topMargin: $topMargin, bottomMargin: $bottomMargin}';
  }
}

@immutable
class PageLayout {
  final double? pageHeight;
  final double? pageWidth;
  final List<PageMargins> pageMargins; // Can have up to 2 (odd/even) or one for "both"

  const PageLayout({
    this.pageHeight,
    this.pageWidth,
    this.pageMargins = const [],
  });

   @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageLayout &&
          runtimeType == other.runtimeType &&
          pageHeight == other.pageHeight &&
          pageWidth == other.pageWidth &&
          const DeepCollectionEquality().equals(pageMargins, other.pageMargins);

  @override
  int get hashCode =>
      pageHeight.hashCode ^
      pageWidth.hashCode ^
      const DeepCollectionEquality().hash(pageMargins);

  @override
  String toString() {
    return 'PageLayout{pageHeight: $pageHeight, pageWidth: $pageWidth, pageMargins: $pageMargins}';
  }
}

/// Represents scaling information in a MusicXML document.
/// Typically found within <defaults>.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Scaling &&
          runtimeType == other.runtimeType &&
          millimeters == other.millimeters &&
          tenths == other.tenths;

  @override
  int get hashCode => millimeters.hashCode ^ tenths.hashCode;

  @override
  String toString() {
    return 'Scaling{millimeters: $millimeters, tenths: $tenths}';
  }
}
