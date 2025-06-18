import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';

/// Represents a key signature in a musical score.
@immutable
class KeySignature {
  /// The number of sharps (positive) or flats (negative) in the key signature.
  final int fifths;

  /// The mode of the key signature (major, minor, etc.).
  final String? mode;

  /// Creates a new [KeySignature] instance.
  /// 
  /// The [fifths] value should be between -7 and +7.
  const KeySignature({
    required this.fifths,
    this.mode,
  });

  /// Creates a new [KeySignature] instance with validation.
  /// 
  /// This factory constructor performs validation and throws
  /// [MusicXmlValidationException] if the key signature is invalid.
  factory KeySignature.validated({
    required int fifths,
    String? mode,
    int? line,
    Map<String, dynamic>? context,
  }) {
    final keySignature = KeySignature(fifths: fifths, mode: mode);
    ValidationUtils.validateKeySignature(keySignature, line: line, context: context);
    return keySignature;
  }

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
