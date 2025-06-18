import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';

/// Represents the duration of a note or rest in a musical score.
@immutable
class Duration {
  /// The duration value, in divisions per quarter note.
  final int value;

  /// The number of divisions per quarter note in the score.
  final int divisions;

  /// Creates a new [Duration] instance.
  /// 
  /// Both [value] and [divisions] must be positive.
  const Duration({
    required this.value,
    required this.divisions,
  });

  /// Creates a new [Duration] instance with validation.
  /// 
  /// This factory constructor performs validation and throws
  /// [MusicXmlValidationException] if the duration values are invalid.
  factory Duration.validated({
    required int value,
    required int divisions,
    int? line,
    Map<String, dynamic>? context,
  }) {
    final duration = Duration(value: value, divisions: divisions);
    ValidationUtils.validateDuration(duration, line: line, context: context);
    return duration;
  }

  /// Gets the duration in quarter notes.
  double get inQuarterNotes => value / divisions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Duration &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          divisions == other.divisions;

  @override
  int get hashCode => value.hashCode ^ divisions.hashCode;

  @override
  String toString() => 'Duration{value: $value, divisions: $divisions}';
}
