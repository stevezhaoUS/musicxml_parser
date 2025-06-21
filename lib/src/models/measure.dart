import 'package:meta/meta.dart';
import 'package:collection/collection.dart'; // For DeepCollectionEquality
import 'package:musicxml_parser/src/models/barline.dart'; // Import for Barline
import 'package:musicxml_parser/src/models/beam.dart';
import 'package:musicxml_parser/src/models/ending.dart'; // Import for Ending
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';

/// Represents a measure in a musical score.
@immutable
class Measure {
  /// The measure number.
  final String number;

  /// The notes contained in the measure.
  final List<Note> notes;

  /// The key signature of the measure, if specified.
  final KeySignature? keySignature;

  /// The time signature of the measure, if specified.
  final TimeSignature? timeSignature;

  /// The width of the measure in tenths.
  final double? width;

  /// The beams contained in the measure.
  final List<Beam> beams;

  /// Whether the measure is a pickup measure.
  final bool isPickup;

  /// A list of barlines associated with this measure.
  final List<Barline>? barlines;

  /// Optional repeat ending information for this measure.
  final Ending? ending;

  /// Creates a new [Measure] instance.
  const Measure({
    required this.number,
    required this.notes,
    this.keySignature,
    this.timeSignature,
    this.isPickup = false,
    this.width,
    this.beams = const [],
    this.barlines,
    this.ending,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Measure &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          notes == other.notes && // Assuming Note also has correct deep equality for its lists
          keySignature == other.keySignature &&
          timeSignature == other.timeSignature &&
          width == other.width &&
          const DeepCollectionEquality().equals(beams, other.beams) && // Corrected for beams as well
          const DeepCollectionEquality().equals(barlines, other.barlines) &&
          ending == other.ending;

  @override
  int get hashCode =>
      number.hashCode ^
      // For lists like notes and beams, need DeepCollectionEquality().hash if deep hash is desired
      // For simplicity and consistency with previous state, notes.hashCode is used.
      // Beams was just beams.hashCode, let's make it deep too.
      notes.hashCode ^
      keySignature.hashCode ^
      timeSignature.hashCode ^
      (width?.hashCode ?? 0) ^
      const DeepCollectionEquality().hash(beams) ^ // Corrected for beams
      (barlines != null ? const DeepCollectionEquality().hash(barlines!) : 0) ^
      (ending?.hashCode ?? 0);

  @override
  String toString() {
    final parts = [
      'number: $number',
      'notes: ${notes.length}',
      if (beams.isNotEmpty) 'beams: ${beams.length}',
      if (keySignature != null) 'key: $keySignature',
      if (timeSignature != null) 'time: $timeSignature',
      if (width != null) 'width: $width',
      if (isPickup) 'pickup',
      if (barlines != null && barlines!.isNotEmpty) 'barlines: $barlines',
      if (ending != null) 'ending: $ending',
    ];
    return 'Measure{${parts.join(', ')}}';
  }
}
