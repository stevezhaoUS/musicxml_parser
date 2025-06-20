import 'package:meta/meta.dart';

/// Represents information about a musical work in a MusicXML file.
///
/// This includes title, composer, and opus information.
@immutable
class Work {
  /// The title of the work.
  final String? title;

  /// The work number (e.g., Symphony No. 5).
  final String? number;

  /// The opus number (e.g., Op. 67).
  final String? opus;

  /// Additional work information.
  final String? description;

  /// Creates a new [Work] instance.
  const Work({
    this.title,
    this.number,
    this.opus,
    this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Work &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          number == other.number &&
          opus == other.opus &&
          description == other.description;

  @override
  int get hashCode =>
      title.hashCode ^ number.hashCode ^ opus.hashCode ^ description.hashCode;
}
