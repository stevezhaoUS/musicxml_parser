import 'package:meta/meta.dart';

/// Represents the duration of a note or rest in a musical score.
@immutable
class Duration {
  /// The duration value, in divisions per quarter note.
  final int value;

  /// The number of divisions per quarter note in the score.
  final int divisions;

  /// Creates a new [Duration] instance.
  const Duration({
    required this.value,
    required this.divisions,
  });

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
