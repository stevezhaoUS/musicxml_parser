import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/models/time_modification.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';

/// Represents a musical note in a score.
@immutable
class Note {
  /// The pitch of the note.
  final Pitch? pitch;

  /// The duration of the note.
  final Duration? duration;

  /// Indicates whether this note is a rest.
  final bool isRest;

  /// Additional voice information for multi-voice measures.
  final int? voice;

  /// The type of the note (e.g., "quarter", "eighth", etc.).
  final String? type;

  /// The number of dots on the note.
  final int? dots;

  /// Time modification information, e.g. for tuplets.
  final TimeModification? timeModification;

  /// Creates a new [Note] instance.
  const Note({
    this.pitch,
    this.duration,
    this.isRest = false,
    this.voice,
    this.type,
    this.dots,
    this.timeModification,
  }) : assert(isRest ? pitch == null : pitch != null,
            'A rest must not have a pitch, and a note must have a pitch');

  /// Creates a new [Note] instance with validation.
  ///
  /// This factory constructor performs comprehensive validation and throws
  /// [MusicXmlValidationException] if the note is invalid.
  factory Note.validated({
    Pitch? pitch,
    Duration? duration,
    bool isRest = false,
    int? voice,
    String? type,
    int? dots,
    TimeModification? timeModification,
    int? line,
    Map<String, dynamic>? context,
  }) {
    // Perform validation first, before creating the Note
    // This allows us to provide better error messages

    // Validate duration if present
    if (duration != null) {
      ValidationUtils.validateDuration(duration, line: line, context: context);
    }

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

    // Validate dots (should be non-negative if specified)
    if (dots != null && dots < 0) {
      throw MusicXmlValidationException(
        'Note dots must be non-negative, got $dots',
        rule: 'note_dots_validation',
        line: line,
        context: {
          'dots': dots,
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
      voice: voice,
      type: type,
      dots: dots,
      timeModification: timeModification,
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
          voice == other.voice &&
          type == other.type &&
          dots == other.dots &&
          timeModification == other.timeModification;

  @override
  int get hashCode =>
      pitch.hashCode ^
      (duration?.hashCode ?? 0) ^
      isRest.hashCode ^
      (voice?.hashCode ?? 0) ^
      (type?.hashCode ?? 0) ^
      (dots?.hashCode ?? 0) ^
      (timeModification?.hashCode ?? 0);

  @override
  String toString() {
    final StringBuffer sb = StringBuffer();
    if (isRest) {
      sb.write('Rest{duration: $duration');
    } else {
      sb.write('Note{pitch: $pitch, duration: $duration');
    }
    if (dots != null && dots! > 0) {
      sb.write(', dots: $dots');
    }
    if (timeModification != null) {
      sb.write(', timeModification: $timeModification');
    }
    sb.write('}');
    return sb.toString();
  }
}
