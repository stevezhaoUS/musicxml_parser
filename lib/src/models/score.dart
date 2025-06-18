import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/models/part.dart';

/// Represents a complete musical score.
@immutable
class Score {
  /// The title of the score.
  final String? title;

  /// The composer of the score.
  final String? composer;

  /// The parts contained in the score.
  final List<Part> parts;

  /// The version of MusicXML used.
  final String? version;

  /// The number of divisions per quarter note.
  final int? divisions;

  /// Creates a new [Score] instance.
  const Score({
    this.title,
    this.composer,
    required this.parts,
    this.version,
    this.divisions,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Score &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          composer == other.composer &&
          parts == other.parts &&
          version == other.version &&
          divisions == other.divisions;

  @override
  int get hashCode =>
      (title?.hashCode ?? 0) ^
      (composer?.hashCode ?? 0) ^
      parts.hashCode ^
      (version?.hashCode ?? 0) ^
      (divisions?.hashCode ?? 0);

  @override
  String toString() =>
      'Score{title: $title, composer: $composer, parts: ${parts.length}}';
}
