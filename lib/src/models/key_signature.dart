import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';
import 'package:xml/xml.dart';

/// Represents a key signature in a musical score.
///
/// A key signature is defined by the number of sharps or flats (fifths)
/// and an optional mode (e.g., major, minor).
///
/// Objects of this class are immutable.
@immutable
class KeySignature {
  /// The number of sharps (positive value) or flats (negative value)
  /// in the key signature. Typically ranges from -7 to 7.
  final int fifths;

  /// The mode of the key signature (e.g., "major", "minor", "dorian").
  ///
  /// This is optional as per MusicXML specification.
  final String? mode;

  /// Creates a new [KeySignature] instance.
  ///
  /// It's recommended to use [KeySignature.validated] or [KeySignature.fromXmlElement]
  /// for creating instances, as they include validation.
  const KeySignature({
    required this.fifths,
    this.mode,
  });

  /// Creates a new [KeySignature] instance with validation.
  ///
  /// This factory constructor performs validation against MusicXML rules
  /// (e.g., fifths within range, valid mode if specified).
  ///
  /// Throws [MusicXmlValidationException] if the key signature is invalid.
  ///
  /// Parameters:
  ///   [fifths]: The number of sharps or flats.
  ///   [mode]: The mode of the key (optional).
  ///   [line]: The line number in the XML document (for context in error messages).
  ///   [context]: Additional context for error messages.
  factory KeySignature.validated({
    required int fifths,
    String? mode,
    int? line,
    Map<String, dynamic>? context,
  }) {
    final keySignature = KeySignature(fifths: fifths, mode: mode);
    // ValidationUtils.validateKeySignature will throw if invalid.
    ValidationUtils.validateKeySignature(keySignature,
        line: line, context: context);
    return keySignature;
  }

  /// Creates a new [KeySignature] instance from a MusicXML `<key>` [element].
  ///
  /// This factory parses the required `<fifths>` element and the optional
  /// `<mode>` element. It then validates the parsed values.
  ///
  /// Throws [MusicXmlStructureException] if required XML elements are missing.
  /// Throws [MusicXmlValidationException] if the parsed values are invalid.
  ///
  /// Parameters:
  ///   [element]: The XML element representing the `<key>`.
  ///   [partId]: The ID of the part (for context in error messages).
  ///   [measureNumber]: The number of the measure (for context in error messages).
  factory KeySignature.fromXmlElement(
    XmlElement element,
    String partId,
    String measureNumber,
  ) {
    final line = XmlHelper.getLineNumber(element);

    final fifthsElement = element.findElements('fifths').firstOrNull;
    if (fifthsElement == null) {
      throw MusicXmlStructureException(
        'Required <fifths> element not found in <key>',
        parentElement: 'key',
        line: line,
        context: {'part': partId, 'measure': measureNumber},
      );
    }
    final fifthsText = fifthsElement.innerText.trim();
    final fifths = int.tryParse(fifthsText);

    if (fifths == null) {
      throw MusicXmlValidationException(
        'Invalid key signature fifths value: "$fifthsText". Must be an integer.',
        rule: 'key_fifths_invalid',
        line: XmlHelper.getLineNumber(fifthsElement),
        context: {
          'part': partId,
          'measure': measureNumber,
          'parsedFifths': fifthsText
        },
      );
    }

    final modeElement = element.findElements('mode').firstOrNull;
    final mode = modeElement?.innerText.trim();

    // Use the .validated factory to ensure consistent validation logic
    return KeySignature.validated(
      fifths: fifths,
      mode: mode,
      line: line,
      context: {'part': partId, 'measure': measureNumber},
    );
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeySignature &&
          runtimeType == other.runtimeType &&
          fifths == other.fifths &&
          mode == other.mode;

  @override
  int get hashCode => fifths.hashCode ^ (mode?.hashCode ?? 0);

  @override
  String toString() => 'KeySignature{fifths: $fifths, mode: $mode}';
}
