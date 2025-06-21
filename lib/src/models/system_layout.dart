import 'package:meta/meta.dart';
// No collection needed for this specific file's direct classes, but good practice if they evolve.

@immutable
class SystemMargins {
  final double? leftMargin;
  final double? rightMargin;

  const SystemMargins({this.leftMargin, this.rightMargin});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemMargins &&
          runtimeType == other.runtimeType &&
          leftMargin == other.leftMargin &&
          rightMargin == other.rightMargin;

  @override
  int get hashCode => leftMargin.hashCode ^ rightMargin.hashCode;

  @override
  String toString() {
    return 'SystemMargins{leftMargin: $leftMargin, rightMargin: $rightMargin}';
  }
}

@immutable
class SystemDividers {
  final bool leftDivider;
  final bool rightDivider;

  const SystemDividers({this.leftDivider = false, this.rightDivider = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemDividers &&
          runtimeType == other.runtimeType &&
          leftDivider == other.leftDivider &&
          rightDivider == other.rightDivider;

  @override
  int get hashCode => leftDivider.hashCode ^ rightDivider.hashCode;

  @override
  String toString() {
    return 'SystemDividers{leftDivider: $leftDivider, rightDivider: $rightDivider}';
  }
}

@immutable
class SystemLayout {
  final SystemMargins? systemMargins;
  final double? systemDistance;
  final double? topSystemDistance;
  final SystemDividers? systemDividers;

  const SystemLayout({
    this.systemMargins,
    this.systemDistance,
    this.topSystemDistance,
    this.systemDividers,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemLayout &&
          runtimeType == other.runtimeType &&
          systemMargins == other.systemMargins &&
          systemDistance == other.systemDistance &&
          topSystemDistance == other.topSystemDistance &&
          systemDividers == other.systemDividers;

  @override
  int get hashCode =>
      systemMargins.hashCode ^
      systemDistance.hashCode ^
      topSystemDistance.hashCode ^
      systemDividers.hashCode;

  @override
  String toString() {
    return 'SystemLayout{systemMargins: $systemMargins, systemDistance: $systemDistance, topSystemDistance: $topSystemDistance, systemDividers: $systemDividers}';
  }
}
