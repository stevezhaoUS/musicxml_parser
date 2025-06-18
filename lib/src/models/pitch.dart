import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';

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
  /// 
  /// Validates that the step is one of C, D, E, F, G, A, B and
  /// the octave is within the valid range (0-9).
  /// 
  /// Throws [MusicXmlValidationException] if validation fails.
  const Pitch({
    required this.step,
    required this.octave,
    this.alter,
  });

  /// Creates a new [Pitch] instance with validation.
  /// 
  /// This factory constructor performs validation and throws
  /// [MusicXmlValidationException] if the pitch is invalid.
  factory Pitch.validated({
    required String step,
    required int octave,
    int? alter,
    int? line,
    Map<String, dynamic>? context,
  }) {
    final pitch = Pitch(step: step, octave: octave, alter: alter);
    ValidationUtils.validatePitch(pitch, line: line, context: context);
    return pitch;
  }

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
