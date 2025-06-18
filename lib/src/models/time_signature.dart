import 'package:meta/meta.dart';

/// Represents a time signature in a musical score.
@immutable
class TimeSignature {
  /// The numerator of the time signature (beats per measure).
  final int beats;

  /// The denominator of the time signature (beat unit).
  final int beatType;

  /// Creates a new [TimeSignature] instance.
  const TimeSignature({
    required this.beats,
    required this.beatType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSignature &&
          runtimeType == other.runtimeType &&
          beats == other.beats &&
          beatType == other.beatType;

  @override
  int get hashCode => beats.hashCode ^ beatType.hashCode;

  @override
  String toString() => 'TimeSignature{$beats/$beatType}';
}
