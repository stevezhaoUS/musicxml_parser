import 'package:musicxml_parser/src/models/appearance.dart';
import 'package:musicxml_parser/src/models/line_width.dart';
import 'package:musicxml_parser/src/models/note_size.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:xml/xml.dart';

/// Parser for MusicXML appearance elements.
class AppearanceParser {
  /// The warning system for collecting non-critical issues.
  final WarningSystem warningSystem;

  /// Creates a new [AppearanceParser].
  AppearanceParser({WarningSystem? warningSystem})
      : warningSystem = warningSystem ?? WarningSystem();

  /// Parses an appearance element into an [Appearance] object.
  ///
  /// [element] - The XML element to parse.
  Appearance parse(XmlElement element) {
    final lineWidths = <LineWidth>[];
    final noteSizes = <NoteSize>[];

    // Parse line-width elements
    for (final lineWidthElement in element.findElements('line-width')) {
      final lineWidth = _parseLineWidth(lineWidthElement);
      if (lineWidth != null) {
        lineWidths.add(lineWidth);
      }
    }

    // Parse note-size elements
    for (final noteSizeElement in element.findElements('note-size')) {
      final noteSize = _parseNoteSize(noteSizeElement);
      if (noteSize != null) {
        noteSizes.add(noteSize);
      }
    }

    return Appearance(
      lineWidths: lineWidths,
      noteSizes: noteSizes,
    );
  }

  /// Parses a line-width element into a [LineWidth] object.
  LineWidth? _parseLineWidth(XmlElement element) {
    final type = element.getAttribute('type');
    final valueText = element.innerText.trim();

    if (type == null || type.isEmpty) {
      warningSystem.addWarning(
        'line-width element missing type attribute',
        category: 'appearance',
        context: {
          'line': XmlHelper.getLineNumber(element),
        },
      );
      return null;
    }

    if (valueText.isEmpty) {
      warningSystem.addWarning(
        'line-width element has no value',
        category: 'appearance',
        context: {
          'type': type,
          'line': XmlHelper.getLineNumber(element),
        },
      );
      return null;
    }

    final value = double.tryParse(valueText);
    if (value == null) {
      warningSystem.addWarning(
        'line-width element has invalid numeric value: $valueText',
        category: 'appearance',
        context: {
          'type': type,
          'value': valueText,
          'line': XmlHelper.getLineNumber(element),
        },
      );
      return null;
    }

    return LineWidth(type: type, value: value);
  }

  /// Parses a note-size element into a [NoteSize] object.
  NoteSize? _parseNoteSize(XmlElement element) {
    final type = element.getAttribute('type');
    final valueText = element.innerText.trim();

    if (type == null || type.isEmpty) {
      warningSystem.addWarning(
        'note-size element missing type attribute',
        category: 'appearance',
        context: {
          'line': XmlHelper.getLineNumber(element),
        },
      );
      return null;
    }

    if (valueText.isEmpty) {
      warningSystem.addWarning(
        'note-size element has no value',
        category: 'appearance',
        context: {
          'type': type,
          'line': XmlHelper.getLineNumber(element),
        },
      );
      return null;
    }

    final value = double.tryParse(valueText);
    if (value == null) {
      warningSystem.addWarning(
        'note-size element has invalid numeric value: $valueText',
        category: 'appearance',
        context: {
          'type': type,
          'value': valueText,
          'line': XmlHelper.getLineNumber(element),
        },
      );
      return null;
    }

    return NoteSize(type: type, value: value);
  }
}