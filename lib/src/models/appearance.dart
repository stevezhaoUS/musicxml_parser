import 'package:meta/meta.dart';

/// Represents a line width setting in MusicXML.
@immutable
class LineWidth {
  /// The type of line (e.g., "light barline", "heavy barline", "beam", etc.).
  final String type;

  /// The width value.
  final double width;

  /// Creates a new [LineWidth] instance.
  const LineWidth({
    required this.type,
    required this.width,
  });
}

/// Represents a note size setting in MusicXML.
@immutable
class NoteSize {
  /// The type of note (e.g., "cue", "grace", etc.).
  final String type;

  /// The size value as a percentage.
  final double size;

  /// Creates a new [NoteSize] instance.
  const NoteSize({
    required this.type,
    required this.size,
  });
}

/// Represents appearance settings in a MusicXML document.
@immutable
class Appearance {
  /// Line width settings for different elements.
  final List<LineWidth> lineWidths;

  /// Note size settings for different types of notes.
  final List<NoteSize> noteSizes;

  /// Creates a new [Appearance] instance.
  const Appearance({
    this.lineWidths = const [],
    this.noteSizes = const [],
  });
}
