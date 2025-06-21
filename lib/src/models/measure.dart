import 'package:meta/meta.dart';
import 'package:collection/collection.dart'; // For DeepCollectionEquality
import 'package:musicxml_parser/src/models/barline.dart'; // Import for Barline
import 'package:musicxml_parser/src/models/beam.dart';
import 'package:musicxml_parser/src/models/ending.dart'; // Import for Ending
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/models/direction_words.dart';
import 'print_object.dart'; // New import

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

  /// Textual directions (e.g., "Allegro", "Fine") associated with this measure.
  final List<WordsDirection> wordsDirections;

  /// Print-related information for this measure (e.g. new page/system, local layouts).
  final PrintObject? printObject;

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
    this.wordsDirections = const [],
    this.printObject, // New parameter
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Measure &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          const DeepCollectionEquality().equals(notes, other.notes) &&
          keySignature == other.keySignature &&
          timeSignature == other.timeSignature &&
          width == other.width &&
          const DeepCollectionEquality().equals(beams, other.beams) &&
          const DeepCollectionEquality().equals(barlines, other.barlines) &&
          ending == other.ending &&
          const DeepCollectionEquality().equals(wordsDirections, other.wordsDirections) &&
          printObject == other.printObject; // Add to equality check

  @override
  int get hashCode =>
      number.hashCode ^
      const DeepCollectionEquality().hash(notes) ^
      keySignature.hashCode ^
      timeSignature.hashCode ^
      (width?.hashCode ?? 0) ^
      const DeepCollectionEquality().hash(beams) ^
      (barlines != null ? const DeepCollectionEquality().hash(barlines!) : 0) ^
      (ending?.hashCode ?? 0) ^
      const DeepCollectionEquality().hash(wordsDirections) ^
      printObject.hashCode; // Add to hash code

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
      if (wordsDirections.isNotEmpty) 'wordsDirections: $wordsDirections',
      if (printObject != null) 'printObject: $printObject', // Add to toString
    ];
    return 'Measure{${parts.join(', ')}}';
  }
}
