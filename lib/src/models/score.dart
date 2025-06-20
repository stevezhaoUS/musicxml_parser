import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/models/appearance.dart';
import 'package:musicxml_parser/src/models/identification.dart';
import 'package:musicxml_parser/src/models/page_layout.dart';
import 'package:musicxml_parser/src/models/part.dart';
import 'package:musicxml_parser/src/models/work.dart';

/// Represents a MusicXML score document.
@immutable
class Score {
  /// The version of MusicXML used.
  final String version;

  /// Information about the musical work.
  final Work? work;

  /// Metadata about the score.
  final Identification? identification;

  /// List of parts in the score.
  final List<Part> parts;

  /// Page layout information.
  final PageLayout? pageLayout;

  /// Scaling information.
  final Scaling? scaling;

  /// Appearance settings.
  final Appearance? appearance;

  /// Creates a new [Score] instance.
  const Score({
    required this.version,
    this.work,
    this.identification,
    required this.parts,
    this.pageLayout,
    this.scaling,
    this.appearance,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Score &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          work == other.work &&
          identification == other.identification &&
          parts == other.parts &&
          pageLayout == other.pageLayout &&
          scaling == other.scaling &&
          appearance == other.appearance;

  @override
  int get hashCode =>
      version.hashCode ^
      (work?.hashCode ?? 0) ^
      (identification?.hashCode ?? 0) ^
      parts.hashCode ^
      (pageLayout?.hashCode ?? 0) ^
      (scaling?.hashCode ?? 0) ^
      (appearance?.hashCode ?? 0);

  @override
  String toString() =>
      'Score{version: $version, work: $work, identification: $identification, parts: ${parts.length}}';
}
