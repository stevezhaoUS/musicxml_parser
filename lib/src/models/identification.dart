import 'package:meta/meta.dart';

/// Represents the identification information in a MusicXML file.
///
/// This includes creator information (composer, lyricist, etc.),
/// rights, encoding information, and source.
@immutable
class Identification {
  /// The composer of the work.
  final String? composer;

  /// The lyricist of the work.
  final String? lyricist;

  /// The arranger of the work.
  final String? arranger;

  /// Copyright notice for the score.
  final String? rights;

  /// Information about the source of the score.
  final String? source;

  /// Information about the encoding of the score.
  final Encoding? encoding;

  /// Creates a new [Identification] instance.
  const Identification({
    this.composer,
    this.lyricist,
    this.arranger,
    this.rights,
    this.source,
    this.encoding,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Identification &&
          runtimeType == other.runtimeType &&
          composer == other.composer &&
          lyricist == other.lyricist &&
          arranger == other.arranger &&
          rights == other.rights &&
          source == other.source &&
          encoding == other.encoding;

  @override
  int get hashCode =>
      composer.hashCode ^
      lyricist.hashCode ^
      arranger.hashCode ^
      rights.hashCode ^
      source.hashCode ^
      encoding.hashCode;
}

/// Represents encoding information in the score.
@immutable
class Encoding {
  /// The software used to create the score.
  final String? software;

  /// The date when the score was encoded.
  final String? encodingDate;

  /// The description of the encoding.
  final String? description;

  /// Creates a new [Encoding] instance.
  const Encoding({
    this.software,
    this.encodingDate,
    this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Encoding &&
          runtimeType == other.runtimeType &&
          software == other.software &&
          encodingDate == other.encodingDate &&
          description == other.description;

  @override
  int get hashCode =>
      software.hashCode ^ encodingDate.hashCode ^ description.hashCode;
}
