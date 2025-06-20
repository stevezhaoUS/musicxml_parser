import 'package:musicxml_parser/src/models/barline.dart';
import 'package:musicxml_parser/src/models/repeat.dart';
import 'package:musicxml_parser/src/models/ending.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:xml/xml.dart';

/// Parser for MusicXML barline elements.
class BarlineParser {
  /// Creates a new [BarlineParser].
  const BarlineParser();

  /// Parses a barline element into a [Barline] object.
  ///
  /// [element] - The XML element representing the barline.
  /// [partId] - The ID of the part containing this barline.
  /// [measureNumber] - The number of the measure containing this barline.
  Barline parse(
    XmlElement element,
    String partId,
    String measureNumber,
  ) {
    final line = XmlHelper.getLineNumber(element);

    // Parse location (required in MusicXML)
    final locationStr = element.getAttribute('location');
    if (locationStr == null || locationStr.isEmpty) {
      throw MusicXmlValidationException(
        'Barline location is required',
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    final location = _parseLocation(locationStr, partId, measureNumber, line);

    // Parse bar-style (defaults to regular if not specified)
    final barStyleElement = element.getElement('bar-style');
    final style = barStyleElement != null
        ? _parseStyle(barStyleElement.innerText, partId, measureNumber, line)
        : BarlineStyle.regular;

    // Parse repeat (optional)
    final repeatElement = element.getElement('repeat');
    final repeat = repeatElement != null
        ? _parseRepeat(repeatElement, partId, measureNumber)
        : null;

    // Parse ending (optional)
    final endingElement = element.getElement('ending');
    final ending = endingElement != null
        ? _parseEnding(endingElement, partId, measureNumber)
        : null;

    return Barline(
      location: location,
      style: style,
      repeat: repeat,
      ending: ending,
    );
  }

  /// Parses a barline location string into a [BarlineLocation].
  BarlineLocation _parseLocation(
    String locationStr,
    String partId,
    String measureNumber,
    int? line,
  ) {
    switch (locationStr) {
      case 'left':
        return BarlineLocation.left;
      case 'right':
        return BarlineLocation.right;
      case 'middle':
        return BarlineLocation.middle;
      default:
        throw MusicXmlValidationException(
          'Invalid barline location: $locationStr',
          context: {
            'part': partId,
            'measure': measureNumber,
            'location': locationStr,
            'line': line,
          },
        );
    }
  }

  /// Parses a bar-style string into a [BarlineStyle].
  BarlineStyle _parseStyle(
    String styleStr,
    String partId,
    String measureNumber,
    int? line,
  ) {
    switch (styleStr) {
      case 'regular':
        return BarlineStyle.regular;
      case 'light-heavy':
        return BarlineStyle.lightHeavy;
      case 'heavy-light':
        return BarlineStyle.heavyLight;
      case 'light-light':
        return BarlineStyle.lightLight;
      case 'heavy-heavy':
        return BarlineStyle.heavyHeavy;
      case 'dashed':
        return BarlineStyle.dashed;
      case 'dotted':
        return BarlineStyle.dotted;
      case 'none':
        return BarlineStyle.none;
      default:
        throw MusicXmlValidationException(
          'Invalid barline style: $styleStr',
          context: {
            'part': partId,
            'measure': measureNumber,
            'style': styleStr,
            'line': line,
          },
        );
    }
  }

  /// Parses a repeat element into a [Repeat] object.
  Repeat _parseRepeat(
    XmlElement element,
    String partId,
    String measureNumber,
  ) {
    final line = XmlHelper.getLineNumber(element);

    // Parse direction (required)
    final directionStr = element.getAttribute('direction');
    if (directionStr == null || directionStr.isEmpty) {
      throw MusicXmlValidationException(
        'Repeat direction is required',
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    final direction = _parseRepeatDirection(directionStr, partId, measureNumber, line);

    // Parse times (optional)
    final timesStr = element.getAttribute('times');
    int? times;
    if (timesStr != null && timesStr.isNotEmpty) {
      times = int.tryParse(timesStr);
      if (times == null || times < 1) {
        throw MusicXmlValidationException(
          'Invalid repeat times: $timesStr',
          context: {
            'part': partId,
            'measure': measureNumber,
            'times': timesStr,
            'line': line,
          },
        );
      }
    }

    return Repeat(
      direction: direction,
      times: times,
    );
  }

  /// Parses a repeat direction string into a [RepeatDirection].
  RepeatDirection _parseRepeatDirection(
    String directionStr,
    String partId,
    String measureNumber,
    int? line,
  ) {
    switch (directionStr) {
      case 'forward':
        return RepeatDirection.forward;
      case 'backward':
        return RepeatDirection.backward;
      default:
        throw MusicXmlValidationException(
          'Invalid repeat direction: $directionStr',
          context: {
            'part': partId,
            'measure': measureNumber,
            'direction': directionStr,
            'line': line,
          },
        );
    }
  }

  /// Parses an ending element into an [Ending] object.
  Ending _parseEnding(
    XmlElement element,
    String partId,
    String measureNumber,
  ) {
    final line = XmlHelper.getLineNumber(element);

    // Parse number (required)
    final number = element.getAttribute('number');
    if (number == null || number.isEmpty) {
      throw MusicXmlValidationException(
        'Ending number is required',
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    // Parse type (required)
    final typeStr = element.getAttribute('type');
    if (typeStr == null || typeStr.isEmpty) {
      throw MusicXmlValidationException(
        'Ending type is required',
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    final type = _parseEndingType(typeStr, partId, measureNumber, line);

    // Parse text (optional, defaults to element text content)
    final text = element.innerText.isNotEmpty ? element.innerText : null;

    return Ending(
      number: number,
      type: type,
      text: text,
    );
  }

  /// Parses an ending type string into an [EndingType].
  EndingType _parseEndingType(
    String typeStr,
    String partId,
    String measureNumber,
    int? line,
  ) {
    switch (typeStr) {
      case 'start':
        return EndingType.start;
      case 'stop':
        return EndingType.stop;
      case 'discontinue':
        return EndingType.discontinue;
      default:
        throw MusicXmlValidationException(
          'Invalid ending type: $typeStr',
          context: {
            'part': partId,
            'measure': measureNumber,
            'type': typeStr,
            'line': line,
          },
        );
    }
  }
}