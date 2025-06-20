import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/models/repeat.dart';
import 'package:musicxml_parser/src/models/ending.dart';

/// Represents the location of a barline within a measure.
enum BarlineLocation {
  /// Barline at the left side of the measure.
  left,
  
  /// Barline at the right side of the measure.
  right,
  
  /// Barline in the middle of the measure.
  middle,
}

/// Represents the style/type of a barline.
enum BarlineStyle {
  /// Regular barline (single line).
  regular,
  
  /// Light-heavy barline (final barline).
  lightHeavy,
  
  /// Heavy-light barline (start repeat).
  heavyLight,
  
  /// Light-light barline (double barline).
  lightLight,
  
  /// Heavy-heavy barline (heavy double barline).
  heavyHeavy,
  
  /// Dashed barline.
  dashed,
  
  /// Dotted barline.
  dotted,
  
  /// Invisible barline.
  none,
}

/// Represents a barline in a musical score.
/// 
/// Barlines indicate the end of measures and can contain repeats,
/// endings, and other structural information.
/// 
/// Example usage:
/// ```dart
/// // Simple barline
/// const barline = Barline(
///   location: BarlineLocation.right,
///   style: BarlineStyle.regular,
/// );
/// 
/// // Barline with repeat
/// final repeatBarline = Barline(
///   location: BarlineLocation.right,
///   style: BarlineStyle.lightHeavy,
///   repeat: Repeat(direction: RepeatDirection.backward),
/// );
/// ```
@immutable
class Barline {
  /// The location of the barline within the measure.
  final BarlineLocation location;
  
  /// The style/type of the barline.
  final BarlineStyle style;
  
  /// Optional repeat information associated with this barline.
  final Repeat? repeat;
  
  /// Optional ending information associated with this barline.
  final Ending? ending;
  
  /// Creates a new [Barline] instance.
  /// 
  /// [location] specifies where the barline appears in the measure.
  /// [style] specifies the visual appearance of the barline.
  /// [repeat] and [ending] provide optional structural information.
  const Barline({
    required this.location,
    required this.style,
    this.repeat,
    this.ending,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Barline &&
          runtimeType == other.runtimeType &&
          location == other.location &&
          style == other.style &&
          repeat == other.repeat &&
          ending == other.ending;

  @override
  int get hashCode =>
      location.hashCode ^
      style.hashCode ^
      (repeat?.hashCode ?? 0) ^
      (ending?.hashCode ?? 0);

  @override
  String toString() =>
      'Barline{location: $location, style: $style, repeat: $repeat, ending: $ending}';
}