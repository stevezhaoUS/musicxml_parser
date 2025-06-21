import 'package:musicxml_parser/src/exceptions/musicxml_parse_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:xml/xml.dart';

/// Parser for MusicXML attributes elements (key, time signatures, etc.).
class AttributesParser {
  /// Creates a new [AttributesParser].
  const AttributesParser();

  /// Parses an attributes element and extracts divisions, key signature, and time signature.
  ///
  /// [element] - The XML element representing the attributes.
  /// [partId] - The ID of the part containing these attributes.
  /// [measureNumber] - The number of the measure containing these attributes.
  /// [currentDivisions] - The current divisions value (may be updated by this method).
  ///
  /// Returns a map containing the extracted values.
  Map<String, dynamic> parse(
    XmlElement element,
    String partId,
    String measureNumber,
    int? currentDivisions,
  ) {
    int? divisions = currentDivisions;
    KeySignature? keySignature;
    TimeSignature? timeSignature;

    // Parse divisions
    final divisionsElement = element.findElements('divisions').firstOrNull;
    if (divisionsElement != null) {
      final divisionsText = divisionsElement.innerText.trim();
      final divisionsValue = int.tryParse(divisionsText);

      if (divisionsValue == null) {
        throw MusicXmlParseException(
          'Invalid divisions value "$divisionsText"',
          element: 'divisions',
          line: XmlHelper.getLineNumber(divisionsElement),
          context: {
            'part': partId,
            'measure': measureNumber,
          },
        );
      }

      if (divisionsValue <= 0) {
        throw MusicXmlValidationException(
          'Divisions value must be positive, got $divisionsValue',
          rule: 'divisions_positive_validation',
          line: XmlHelper.getLineNumber(divisionsElement),
          context: {
            'part': partId,
            'measure': measureNumber,
            'divisions': divisionsValue,
          },
        );
      }

      divisions = divisionsValue;
    }

    // Parse key signature
    final keyElement = element.findElements('key').firstOrNull;
    if (keyElement != null) {
      keySignature = _parseKeySignature(keyElement, partId, measureNumber);
    }

    // Parse time signature
    final timeElement = element.findElements('time').firstOrNull;
    if (timeElement != null) {
      timeSignature = _parseTimeSignature(timeElement, partId, measureNumber);
    }

    // Return the parsed attributes
    return {
      'divisions': divisions,
      'keySignature': keySignature,
      'timeSignature': timeSignature,
    };
  }

  /// Parses a key element into a [KeySignature] object using the KeySignature.fromXmlElement factory.
  KeySignature _parseKeySignature(
    XmlElement element,
    String partId,
    String measureNumber,
  ) {
    try {
      return KeySignature.fromXmlElement(element, partId, measureNumber);
    } on MusicXmlStructureException {
      // Re-throw, or add more context if needed
      rethrow;
    } on MusicXmlValidationException {
      // Re-throw, or add more context if needed
      rethrow;
    }
  }

  /// Parses a time element into a [TimeSignature] object using the TimeSignature.fromXmlElement factory.
  TimeSignature _parseTimeSignature(
    XmlElement element,
    String partId,
    String measureNumber,
  ) {
    try {
      return TimeSignature.fromXmlElement(element, partId, measureNumber);
    } on MusicXmlStructureException {
      // Re-throw, or add more context if needed
      rethrow;
    } on MusicXmlValidationException {
      // Re-throw, or add more context if needed
      rethrow;
    }
  }
}
