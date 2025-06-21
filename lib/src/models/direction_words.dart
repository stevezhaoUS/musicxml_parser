import 'package:meta/meta.dart';
import 'direction_type_elements.dart';

/// Represents a textual direction from a <words> element within a <direction>.
@immutable
class WordsDirection extends DirectionTypeElement {
  /// The text content of the <words> element.
  final String text;

  // Attributes from <words> element
  final String? color;
  final double? defaultX;
  final double? defaultY;
  final String? dir; // text-direction
  final String? enclosure; // enclosure-shape
  final String? fontFamily;
  final String? fontSize; // font-size (CSS size or numeric point size)
  final String? fontStyle; // font-style (normal or italic)
  final String? fontWeight; // font-weight (normal or bold)
  final String? halign; // left-center-right
  final String? id;
  final String? justify; // left-center-right
  final String? letterSpacing; // number-or-normal
  final String? lineHeight; // number-or-normal
  final int? lineThrough; // number-of-lines
  final int? overline; // number-of-lines
  final double? relativeX;
  final double? relativeY;
  final double? rotation; // rotation-degrees
  final int? underline; // number-of-lines
  final String? valign; // valign
  final String? xmlLang;
  final String? xmlSpace; // preserve or default

  /// Creates a new [WordsDirection] instance.
  const WordsDirection({
    required this.text,
    this.color,
    this.defaultX,
    this.defaultY,
    this.dir,
    this.enclosure,
    this.fontFamily,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.halign,
    this.id,
    this.justify,
    this.letterSpacing,
    this.lineHeight,
    this.lineThrough,
    this.overline,
    this.relativeX,
    this.relativeY,
    this.rotation,
    this.underline,
    this.valign,
    this.xmlLang,
    this.xmlSpace,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordsDirection &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          color == other.color &&
          defaultX == other.defaultX &&
          defaultY == other.defaultY &&
          dir == other.dir &&
          enclosure == other.enclosure &&
          fontFamily == other.fontFamily &&
          fontSize == other.fontSize &&
          fontStyle == other.fontStyle &&
          fontWeight == other.fontWeight &&
          halign == other.halign &&
          id == other.id &&
          justify == other.justify &&
          letterSpacing == other.letterSpacing &&
          lineHeight == other.lineHeight &&
          lineThrough == other.lineThrough &&
          overline == other.overline &&
          relativeX == other.relativeX &&
          relativeY == other.relativeY &&
          rotation == other.rotation &&
          underline == other.underline &&
          valign == other.valign &&
          xmlLang == other.xmlLang &&
          xmlSpace == other.xmlSpace;

  @override
  int get hashCode =>
      text.hashCode ^
      color.hashCode ^
      defaultX.hashCode ^
      defaultY.hashCode ^
      dir.hashCode ^
      enclosure.hashCode ^
      fontFamily.hashCode ^
      fontSize.hashCode ^
      fontStyle.hashCode ^
      fontWeight.hashCode ^
      halign.hashCode ^
      id.hashCode ^
      justify.hashCode ^
      letterSpacing.hashCode ^
      lineHeight.hashCode ^
      lineThrough.hashCode ^
      overline.hashCode ^
      relativeX.hashCode ^
      relativeY.hashCode ^
      rotation.hashCode ^
      underline.hashCode ^
      valign.hashCode ^
      xmlLang.hashCode ^
      xmlSpace.hashCode;

  @override
  String toString() => 'WordsDirection{text: "$text", '
      'fontFamily: $fontFamily, fontSize: $fontSize, defaultX: $defaultX, defaultY: $defaultY, '
      'halign: $halign, valign: $valign, color: $color, dir: $dir, enclosure: $enclosure, '
      'fontStyle: $fontStyle, fontWeight: $fontWeight, id: $id, justify: $justify, '
      'letterSpacing: $letterSpacing, lineHeight: $lineHeight, lineThrough: $lineThrough, '
      'overline: $overline, relativeX: $relativeX, relativeY: $relativeY, rotation: $rotation, '
      'underline: $underline, xmlLang: $xmlLang, xmlSpace: $xmlSpace}';
}
