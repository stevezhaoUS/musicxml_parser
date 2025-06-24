import 'package:meta/meta.dart';
import 'package:collection/collection.dart'; // For DeepCollectionEquality
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/articulation.dart';
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/models/slur.dart';
import 'package:musicxml_parser/src/models/tie.dart';
import 'package:musicxml_parser/src/models/time_modification.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';

/// 符干方向枚举
enum StemDirection { up, down, doubleStem, none }

/// Accidental枚举，表示音符的变音记号。
enum Accidental {
  sharp,
  flat,
  natural,
  doubleSharp,
  doubleFlat,
  sharpSharp,
  flatFlat,
  quarterSharp,
  quarterFlat,
  other,
}

/// Represents a musical note or rest in a score.
///
/// This class encapsulates all properties of a note, such as its [pitch] (if not a rest),
/// [duration], [type] (e.g., "quarter", "eighth"), [voice], [dots],
/// articulations, slurs, ties, and time modification for tuplets.
///
/// It also indicates if the note is a [isRest] or part of a chord via [isChordElementPresent].
///
/// Instances are typically created via [Note.validated] factory or [NoteBuilder]
/// to ensure all MusicXML validation rules are applied.
/// Objects of this class are immutable.
@immutable
class Note {
  /// The pitch of the note. Null if this is a rest.
  final Pitch? pitch;

  /// The duration of the note.
  final Duration? duration;

  /// Indicates whether this note is a rest. If true, [pitch] must be null.
  final bool isRest;

  /// The voice number for multi-voice music within a staff.
  final int? voice;

  /// The staff number for multi-staff music (e.g., piano grand staff). Null if not specified.
  final int? staff;

  /// The graphical type of the note (e.g., "quarter", "eighth", "whole").
  final String? type;

  /// The number of augmentation dots on the note.
  final int? dots;

  /// Time modification information, e.g., for tuplets.
  final TimeModification? timeModification;

  /// A list of slurs starting or ending on this note.
  final List<Slur>? slurs;

  /// A list of articulations (e.g., staccato, accent) applied to this note.
  final List<Articulation>? articulations;

  /// A list of ties connecting this note to an adjacent note.
  final List<Tie>? ties;

  /// True if the MusicXML `<chord/>` element was present for this note,
  /// indicating it shares a stem with the preceding note.
  final bool isChordElementPresent;

  /// 符干方向，来自<stem>元素，可为up/down/double/none/null
  final StemDirection? stemDirection;

  /// The accidental associated with the note (e.g., "sharp", "flat"). Null if none.
  final Accidental? accidental;

  /// Default X position
  final double? defaultX;

  /// Creates a new [Note] instance.
  ///
  /// Basic structural validation (e.g., a rest cannot have a pitch) is
  /// performed via an assertion. For comprehensive MusicXML validation,
  /// use the [Note.validated] factory or [NoteBuilder].
  const Note({
    this.pitch,
    this.duration,
    this.isRest = false,
    this.voice,
    this.staff,
    this.type,
    this.dots,
    this.timeModification,
    this.slurs,
    this.articulations,
    this.ties,
    this.isChordElementPresent = false,
    this.stemDirection,
    this.accidental,
    this.defaultX,
  }) : assert(isRest ? pitch == null : pitch != null,
            'A rest must not have a pitch, and a non-rest note must have a pitch.');

  /// Creates a new [Note] instance with comprehensive validation.
  ///
  /// This factory constructor checks various MusicXML rules, such as:
  /// - Duration validity.
  /// - Pitch validity (if not a rest).
  /// - Voice number must be positive if specified.
  /// - Dot count must be non-negative if specified.
  /// - Rests must not have pitch information.
  /// - Non-rest notes must have pitch information.
  ///
  /// Throws [MusicXmlValidationException] if any validation rule is violated.
  ///
  /// Parameters are the same as the default constructor, with additional
  /// [line] and [context] for error reporting.
  factory Note.validated({
    Pitch? pitch,
    Duration? duration,
    bool isRest = false,
    int? voice,
    int? staff,
    String? type,
    int? dots,
    TimeModification? timeModification,
    List<Slur>? slurs,
    List<Articulation>? articulations,
    List<Tie>? ties,
    bool isChordElementPresent = false,
    StemDirection? stemDirection,
    Accidental? accidental,
    double? defaultX,
    int? line,
    Map<String, dynamic>? context,
  }) {
    // Perform validation first
    if (duration != null) {
      ValidationUtils.validateDuration(duration, line: line, context: context);
    }
    if (!isRest && pitch != null) {
      ValidationUtils.validatePitch(pitch, line: line, context: context);
    }

    if (voice != null && voice <= 0) {
      throw MusicXmlValidationException(
        'Note voice must be positive, got $voice',
        rule: 'note_voice_validation',
        line: line,
        context: {'voice': voice, 'isRest': isRest, ...?context},
      );
    }

    if (dots != null && dots < 0) {
      throw MusicXmlValidationException(
        'Note dots must be non-negative, got $dots',
        rule: 'note_dots_validation',
        line: line,
        context: {'dots': dots, ...?context},
      );
    }

    if (isRest && pitch != null) {
      throw MusicXmlValidationException(
        'Rest notes should not have pitch information.',
        rule: 'rest_no_pitch_validation',
        line: line,
        context: {'isRest': isRest, 'hasPitch': true, ...?context},
      );
    }

    if (!isRest && pitch == null) {
      throw MusicXmlValidationException(
        'Non-rest notes must have pitch information.',
        rule: 'note_pitch_required_validation',
        line: line,
        context: {'isRest': isRest, 'hasPitch': false, ...?context},
      );
    }

    return Note(
      pitch: pitch,
      duration: duration,
      isRest: isRest,
      voice: voice,
      staff: staff,
      type: type,
      dots: dots,
      timeModification: timeModification,
      slurs: slurs,
      articulations: articulations,
      ties: ties,
      isChordElementPresent: isChordElementPresent,
      stemDirection: stemDirection,
      accidental: accidental,
      defaultX: defaultX,
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
          staff == other.staff &&
          type == other.type &&
          dots == other.dots &&
          timeModification == other.timeModification &&
          const DeepCollectionEquality().equals(slurs, other.slurs) &&
          const DeepCollectionEquality()
              .equals(articulations, other.articulations) &&
          const DeepCollectionEquality().equals(ties, other.ties) &&
          isChordElementPresent == other.isChordElementPresent &&
          defaultX == other.defaultX;

  @override
  int get hashCode =>
      pitch.hashCode ^
      (duration?.hashCode ?? 0) ^
      isRest.hashCode ^
      (voice?.hashCode ?? 0) ^
      (staff?.hashCode ?? 0) ^
      (type?.hashCode ?? 0) ^
      (dots?.hashCode ?? 0) ^
      (timeModification?.hashCode ?? 0) ^
      (slurs != null ? const DeepCollectionEquality().hash(slurs!) : 0) ^
      (articulations != null
          ? const DeepCollectionEquality().hash(articulations!)
          : 0) ^
      (ties != null ? const DeepCollectionEquality().hash(ties!) : 0) ^
      isChordElementPresent.hashCode ^
      (defaultX?.hashCode ?? 0);

  @override
  String toString() {
    final StringBuffer sb = StringBuffer();
    if (isRest) {
      sb.write('Rest{duration: $duration');
    } else {
      sb.write('Note{pitch: $pitch, duration: $duration');
    }
    if (staff != null) {
      sb.write(', staff: $staff');
    }
    if (dots != null && dots! > 0) {
      sb.write(', dots: $dots');
    }
    if (timeModification != null) {
      sb.write(', timeModification: $timeModification');
    }
    if (slurs != null && slurs!.isNotEmpty) {
      sb.write(', slurs: $slurs');
    }
    if (articulations != null && articulations!.isNotEmpty) {
      sb.write(', articulations: $articulations');
    }
    if (ties != null && ties!.isNotEmpty) {
      sb.write(', ties: $ties');
    }
    if (isChordElementPresent) {
      sb.write(', isChordNote: true');
    }
    if (defaultX != null) {
      sb.write(', defaultX: $defaultX');
    }
    sb.write('}');
    return sb.toString();
  }
}

/// Builder for creating [Note] objects incrementally.
///
/// This builder is useful during the parsing process where note properties
/// are discovered and set step-by-step. The [build] method finalizes
/// the note construction and performs validation using [Note.validated].
///
/// Example:
/// ```dart
/// final noteBuilder = NoteBuilder(line: 10, context: {'measure': '1'});
/// noteBuilder
///   .setPitch(Pitch(step: 'C', octave: 4))
///   .setDuration(Duration(value: 4, divisions: 1))
///   .setType('quarter');
/// final Note note = noteBuilder.build();
/// ```
class NoteBuilder {
  Pitch? _pitch;
  Duration? _duration;
  bool _isRest = false;
  int? _voice;
  String? _type;
  int? _dots;
  TimeModification? _timeModification;
  List<Slur>? _slurs;
  List<Articulation>? _articulations;
  List<Tie>? _ties;
  bool _isChordElementPresent = false;
  int? _staff; // Added for staff support
  StemDirection? _stemDirection;
  Accidental? accidental;
  double? defaultX;

  final int? _line;
  final Map<String, dynamic>? _context;

  /// Creates a [NoteBuilder].
  ///
  /// [line] and [context] can be provided for more detailed error
  /// messages if validation fails during the [build] process.
  NoteBuilder({int? line, Map<String, dynamic>? context})
      : _line = line,
        _context = context;

  /// Sets the staff number for the note.
  NoteBuilder setStaff(int? staff) {
    _staff = staff;
    return this;
  }

  /// Sets the pitch of the note.
  NoteBuilder setPitch(Pitch? pitch) {
    _pitch = pitch;
    return this;
  }

  /// Sets the duration of the note.
  NoteBuilder setDuration(Duration? duration) {
    _duration = duration;
    return this;
  }

  /// Sets whether the note is a rest.
  NoteBuilder setIsRest(bool isRest) {
    _isRest = isRest;
    return this;
  }

  /// Sets the voice of the note.
  NoteBuilder setVoice(int? voice) {
    _voice = voice;
    return this;
  }

  /// Sets the graphical type of the note (e.g., "quarter").
  NoteBuilder setType(String? type) {
    _type = type;
    return this;
  }

  /// Sets the number of augmentation dots.
  NoteBuilder setDots(int? dots) {
    _dots = dots;
    return this;
  }

  /// Sets the time modification (e.g., for tuplets).
  NoteBuilder setTimeModification(TimeModification? timeModification) {
    _timeModification = timeModification;
    return this;
  }

  /// Sets the list of slurs associated with the note.
  NoteBuilder setSlurs(List<Slur>? slurs) {
    _slurs = slurs;
    return this;
  }

  /// Sets the list of articulations for the note.
  NoteBuilder setArticulations(List<Articulation>? articulations) {
    _articulations = articulations;
    return this;
  }

  /// Sets the list of ties for the note.
  NoteBuilder setTies(List<Tie>? ties) {
    _ties = ties;
    return this;
  }

  /// Sets whether the note is part of a chord (i.e., `<chord/>` element was present).
  NoteBuilder setIsChordElementPresent(bool isChordElementPresent) {
    _isChordElementPresent = isChordElementPresent;
    return this;
  }

  /// Sets the stem direction of the note.
  NoteBuilder setStemDirection(StemDirection? stemDirection) {
    _stemDirection = stemDirection;
    return this;
  }

  /// Sets the accidental of the note.
  NoteBuilder setAccidental(Accidental? accidental) {
    this.accidental = accidental;
    return this;
  }

  /// Sets the default X position of the note.
  NoteBuilder setDefaultX(double? x) {
    defaultX = x;
    return this;
  }

  /// Builds and validates the [Note] instance using [Note.validated].
  ///
  /// Throws [MusicXmlValidationException] if the constructed note violates
  /// MusicXML validation rules.
  Note build() {
    return Note.validated(
      pitch: _pitch,
      duration: _duration,
      isRest: _isRest,
      voice: _voice,
      staff: _staff, // Pass staff to Note
      type: _type,
      dots: _dots,
      timeModification: _timeModification,
      slurs: _slurs,
      articulations: _articulations,
      ties: _ties,
      isChordElementPresent: _isChordElementPresent,
      stemDirection: _stemDirection,
      accidental: accidental,
      defaultX: defaultX,
      line: _line,
      context: _context,
    );
  }
}
