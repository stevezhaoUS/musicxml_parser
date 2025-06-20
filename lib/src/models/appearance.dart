import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/models/line_width.dart';
import 'package:musicxml_parser/src/models/note_size.dart';

/// Represents appearance settings for a musical score.
///
/// The appearance element controls the visual formatting of musical elements
/// including line widths and note sizes.
@immutable
class Appearance {
  /// List of line width specifications.
  final List<LineWidth> lineWidths;

  /// List of note size specifications.
  final List<NoteSize> noteSizes;

  /// Creates a new [Appearance] instance.
  const Appearance({
    this.lineWidths = const [],
    this.noteSizes = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Appearance &&
          runtimeType == other.runtimeType &&
          _listEquals(lineWidths, other.lineWidths) &&
          _listEquals(noteSizes, other.noteSizes);

  @override
  int get hashCode => 
      lineWidths.fold(0, (prev, elem) => prev ^ elem.hashCode) ^
      noteSizes.fold(0, (prev, elem) => prev ^ elem.hashCode);

  @override
  String toString() => 
      'Appearance{lineWidths: ${lineWidths.length}, noteSizes: ${noteSizes.length}}';

  /// Helper method to compare lists for equality.
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}