import 'package:meta/meta.dart';

/// Represents a note size specification in a musical score appearance.
///
/// Note sizes specify the relative scaling of different types of notes
/// as a percentage of normal size.
@immutable
class NoteSize {
  /// The type of note this size applies to.
  ///
  /// Common types include: 'cue', 'grace', 'grace-cue'.
  final String type;

  /// The size value as a percentage of normal size.
  ///
  /// For example, a value of 70 means 70% of normal size.
  final double value;

  /// Creates a new [NoteSize] instance.
  const NoteSize({
    required this.type,
    required this.value,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteSize &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode => type.hashCode ^ value.hashCode;

  @override
  String toString() => 'NoteSize{type: $type, value: $value}';
}