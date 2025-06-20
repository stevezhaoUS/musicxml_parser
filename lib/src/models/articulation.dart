import 'package:meta/meta.dart';

/// Represents a musical articulation mark.
@immutable
class Articulation {
  /// The type of articulation, corresponding to the MusicXML element name
  /// (e.g., "accent", "staccato", "tenuto").
  final String type;

  /// The placement of the articulation relative to the note (e.g., "above", "below").
  /// Optional.
  final String? placement; // Consider an enum Placement in the future

  /// Creates a new [Articulation] instance.
  const Articulation({
    required this.type,
    this.placement,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Articulation &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          placement == other.placement;

  @override
  int get hashCode => type.hashCode ^ (placement?.hashCode ?? 0);

  @override
  String toString() {
    final parts = [
      'type: $type',
      if (placement != null) 'placement: $placement',
    ];
    return 'Articulation{${parts.join(', ')}}';
  }
}
