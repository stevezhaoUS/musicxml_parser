import 'package:meta/meta.dart';

@immutable
class MeasureLayout {
  final double? measureDistance;

  const MeasureLayout({this.measureDistance});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasureLayout &&
          runtimeType == other.runtimeType &&
          measureDistance == other.measureDistance;

  @override
  int get hashCode => measureDistance.hashCode;

  @override
  String toString() => 'MeasureLayout{measureDistance: $measureDistance}';
}

enum MeasureNumberingValue { none, measure, system }

@immutable
class MeasureNumbering {
  final MeasureNumberingValue value;
  final String? color;
  final double? defaultX;
  final double? defaultY;
  final String? fontFamily;
  final String? fontSize;
  final String? fontStyle;
  final String? fontWeight;
  final String? halign;
  final bool? multipleRestAlways; // yes-no
  final bool? multipleRestRange; // yes-no
  final double? relativeX;
  final double? relativeY;
  final int? staff; // staff-number
  final String? system; // system-relation-number (can be 'none', 'other', 'default', or a number)
  final String? valign;

  const MeasureNumbering({
    required this.value,
    this.color,
    this.defaultX,
    this.defaultY,
    this.fontFamily,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.halign,
    this.multipleRestAlways,
    this.multipleRestRange,
    this.relativeX,
    this.relativeY,
    this.staff,
    this.system,
    this.valign,
  });

  static MeasureNumberingValue parseValue(String? valueStr) {
    switch (valueStr) {
      case 'none':
        return MeasureNumberingValue.none;
      case 'measure':
        return MeasureNumberingValue.measure;
      case 'system':
        return MeasureNumberingValue.system;
      default:
        // As per spec, if not specified, it's 'measure' if part of <measure-style>,
        // but within <print>, it implies a specific value must be present.
        // However, for robustness, let's default or handle error.
        // For now, defaulting to 'measure' if text is unexpected, though strict parsing might throw.
        return MeasureNumberingValue.measure; // Or throw an exception.
    }
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasureNumbering &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          color == other.color &&
          defaultX == other.defaultX &&
          defaultY == other.defaultY &&
          fontFamily == other.fontFamily &&
          fontSize == other.fontSize &&
          fontStyle == other.fontStyle &&
          fontWeight == other.fontWeight &&
          halign == other.halign &&
          multipleRestAlways == other.multipleRestAlways &&
          multipleRestRange == other.multipleRestRange &&
          relativeX == other.relativeX &&
          relativeY == other.relativeY &&
          staff == other.staff &&
          system == other.system &&
          valign == other.valign;

  @override
  int get hashCode =>
      value.hashCode ^
      color.hashCode ^
      defaultX.hashCode ^
      defaultY.hashCode ^
      fontFamily.hashCode ^
      fontSize.hashCode ^
      fontStyle.hashCode ^
      fontWeight.hashCode ^
      halign.hashCode ^
      multipleRestAlways.hashCode ^
      multipleRestRange.hashCode ^
      relativeX.hashCode ^
      relativeY.hashCode ^
      staff.hashCode ^
      system.hashCode ^
      valign.hashCode;

  @override
  String toString() {
    return 'MeasureNumbering{value: $value, color: $color, defaultX: $defaultX, defaultY: $defaultY, fontFamily: $fontFamily, fontSize: $fontSize, fontStyle: $fontStyle, fontWeight: $fontWeight, halign: $halign, multipleRestAlways: $multipleRestAlways, multipleRestRange: $multipleRestRange, relativeX: $relativeX, relativeY: $relativeY, staff: $staff, system: $system, valign: $valign}';
  }
}
