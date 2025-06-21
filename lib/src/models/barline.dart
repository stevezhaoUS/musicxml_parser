import 'package:meta/meta.dart';

/// Represents a barline in a measure, potentially including repeat information.
@immutable
class Barline {
  /// The location of the barline within the measure (e.g., "left", "right", "middle").
  /// Typically corresponds to the 'location' attribute of the <barline> element.
  final String? location;

  /// The style of the barline (e.g., "light-light", "light-heavy", "none").
  /// Corresponds to the text content of the <bar-style> child element.
  final String? barStyle;

  /// The direction of a repeat mark (e.g., "forward", "backward").
  /// Corresponds to the 'direction' attribute of a <repeat> child element of <barline>.
  final String? repeatDirection;

  /// The number of times a repeat is to be played.
  /// Corresponds to the 'times' attribute of a <repeat> child element (MusicXML 3.0+).
  final int? times;

  /// Creates a new [Barline] instance.
  const Barline({
    this.location,
    this.barStyle,
    this.repeatDirection,
    this.times,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Barline &&
          runtimeType == other.runtimeType &&
          location == other.location &&
          barStyle == other.barStyle &&
          repeatDirection == other.repeatDirection &&
          times == other.times;

  @override
  int get hashCode =>
      (location?.hashCode ?? 0) ^
      (barStyle?.hashCode ?? 0) ^
      (repeatDirection?.hashCode ?? 0) ^
      (times?.hashCode ?? 0);

  @override
  String toString() {
    final parts = <String>[];
    if (location != null) parts.add('location: $location');
    if (barStyle != null) parts.add('barStyle: $barStyle');
    if (repeatDirection != null) parts.add('repeatDirection: $repeatDirection');
    if (times != null) parts.add('times: $times');
    return 'Barline{${parts.join(', ')}}';
  }
}
