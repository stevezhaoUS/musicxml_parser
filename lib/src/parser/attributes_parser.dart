import 'package:musicxml_parser/src/exceptions/musicxml_parse_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:xml/xml.dart';

/// Parser for MusicXML attributes elements (key, time signatures, etc.).
class AttributesParser {
  /// The warning system for collecting non-critical issues.
  final WarningSystem warningSystem;

  /// Creates a new [AttributesParser].
  ///
  /// [warningSystem] - Optional warning system. If not provided, a new one will be created.
  AttributesParser({WarningSystem? warningSystem})
      : warningSystem = warningSystem ?? WarningSystem();

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

  /// Parses a key element into a [KeySignature] object.
  KeySignature _parseKeySignature(
    XmlElement element,
    String partId,
    String measureNumber,
  ) {
    final line = XmlHelper.getLineNumber(element);

    // Parse fifths
    final fifthsElement = element.findElements('fifths').firstOrNull;
    final fifthsText = fifthsElement?.innerText.trim();
    final fifths = fifthsText != null ? int.tryParse(fifthsText) : null;

    if (fifths == null) {
      throw MusicXmlValidationException(
        'Invalid key signature fifths value: $fifthsText',
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    // Parse mode (optional)
    final modeElement = element.findElements('mode').firstOrNull;
    final mode = modeElement?.innerText.trim();

    return KeySignature.validated(
      fifths: fifths,
      mode: mode,
      line: line,
      context: {
        'part': partId,
        'measure': measureNumber,
      },
    );
  }

  /// Parses a time element into a [TimeSignature] object.
  TimeSignature _parseTimeSignature(
    XmlElement element,
    String partId,
    String measureNumber,
  ) {
    final line = XmlHelper.getLineNumber(element);

    // Parse beats (numerator)
    final beatsElement = element.findElements('beats').firstOrNull;
    final beatsText = beatsElement?.innerText.trim();
    final beats = beatsText != null ? int.tryParse(beatsText) : null;

    if (beats == null || beats <= 0) {
      throw MusicXmlValidationException(
        'Invalid time signature beats (numerator) value: $beatsText',
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    // Parse beat-type (denominator)
    final beatTypeElement = element.findElements('beat-type').firstOrNull;
    final beatTypeText = beatTypeElement?.innerText.trim();
    final beatType = beatTypeText != null ? int.tryParse(beatTypeText) : null;

    if (beatType == null || beatType <= 0) {
      throw MusicXmlValidationException(
        'Invalid time signature beat-type (denominator) value: $beatTypeText',
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    // Note: We could use symbol attribute for special time signatures in the future
    // final symbol = element.getAttribute('symbol');
    
    return TimeSignature.validated(
      beats: beats,
      beatType: beatType,
      line: line,
      context: {
        'part': partId,
        'measure': measureNumber,
      },
    );
  }
}
