import 'package:meta/meta.dart';

/// Represents a slur mark attached to a note.
@immutable
class Slur {
  /// The type of slur (e.g., "start", "stop", "continue").
  final String type; // Consider an enum SlurType in the future

  /// The slur number, used for matching slurs that span multiple notes.
  /// Defaults to 1 if not specified in the MusicXML.
  final int number;

  /// The placement of the slur relative to the note (e.g., "above", "below").
  /// Optional.
  final String? placement; // Consider an enum Placement in the future

  // Other common attributes like orientation, bezier points can be added later.

  /// Creates a new [Slur] instance.
  const Slur({
    required this.type,
    this.number = 1, // MusicXML default for slur number is 1
    this.placement,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Slur &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          number == other.number &&
          placement == other.placement;

  @override
  int get hashCode =>
      type.hashCode ^
      number.hashCode ^
      (placement?.hashCode ?? 0);

  @override
  String toString() {
    final parts = [
      'type: $type',
      'number: $number',
      if (placement != null) 'placement: $placement',
    ];
    return 'Slur{${parts.join(', ')}}';
  }
}
