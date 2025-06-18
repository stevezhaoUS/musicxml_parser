import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';

/// Represents a time signature in a musical score.
@immutable
class TimeSignature {
  /// The numerator of the time signature (beats per measure).
  final int beats;

  /// The denominator of the time signature (beat unit).
  final int beatType;

  /// Creates a new [TimeSignature] instance.
  ///
  /// [beats] must be positive and [beatType] must be a positive power of 2.
  const TimeSignature({
    required this.beats,
    required this.beatType,
  });

  /// Creates a new [TimeSignature] instance with validation.
  ///
  /// This factory constructor performs validation and throws
  /// [MusicXmlValidationException] if the time signature is invalid.
  factory TimeSignature.validated({
    required int beats,
    required int beatType,
    int? line,
    Map<String, dynamic>? context,
  }) {
    final timeSignature = TimeSignature(beats: beats, beatType: beatType);
    ValidationUtils.validateTimeSignature(timeSignature,
        line: line, context: context);
    return timeSignature;
  }

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
