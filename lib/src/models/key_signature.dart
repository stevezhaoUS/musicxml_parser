import 'package:meta/meta.dart';

/// Represents a key signature in a musical score.
@immutable
class KeySignature {
  /// The number of sharps (positive) or flats (negative) in the key signature.
  final int fifths;

  /// The mode of the key signature (major, minor, etc.).
  final String? mode;

  /// Creates a new [KeySignature] instance.
  const KeySignature({
    required this.fifths,
    this.mode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeySignature &&
          runtimeType == other.runtimeType &&
          fifths == other.fifths &&
          mode == other.mode;

  @override
  int get hashCode => fifths.hashCode ^ (mode?.hashCode ?? 0);

  @override
  String toString() => 'KeySignature{fifths: $fifths, mode: $mode}';
}
