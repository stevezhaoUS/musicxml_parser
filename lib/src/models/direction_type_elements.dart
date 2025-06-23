import 'package:meta/meta.dart';

@immutable
abstract class DirectionTypeElement {
  const DirectionTypeElement();
}

@immutable
class Segno extends DirectionTypeElement {
  final String? color;
  final double? defaultX;
  final double? defaultY;
  final String? fontFamily;
  final String? fontSize;
  final String? fontStyle;
  final String? fontWeight;
  final String? halign;
  final String? id;
  final double? relativeX;
  final double? relativeY;
  final String? smufl;
  final String? valign;

  const Segno({
    this.color,
    this.defaultX,
    this.defaultY,
    this.fontFamily,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.halign,
    this.id,
    this.relativeX,
    this.relativeY,
    this.smufl,
    this.valign,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Segno &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          defaultX == other.defaultX &&
          defaultY == other.defaultY &&
          fontFamily == other.fontFamily &&
          fontSize == other.fontSize &&
          fontStyle == other.fontStyle &&
          fontWeight == other.fontWeight &&
          halign == other.halign &&
          id == other.id &&
          relativeX == other.relativeX &&
          relativeY == other.relativeY &&
          smufl == other.smufl &&
          valign == other.valign;

  @override
  int get hashCode =>
      color.hashCode ^
      defaultX.hashCode ^
      defaultY.hashCode ^
      fontFamily.hashCode ^
      fontSize.hashCode ^
      fontStyle.hashCode ^
      fontWeight.hashCode ^
      halign.hashCode ^
      id.hashCode ^
      relativeX.hashCode ^
      relativeY.hashCode ^
      smufl.hashCode ^
      valign.hashCode;

  @override
  String toString() {
    return 'Segno{color: $color, defaultX: $defaultX, defaultY: $defaultY, fontFamily: $fontFamily, fontSize: $fontSize, fontStyle: $fontStyle, fontWeight: $fontWeight, halign: $halign, id: $id, relativeX: $relativeX, relativeY: $relativeY, smufl: $smufl, valign: $valign}';
  }
}

@immutable
class Coda extends DirectionTypeElement {
  final String? color;
  final double? defaultX;
  final double? defaultY;
  final String? fontFamily;
  final String? fontSize;
  final String? fontStyle;
  final String? fontWeight;
  final String? halign;
  final String? id;
  final double? relativeX;
  final double? relativeY;
  final String? smufl;
  final String? valign;

  const Coda({
    this.color,
    this.defaultX,
    this.defaultY,
    this.fontFamily,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.halign,
    this.id,
    this.relativeX,
    this.relativeY,
    this.smufl,
    this.valign,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coda &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          defaultX == other.defaultX &&
          defaultY == other.defaultY &&
          fontFamily == other.fontFamily &&
          fontSize == other.fontSize &&
          fontStyle == other.fontStyle &&
          fontWeight == other.fontWeight &&
          halign == other.halign &&
          id == other.id &&
          relativeX == other.relativeX &&
          relativeY == other.relativeY &&
          smufl == other.smufl &&
          valign == other.valign;

  @override
  int get hashCode =>
      color.hashCode ^
      defaultX.hashCode ^
      defaultY.hashCode ^
      fontFamily.hashCode ^
      fontSize.hashCode ^
      fontStyle.hashCode ^
      fontWeight.hashCode ^
      halign.hashCode ^
      id.hashCode ^
      relativeX.hashCode ^
      relativeY.hashCode ^
      smufl.hashCode ^
      valign.hashCode;

  @override
  String toString() {
    return 'Coda{color: $color, defaultX: $defaultX, defaultY: $defaultY, fontFamily: $fontFamily, fontSize: $fontSize, fontStyle: $fontStyle, fontWeight: $fontWeight, halign: $halign, id: $id, relativeX: $relativeX, relativeY: $relativeY, smufl: $smufl, valign: $valign}';
  }
}

@immutable
class Dynamics extends DirectionTypeElement {
  final String? color;
  final double? defaultX;
  final double? defaultY;
  final String? enclosure;
  final String? fontFamily;
  final String? fontSize;
  final String? fontStyle;
  final String? fontWeight;
  final String? halign;
  final String? id;
  final int? lineThrough;
  final int? overline;
  final String? placement;
  final double? relativeX;
  final double? relativeY;
  final int? underline;
  final String? valign;
  final List<String>
      values; // e.g. ["p", "f", "sfz"] or ["other-dynamics"] content

  const Dynamics({
    this.color,
    this.defaultX,
    this.defaultY,
    this.enclosure,
    this.fontFamily,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.halign,
    this.id,
    this.lineThrough,
    this.overline,
    this.placement,
    this.relativeX,
    this.relativeY,
    this.underline,
    this.valign,
    this.values = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dynamics &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          defaultX == other.defaultX &&
          defaultY == other.defaultY &&
          enclosure == other.enclosure &&
          fontFamily == other.fontFamily &&
          fontSize == other.fontSize &&
          fontStyle == other.fontStyle &&
          fontWeight == other.fontWeight &&
          halign == other.halign &&
          id == other.id &&
          lineThrough == other.lineThrough &&
          overline == other.overline &&
          placement == other.placement &&
          relativeX == other.relativeX &&
          relativeY == other.relativeY &&
          underline == other.underline &&
          valign == other.valign &&
          ListEquality().equals(values, other.values);

  @override
  int get hashCode =>
      color.hashCode ^
      defaultX.hashCode ^
      defaultY.hashCode ^
      enclosure.hashCode ^
      fontFamily.hashCode ^
      fontSize.hashCode ^
      fontStyle.hashCode ^
      fontWeight.hashCode ^
      halign.hashCode ^
      id.hashCode ^
      lineThrough.hashCode ^
      overline.hashCode ^
      placement.hashCode ^
      relativeX.hashCode ^
      relativeY.hashCode ^
      underline.hashCode ^
      valign.hashCode ^
      ListEquality().hash(values);

  @override
  String toString() {
    return 'Dynamics{color: $color, defaultX: $defaultX, defaultY: $defaultY, enclosure: $enclosure, fontFamily: $fontFamily, fontSize: $fontSize, fontStyle: $fontStyle, fontWeight: $fontWeight, halign: $halign, id: $id, lineThrough: $lineThrough, overline: $overline, placement: $placement, relativeX: $relativeX, relativeY: $relativeY, underline: $underline, valign: $valign, values: $values}';
  }
}

// Helper for list equality, can be moved to a utility file if needed
class ListEquality {
  bool equals(List? a, List? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int hash(List? a) {
    if (a == null) return 0;
    return a.fold(0, (prev, element) => prev ^ element.hashCode);
  }
}
