import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';

/// Represents a beam connecting multiple notes within a measure.
///
/// A beam visually groups notes (typically eighth notes or shorter) together.
/// All notes in a beam must belong to the same measure.
@immutable
class Beam {
  /// The beam number/level (1 for primary beam, 2 for secondary beam, etc.)
  final int number;

  /// The beam type indicating the beam's role
  /// (begin, continue, end, forward hook, backward hook, etc.)
  final String type;

  /// The measure number this beam belongs to.
  final String measureNumber;

  /// The indices of notes connected by this beam.
  /// The order of indices is significant.
  final List<int> noteIndices;

  /// Creates a new [Beam] instance.
  const Beam({
    required this.number,
    required this.type,
    required this.measureNumber,
    required this.noteIndices,
  });

  /// Creates a new [Beam] instance with validation.
  ///
  /// Throws [MusicXmlValidationException] if invalid.
  factory Beam.validated({
    required int number,
    required String type,
    required String measureNumber,
    required List<int> noteIndices,
    int? line,
    Map<String, dynamic>? context,
  }) {
    // Validate beam number
    if (number <= 0) {
      throw MusicXmlValidationException(
        'Beam number must be positive, got $number',
        rule: 'beam_number_validation',
        line: line,
        context: {'number': number, ...?context},
      );
    }

    // Validate beam type
    const validTypes = [
      'begin',
      'continue',
      'end',
      'forward hook',
      'backward hook',
    ];
    if (!validTypes.contains(type)) {
      throw MusicXmlValidationException(
        'Invalid beam type: $type. Expected one of: $validTypes',
        rule: 'beam_type_validation',
        line: line,
        context: {'type': type, ...?context},
      );
    }

    // Validate measure number
    if (measureNumber.isEmpty) {
      throw MusicXmlValidationException(
        'Measure number cannot be empty',
        rule: 'beam_measure_validation',
        line: line,
        context: context,
      );
    }

    // Validate note indices
    if (noteIndices.length < 2) {
      throw MusicXmlValidationException(
        'A beam must connect at least 2 notes, got ${noteIndices.length}',
        rule: 'beam_notes_validation',
        line: line,
        context: {'noteCount': noteIndices.length, ...?context},
      );
    }

    return Beam(
      number: number,
      type: type,
      measureNumber: measureNumber,
      noteIndices: noteIndices,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Beam &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          type == other.type &&
          measureNumber == other.measureNumber &&
          _listEquals(noteIndices, other.noteIndices);

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        number,
        type,
        measureNumber,
        Object.hashAll(noteIndices),
      );

  @override
  String toString() =>
      'Beam{number: $number, type: $type, measureNumber: $measureNumber, noteIndices: $noteIndices}';
}
