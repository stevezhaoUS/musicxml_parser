import 'package:meta/meta.dart';

/// Represents a pitch in music notation.
@immutable
class Pitch {
  /// The step of the pitch (C, D, E, F, G, A, B).
  final String step;

  /// The octave number.
  final int octave;

  /// The alteration of the pitch (-1 for flat, 1 for sharp, etc.).
  final int? alter;

  /// Creates a new [Pitch] instance.
  const Pitch({
    required this.step,
    required this.octave,
    this.alter,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pitch &&
          runtimeType == other.runtimeType &&
          step == other.step &&
          octave == other.octave &&
          alter == other.alter;

  @override
  int get hashCode => step.hashCode ^ octave.hashCode ^ (alter?.hashCode ?? 0);

  @override
  String toString() => 'Pitch{step: $step, octave: $octave, alter: $alter}';
}
