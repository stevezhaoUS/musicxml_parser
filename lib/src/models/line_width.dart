import 'package:meta/meta.dart';

/// Represents a line width specification in a musical score appearance.
///
/// Line widths specify the thickness of various graphical elements
/// such as staff lines, barlines, beams, etc.
@immutable
class LineWidth {
  /// The type of line this width applies to.
  ///
  /// Common types include: 'light barline', 'heavy barline', 'beam',
  /// 'bracket', 'dashes', 'enclosure', 'ending', 'extend', 'leger',
  /// 'pedal', 'octave shift', 'slur middle', 'slur tip', 'staff',
  /// 'stem', 'tie middle', 'tie tip', 'tuplet bracket', 'wedge'.
  final String type;

  /// The width value in tenths of staff space.
  final double value;

  /// Creates a new [LineWidth] instance.
  const LineWidth({
    required this.type,
    required this.value,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineWidth &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode => type.hashCode ^ value.hashCode;

  @override
  String toString() => 'LineWidth{type: $type, value: $value}';
}