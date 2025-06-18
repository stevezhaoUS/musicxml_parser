import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';

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

  /// Creates a new [Note] instance with validation.
  ///
  /// This factory constructor performs comprehensive validation and throws
  /// [MusicXmlValidationException] if the note is invalid.
  factory Note.validated({
    Pitch? pitch,
    required Duration duration,
    bool isRest = false,
    String? lyric,
    int? voice,
    String? type,
    bool tiedStart = false,
    bool tiedEnd = false,
    int? line,
    Map<String, dynamic>? context,
  }) {
    // Perform validation first, before creating the Note
    // This allows us to provide better error messages

    // Validate duration
    ValidationUtils.validateDuration(duration, line: line, context: context);

    // Validate pitch if not a rest
    if (!isRest && pitch != null) {
      ValidationUtils.validatePitch(pitch, line: line, context: context);
    }

    // Validate voice (should be positive if specified)
    if (voice != null && voice <= 0) {
      throw MusicXmlValidationException(
        'Note voice must be positive, got $voice',
        rule: 'note_voice_validation',
        line: line,
        context: {
          'voice': voice,
          'isRest': isRest,
          ...?context,
        },
      );
    }

    // Validate that rests don't have pitches
    if (isRest && pitch != null) {
      throw MusicXmlValidationException(
        'Rest notes should not have pitch information',
        rule: 'rest_no_pitch_validation',
        line: line,
        context: {
          'isRest': isRest,
          'hasPitch': true,
          ...?context,
        },
      );
    }

    // Validate that non-rest notes have pitches (unless it's a special case)
    if (!isRest && pitch == null) {
      throw MusicXmlValidationException(
        'Non-rest notes must have pitch information',
        rule: 'note_pitch_required_validation',
        line: line,
        context: {
          'isRest': isRest,
          'hasPitch': false,
          ...?context,
        },
      );
    }

    // Create the Note - this will still trigger the assertion if validation missed something
    return Note(
      pitch: pitch,
      duration: duration,
      isRest: isRest,
      lyric: lyric,
      voice: voice,
      type: type,
      tiedStart: tiedStart,
      tiedEnd: tiedEnd,
    );
  }

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
