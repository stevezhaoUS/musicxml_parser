import 'package:meta/meta.dart';

/// Represents a tie mark connecting notes of the same pitch.
@immutable
class Tie {
  /// The type of tie (e.g., "start", "stop").
  /// MusicXML also allows "continue" but it's less common for basic ties.
  final String type;

  /// The placement of the tie relative to the note (e.g., "above", "below").
  /// Optional.
  final String? placement;

  /// Creates a new [Tie] instance.
  const Tie({
    required this.type,
    this.placement,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tie &&
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
    return 'Tie{${parts.join(', ')}}';
  }
}
