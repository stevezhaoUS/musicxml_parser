import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';
import 'package:xml/xml.dart';

/// Represents a time signature in a musical score.
///
/// A time signature is defined by a numerator ([beats]) indicating the number
/// of beats per measure, and a denominator ([beatType]) indicating the
/// note value that represents one beat.
///
/// Objects of this class are immutable.
@immutable
class TimeSignature {
  /// The numerator of the time signature, indicating the number of beats per measure.
  /// Must be a positive integer.
  final int beats;

  /// The denominator of the time signature, indicating the note value that
  /// represents one beat (e.g., 4 for a quarter note, 2 for a half note).
  /// Must be a positive power of 2.
  final int beatType;

  /// Creates a new [TimeSignature] instance.
  ///
  /// It's recommended to use [TimeSignature.validated] or
  /// [TimeSignature.fromXmlElement] for creating instances, as they include
  /// validation against MusicXML rules.
  const TimeSignature({
    required this.beats,
    required this.beatType,
  });

  /// Creates a new [TimeSignature] instance with validation.
  ///
  /// This factory constructor performs validation against MusicXML rules
  /// (e.g., positive beats, beatType is a power of 2).
  ///
  /// Throws [MusicXmlValidationException] if the time signature is invalid.
  ///
  /// Parameters:
  ///   [beats]: The numerator of the time signature.
  ///   [beatType]: The denominator of the time signature.
  ///   [line]: The line number in the XML document (for context in error messages).
  ///   [context]: Additional context for error messages.
  factory TimeSignature.validated({
    required int beats,
    required int beatType,
    int? line,
    Map<String, dynamic>? context,
  }) {
    final timeSignature = TimeSignature(beats: beats, beatType: beatType);
    // ValidationUtils.validateTimeSignature will throw if invalid.
    ValidationUtils.validateTimeSignature(timeSignature,
        line: line, context: context);
    return timeSignature;
  }

  /// Creates a new [TimeSignature] instance from a MusicXML `<time>` [element].
  ///
  /// This factory parses the required `<beats>` and `<beat-type>` elements
  /// and then validates the parsed values.
  ///
  /// Throws [MusicXmlStructureException] if required XML elements are missing.
  /// Throws [MusicXmlValidationException] if the parsed values are invalid.
  ///
  /// Parameters:
  ///   [element]: The XML element representing the `<time>`.
  ///   [partId]: The ID of the part (for context in error messages).
  ///   [measureNumber]: The number of the measure (for context in error messages).
  factory TimeSignature.fromXmlElement(
    XmlElement element,
    String partId,
    String measureNumber,
  ) {
    final line = XmlHelper.getLineNumber(element);

    final beatsElement = element.findElements('beats').firstOrNull;
    if (beatsElement == null) {
      throw MusicXmlStructureException(
        'Required <beats> element not found in <time>',
        parentElement: 'time',
        line: line,
        context: {'part': partId, 'measure': measureNumber},
      );
    }
    final beatsText = beatsElement.innerText.trim();
    final beats = int.tryParse(beatsText);

    final beatTypeElement = element.findElements('beat-type').firstOrNull;
    if (beatTypeElement == null) {
      throw MusicXmlStructureException(
        'Required <beat-type> element not found in <time>',
        parentElement: 'time',
        line: line,
        context: {'part': partId, 'measure': measureNumber},
      );
    }
    final beatTypeText = beatTypeElement.innerText.trim();
    final beatType = int.tryParse(beatTypeText);

    if (beats == null) {
      throw MusicXmlValidationException(
        'Invalid time signature beats (numerator) value: "$beatsText". Must be an integer.',
        rule: 'time_beats_invalid',
        line: XmlHelper.getLineNumber(beatsElement),
        context: {
          'part': partId,
          'measure': measureNumber,
          'parsedBeats': beatsText
        },
      );
    }
    if (beatType == null) {
      throw MusicXmlValidationException(
        'Invalid time signature beat-type (denominator) value: "$beatTypeText". Must be an integer.',
        rule: 'time_beat_type_invalid',
        line: XmlHelper.getLineNumber(beatTypeElement),
        context: {
          'part': partId,
          'measure': measureNumber,
          'parsedBeatType': beatTypeText
        },
      );
    }

    // Use the .validated factory to ensure consistent validation logic
    return TimeSignature.validated(
      beats: beats,
      beatType: beatType,
      line: line,
      context: {'part': partId, 'measure': measureNumber},
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSignature &&
          runtimeType == other.runtimeType &&
          beats == other.beats &&
          beatType == other.beatType;

  @override
  int get hashCode => beats.hashCode ^ beatType.hashCode;

  @override
  String toString() => 'TimeSignature{$beats/$beatType}';
}
