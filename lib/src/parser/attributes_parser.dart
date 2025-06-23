import 'package:musicxml_parser/src/exceptions/musicxml_parse_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/clef.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:xml/xml.dart';

/// Parser for MusicXML attributes elements (key, time signatures, clefs, etc.).
class AttributesParser {
  /// Creates a new [AttributesParser].
  const AttributesParser();

  /// Parses an attributes element and extracts divisions, key signature, time signature, and clefs.
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
    List<Clef> clefs = [];

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

    // Parse clef elements
    for (final clefElement in element.findElements('clef')) {
      clefs.add(_parseClef(clefElement, partId, measureNumber));
    }

    // Return the parsed attributes
    final parsedAttributes = {
      'divisions': divisions,
      'keySignature': keySignature,
      'timeSignature': timeSignature,
    };
    if (clefs.isNotEmpty) {
      parsedAttributes['clefs'] = clefs;
    }
    return parsedAttributes;
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
      rethrow;
    } on MusicXmlValidationException {
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
      rethrow;
    } on MusicXmlValidationException {
      rethrow;
    }
  }

  /// Parses a clef element into a [Clef] object.
  Clef _parseClef(
    XmlElement element,
    String partId,
    String measureNumber,
  ) {
    final context = {
      'part': partId,
      'measure': measureNumber,
      'line': XmlHelper.getLineNumber(element)
    };

    final signElement = element.findElements('sign').firstOrNull;
    if (signElement == null) {
      throw MusicXmlStructureException(
        'Clef element missing required <sign> child.',
        parentElement: 'clef',
        line: XmlHelper.getLineNumber(element),
        context: context,
      );
    }
    final sign = signElement.innerText.trim();
    if (sign.isEmpty) {
      throw MusicXmlValidationException(
        'Clef <sign> element cannot be empty.',
        rule: 'clef_sign_not_empty',
        line: XmlHelper.getLineNumber(signElement),
        context: context,
      );
    }

    int? line;
    final lineElement = element.findElements('line').firstOrNull;
    if (lineElement != null) {
      final lineText = lineElement.innerText.trim();
      line = int.tryParse(lineText);
      if (line == null) {
        throw MusicXmlParseException(
          'Invalid clef line value "$lineText"',
          element: 'line',
          line: XmlHelper.getLineNumber(lineElement),
          context: context,
        );
      }
    }

    int? octaveChange;
    final octaveChangeElement =
        element.findElements('clef-octave-change').firstOrNull;
    if (octaveChangeElement != null) {
      final octaveChangeText = octaveChangeElement.innerText.trim();
      octaveChange = int.tryParse(octaveChangeText);
      if (octaveChange == null) {
        throw MusicXmlParseException(
          'Invalid clef-octave-change value "$octaveChangeText"',
          element: 'clef-octave-change',
          line: XmlHelper.getLineNumber(octaveChangeElement),
          context: context,
        );
      }
    }

    final numberStr = XmlHelper.getAttributeValue(element, 'number');
    int? number;
    if (numberStr != null) {
      number = int.tryParse(numberStr);
      if (number == null) {
        throw MusicXmlParseException(
          'Invalid clef number attribute "$numberStr"',
          element: 'clef',
          attribute: 'number',
          line: XmlHelper.getLineNumber(element),
          context: context,
        );
      }
    }

    // Basic validation for common clef types, can be expanded
    if (['G', 'F', 'C'].contains(sign) && line == null) {
      throw MusicXmlValidationException(
        'Clef sign "$sign" requires a <line> element.',
        rule: 'clef_line_required_for_sign',
        line: XmlHelper.getLineNumber(element),
        context: {...context, 'sign': sign},
      );
    }


    return Clef(
      sign: sign,
      line: line,
      octaveChange: octaveChange,
      number: number,
    );
  }
}
