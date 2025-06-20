import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';

/// Represents a time modification, such as a tuplet.
@immutable
class TimeModification {
  /// The number of actual notes in the tuplet (e.g., 3 for a triplet).
  final int actualNotes;

  /// The number of normal notes of the same type that would normally
  /// occupy the same duration (e.g., 2 for a triplet of eighths).
  final int normalNotes;

  /// The note type of the normal notes (e.g., "eighth", "quarter").
  /// Optional in MusicXML.
  final String? normalType;

  /// The number of dots on the normal notes, if specified.
  /// This represents the count of <normal-dot/> elements.
  /// Null if <normal-dot> elements are not present.
  final int? normalDotCount;

  /// Creates a new [TimeModification] instance.
  const TimeModification({
    required this.actualNotes,
    required this.normalNotes,
    this.normalType,
    this.normalDotCount,
  });

  /// Creates a new [TimeModification] instance with validation.
  factory TimeModification.validated({
    required int actualNotes,
    required int normalNotes,
    String? normalType,
    int? normalDotCount,
    int? line, // For error reporting
    Map<String, dynamic>? context, // For error reporting
  }) {
    if (actualNotes <= 0) {
      throw MusicXmlValidationException(
        'TimeModification actualNotes must be positive, got $actualNotes',
        rule: 'time_modification_actual_notes_positive',
        line: line,
        context: {'actualNotes': actualNotes, ...?context},
      );
    }
    if (normalNotes <= 0) {
      throw MusicXmlValidationException(
        'TimeModification normalNotes must be positive, got $normalNotes',
        rule: 'time_modification_normal_notes_positive',
        line: line,
        context: {'normalNotes': normalNotes, ...?context},
      );
    }
    // normalDotCount can be null (not specified) or >= 0.
    // A count of 0 means <normal-dot> was not present or explicitly zero (though MusicXML implies presence means at least one).
    // The parser will set this to the number of <normal-dot> elements if they exist, otherwise null.
    if (normalDotCount != null && normalDotCount < 0) {
      throw MusicXmlValidationException(
        'TimeModification normalDotCount cannot be negative if specified, got $normalDotCount',
        rule: 'time_modification_normal_dot_count_non_negative',
        line: line,
        context: {'normalDotCount': normalDotCount, ...?context},
      );
    }

    return TimeModification(
      actualNotes: actualNotes,
      normalNotes: normalNotes,
      normalType: normalType,
      normalDotCount: normalDotCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeModification &&
          runtimeType == other.runtimeType &&
          actualNotes == other.actualNotes &&
          normalNotes == other.normalNotes &&
          normalType == other.normalType &&
          normalDotCount == other.normalDotCount;

  @override
  int get hashCode =>
      actualNotes.hashCode ^
      normalNotes.hashCode ^
      (normalType?.hashCode ?? 0) ^
      (normalDotCount?.hashCode ?? 0); // Handle null for normalDotCount

  @override
  String toString() {
    final parts = [
      'actualNotes: $actualNotes',
      'normalNotes: $normalNotes',
      if (normalType != null) 'normalType: $normalType',
      if (normalDotCount != null) 'normalDotCount: $normalDotCount',
    ];
    return 'TimeModification{${parts.join(', ')}}';
  }
}
