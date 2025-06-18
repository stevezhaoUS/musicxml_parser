import 'package:meta/meta.dart';
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

  /// Creates a new [Measure] instance.
  const Measure({
    required this.number,
    required this.notes,
    this.keySignature,
    this.timeSignature,
    this.width,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Measure &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          notes == other.notes &&
          keySignature == other.keySignature &&
          timeSignature == other.timeSignature &&
          width == other.width;

  @override
  int get hashCode =>
      number.hashCode ^
      notes.hashCode ^
      keySignature.hashCode ^
      timeSignature.hashCode ^
      (width?.hashCode ?? 0);

  @override
  String toString() => 'Measure{number: $number, notes: ${notes.length}}';
}
