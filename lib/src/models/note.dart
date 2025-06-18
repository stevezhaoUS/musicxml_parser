import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/pitch.dart';

/// Represents a musical note in a score.
@immutable
class Note {
  /// The pitch of the note.
  final Pitch? pitch;

  /// The duration of the note.
  final Duration duration;

  /// Indicates whether this note is a rest.
  final bool isRest;

  /// The lyric text associated with this note, if any.
  final String? lyric;

  /// Additional voice information for multi-voice measures.
  final int? voice;

  /// The type of the note (e.g., "quarter", "eighth", etc.).
  final String? type;

  /// Indicates whether this note is tied to the next note.
  final bool tiedStart;

  /// Indicates whether this note is tied to the previous note.
  final bool tiedEnd;

  /// Creates a new [Note] instance.
  const Note({
    this.pitch,
    required this.duration,
    this.isRest = false,
    this.lyric,
    this.voice,
    this.type,
    this.tiedStart = false,
    this.tiedEnd = false,
  }) : assert(isRest ? pitch == null : pitch != null,
            'A rest must not have a pitch, and a note must have a pitch');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          pitch == other.pitch &&
          duration == other.duration &&
          isRest == other.isRest &&
          lyric == other.lyric &&
          voice == other.voice &&
          type == other.type &&
          tiedStart == other.tiedStart &&
          tiedEnd == other.tiedEnd;

  @override
  int get hashCode =>
      pitch.hashCode ^
      duration.hashCode ^
      isRest.hashCode ^
      lyric.hashCode ^
      (voice?.hashCode ?? 0) ^
      (type?.hashCode ?? 0) ^
      tiedStart.hashCode ^
      tiedEnd.hashCode;

  @override
  String toString() => isRest
      ? 'Rest{duration: $duration}'
      : 'Note{pitch: $pitch, duration: $duration, lyric: $lyric}';
}
