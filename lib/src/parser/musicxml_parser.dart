import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:musicxml_parser/src/exceptions/musicxml_parse_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/measure.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/part.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/models/score.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

/// The main parser class for MusicXML files.
class MusicXmlParser {
  /// The warning system for collecting non-critical issues.
  final WarningSystem warningSystem;

  /// Creates a new [MusicXmlParser].
  /// 
  /// [warningSystem] - Optional warning system. If not provided, a new one will be created.
  MusicXmlParser({WarningSystem? warningSystem}) 
      : warningSystem = warningSystem ?? WarningSystem();
  /// Parses a MusicXML string into a [Score] object.
  ///
  /// Throws specific exception types based on the error:
  /// - [MusicXmlParseException] for XML parsing issues
  /// - [MusicXmlStructureException] for structural problems
  /// - [MusicXmlValidationException] for validation issues
  Score parse(String xmlString) {
    try {
      final document = XmlDocument.parse(xmlString);
      final scorePartwise = document.findElements('score-partwise').firstOrNull;

      if (scorePartwise == null) {
        // Try score-timewise format
        final scoreTimewise =
            document.findElements('score-timewise').firstOrNull;
        if (scoreTimewise == null) {
          throw MusicXmlStructureException(
            'Document is not a valid MusicXML file. Root element must be either "score-partwise" or "score-timewise"',
            requiredElement: 'score-partwise or score-timewise',
            line: _getLineNumber(document.rootElement),
          );
        }
        // Convert score-timewise to score-partwise format
        return _parseScoreTimewise(scoreTimewise);
      }

      return _parseScorePartwise(scorePartwise);
    } on XmlException catch (e) {
      throw MusicXmlParseException(
        'XML parsing error: ${e.message}',
        // Note: XmlException doesn't provide line numbers in this package version
      );
    } on MusicXmlParseException {
      rethrow;
    } on MusicXmlStructureException {
      rethrow;
    } on MusicXmlValidationException {
      rethrow;
    } catch (e) {
      throw MusicXmlParseException('Failed to parse MusicXML: $e');
    }
  }

  /// Parses a MusicXML file into a [Score] object.
  ///
  /// Throws [MusicXmlParseException] if the file doesn't exist or
  /// contains invalid MusicXML.
  Future<Score> parseFromFile(String path) async {
    try {
      final file = File(path);
      final xmlString = await file.readAsString();
      return parse(xmlString);
    } on FileSystemException catch (e) {
      throw MusicXmlParseException(
        'File error: ${e.message}',
        context: {'filePath': path},
      );
    }
  }

  /// Parses a MusicXML file in a stream-based manner, which is more efficient for large files.
  ///
  /// Throws [MusicXmlParseException] if the file doesn't exist or
  /// contains invalid MusicXML.
  Future<Score> parseFromFileStream(String path) async {
    final file = File(path);

    if (!await file.exists()) {
      throw MusicXmlParseException(
        'File not found: $path',
        context: {'filePath': path},
      );
    }

    try {
      // This is a simplified implementation of stream parsing.
      // For a complete implementation, you would need to handle events
      // as they come in and build the score incrementally.
      final events =
          file.openRead().transform(utf8.decoder).transform(XmlEventDecoder());

      // For now, collect the entire XML and parse it normally
      final xmlString = await events.map((event) => event.toString()).join();

      return parse(xmlString);
    } catch (e) {
      throw MusicXmlParseException(
        'Stream parsing error: $e',
        context: {'filePath': path},
      );
    }
  }

  // Private parsing methods

  Score _parseScorePartwise(XmlElement element) {
    // Extract score metadata
    final title = _findOptionalTextElement(element, 'work/work-title') ??
        _findOptionalTextElement(element, 'movement-title');
    final composer = _findOptionalTextElement(
        element, 'identification/creator[@type="composer"]');
    final version = element.getAttribute('version');

    // Find divisions (if specified at the score level)
    final scoreDefaultsElement = element.findElements('defaults').firstOrNull;
    final divisionsByQuarterElement =
        scoreDefaultsElement?.findElements('divisions').firstOrNull;
    final divisions = divisionsByQuarterElement != null
        ? int.tryParse(divisionsByQuarterElement.innerText)
        : null;

    // Parse parts
    final parts = element.findElements('part').map(_parsePart).toList();

    return Score(
      title: title,
      composer: composer,
      parts: parts,
      version: version,
      divisions: divisions,
    );
  }

  Score _parseScoreTimewise(XmlElement element) {
    // In a real implementation, convert from timewise to partwise
    // This is a simplification that would need to be expanded
    throw MusicXmlStructureException(
      'Score-timewise format is not fully implemented yet',
      requiredElement: 'score-partwise',
      parentElement: 'score-timewise',
      line: _getLineNumber(element),
      context: _createContext(elementName: 'score-timewise'),
    );
  }

  Part _parsePart(XmlElement element) {
    final id = element.getAttribute('id');
    final line = _getLineNumber(element);
    
    if (id == null || id.isEmpty) {
      throw MusicXmlStructureException(
        'Part element missing required "id" attribute',
        requiredElement: 'id',
        parentElement: 'part',
        line: line,
        context: _createContext(elementName: 'part'),
      );
    }

    // Find part name from the part-list
    String? name;
    final parent = element.parent;
    if (parent != null) {
      final partList = parent.findElements('part-list').firstOrNull;
      if (partList != null) {
        final scorePart = partList
            .findElements('score-part')
            .where((e) => e.getAttribute('id') == id)
            .firstOrNull;
        if (scorePart != null) {
          name = _findOptionalTextElement(scorePart, 'part-name');
        } else {
          warningSystem.addWarning(
            'Part "$id" not found in part-list',
            category: WarningCategories.structure,
            line: line,
            element: 'part',
            severity: WarningSeverity.minor,
            context: _createContext(partId: id),
          );
        }
      } else {
        warningSystem.addWarning(
          'Missing part-list in score',
          category: WarningCategories.structure,
          line: _getLineNumber(parent),
          element: 'score-partwise',
          severity: WarningSeverity.moderate,
        );
      }
    }

    // Parse measures
    final measures = <Measure>[];
    for (final measureElement in element.findElements('measure')) {
      try {
        final measure = _parseMeasure(measureElement, id);
        measures.add(measure);
      } catch (e) {
        if (e is MusicXmlValidationException || 
            e is MusicXmlStructureException ||
            e is MusicXmlParseException) {
          rethrow;
        }
        throw MusicXmlParseException(
          'Error parsing measure in part "$id": $e',
          line: _getLineNumber(measureElement),
          element: 'measure',
          context: _createContext(partId: id),
        );
      }
    }

    return Part(
      id: id,
      name: name,
      measures: measures,
    );
  }

  Measure _parseMeasure(XmlElement element, String partId) {
    final number = element.getAttribute('number') ?? '1';
    final width = element.getAttribute('width') != null
        ? double.tryParse(element.getAttribute('width')!)
        : null;
    final line = _getLineNumber(element);

    // Parse key signature
    KeySignature? keySignature;
    final keyElement = element
        .findElements('attributes')
        .firstOrNull
        ?.findElements('key')
        .firstOrNull;
    if (keyElement != null) {
      try {
        final fifthsText = _findOptionalTextElement(keyElement, 'fifths') ?? '0';
        final fifths = int.tryParse(fifthsText) ?? 0;
        final mode = _findOptionalTextElement(keyElement, 'mode');
        
        keySignature = KeySignature.validated(
          fifths: fifths,
          mode: mode,
          line: _getLineNumber(keyElement),
          context: _createContext(
            partId: partId,
            measureNumber: number,
            elementName: 'key',
          ),
        );
      } catch (e) {
        if (e is MusicXmlValidationException) {
          rethrow;
        }
        throw MusicXmlParseException(
          'Error parsing key signature: $e',
          line: _getLineNumber(keyElement),
          element: 'key',
          context: _createContext(partId: partId, measureNumber: number),
        );
      }
    }

    // Parse time signature
    TimeSignature? timeSignature;
    final timeElement = element
        .findElements('attributes')
        .firstOrNull
        ?.findElements('time')
        .firstOrNull;
    if (timeElement != null) {
      try {
        final beatsText = _findOptionalTextElement(timeElement, 'beats');
        final beatTypeText = _findOptionalTextElement(timeElement, 'beat-type');

        if (beatsText != null && beatTypeText != null) {
          final beats = int.tryParse(beatsText);
          final beatType = int.tryParse(beatTypeText);
          
          if (beats == null) {
            throw MusicXmlParseException(
              'Invalid beats value "$beatsText" in time signature',
              line: _getLineNumber(timeElement),
              element: 'beats',
              context: _createContext(partId: partId, measureNumber: number),
            );
          }
          
          if (beatType == null) {
            throw MusicXmlParseException(
              'Invalid beat-type value "$beatTypeText" in time signature',
              line: _getLineNumber(timeElement),
              element: 'beat-type',
              context: _createContext(partId: partId, measureNumber: number),
            );
          }
          
          timeSignature = TimeSignature.validated(
            beats: beats,
            beatType: beatType,
            line: _getLineNumber(timeElement),
            context: _createContext(
              partId: partId,
              measureNumber: number,
              elementName: 'time',
            ),
          );
        } else {
          warningSystem.addWarning(
            'Time signature missing beats or beat-type',
            category: WarningCategories.timeSignature,
            line: _getLineNumber(timeElement),
            element: 'time',
            severity: WarningSeverity.minor,
            context: _createContext(partId: partId, measureNumber: number),
          );
        }
      } catch (e) {
        if (e is MusicXmlValidationException || e is MusicXmlParseException) {
          rethrow;
        }
        throw MusicXmlParseException(
          'Error parsing time signature: $e',
          line: _getLineNumber(timeElement),
          element: 'time',
          context: _createContext(partId: partId, measureNumber: number),
        );
      }
    }

    // Parse divisions
    int? divisions;
    final divisionsElement = element
        .findElements('attributes')
        .firstOrNull
        ?.findElements('divisions')
        .firstOrNull;
    if (divisionsElement != null) {
      final divisionsText = divisionsElement.innerText.trim();
      divisions = int.tryParse(divisionsText);
      if (divisions == null) {
        throw MusicXmlParseException(
          'Invalid divisions value "$divisionsText"',
          line: _getLineNumber(divisionsElement),
          element: 'divisions',
          context: _createContext(partId: partId, measureNumber: number),
        );
      }
      if (divisions <= 0) {
        throw MusicXmlValidationException(
          'Divisions must be positive, got $divisions',
          rule: 'divisions_positive_validation',
          line: _getLineNumber(divisionsElement),
          node: 'divisions',
          context: _createContext(partId: partId, measureNumber: number),
        );
      }
    }

    // Parse notes
    final notes = <Note>[];
    for (final noteElement in element.findElements('note')) {
      try {
        final note = _parseNote(noteElement, divisions, partId, number);
        if (note != null) {
          notes.add(note);
        }
      } catch (e) {
        if (e is MusicXmlValidationException || 
            e is MusicXmlStructureException ||
            e is MusicXmlParseException) {
          rethrow;
        }
        throw MusicXmlParseException(
          'Error parsing note: $e',
          line: _getLineNumber(noteElement),
          element: 'note',
          context: _createContext(partId: partId, measureNumber: number),
        );
      }
    }

    // Validate measure duration if we have enough information
    if (timeSignature != null && divisions != null && notes.isNotEmpty) {
      try {
        ValidationUtils.validateMeasureDuration(
          notes,
          timeSignature,
          divisions,
          line: line,
          context: _createContext(partId: partId, measureNumber: number),
        );
      } catch (e) {
        if (e is MusicXmlValidationException) {
          // For measure duration validation, we might want to warn instead of error
          warningSystem.addWarning(
            e.message,
            category: WarningCategories.measure,
            line: line,
            element: 'measure',
            severity: WarningSeverity.moderate,
            context: _createContext(partId: partId, measureNumber: number),
          );
        }
      }
    }

    return Measure(
      number: number,
      notes: notes,
      keySignature: keySignature,
      timeSignature: timeSignature,
      width: width,
    );
  }

  Note? _parseNote(XmlElement element, int? parentDivisions, String partId, String measureNumber) {
    final line = _getLineNumber(element);
    
    // Check if it's a rest
    final isRest = element.findElements('rest').isNotEmpty;

    // Parse pitch (if not a rest)
    Pitch? pitch;
    if (!isRest) {
      final pitchElement = element.findElements('pitch').firstOrNull;
      if (pitchElement != null) {
        try {
          final step = _findOptionalTextElement(pitchElement, 'step');
          final octaveText = _findOptionalTextElement(pitchElement, 'octave');
          final alterText = _findOptionalTextElement(pitchElement, 'alter');

          if (step == null) {
            throw MusicXmlStructureException(
              'Pitch element missing required step',
              requiredElement: 'step',
              parentElement: 'pitch',
              line: _getLineNumber(pitchElement),
              context: _createContext(partId: partId, measureNumber: measureNumber),
            );
          }
          
          if (octaveText == null) {
            throw MusicXmlStructureException(
              'Pitch element missing required octave',
              requiredElement: 'octave',
              parentElement: 'pitch',
              line: _getLineNumber(pitchElement),
              context: _createContext(partId: partId, measureNumber: measureNumber),
            );
          }

          final octave = int.tryParse(octaveText);
          if (octave == null) {
            throw MusicXmlParseException(
              'Invalid octave value "$octaveText"',
              line: _getLineNumber(pitchElement),
              element: 'octave',
              context: _createContext(partId: partId, measureNumber: measureNumber),
            );
          }
          
          int? alter;
          if (alterText != null) {
            alter = int.tryParse(alterText);
            if (alter == null) {
              throw MusicXmlParseException(
                'Invalid alter value "$alterText"',
                line: _getLineNumber(pitchElement),
                element: 'alter',
                context: _createContext(partId: partId, measureNumber: measureNumber),
              );
            }
          }
          
          pitch = Pitch.validated(
            step: step,
            octave: octave,
            alter: alter,
            line: _getLineNumber(pitchElement),
            context: _createContext(partId: partId, measureNumber: measureNumber),
          );
        } catch (e) {
          if (e is MusicXmlValidationException || 
              e is MusicXmlParseException || 
              e is MusicXmlStructureException) {
            rethrow;
          }
          throw MusicXmlParseException(
            'Error parsing pitch: $e',
            line: _getLineNumber(pitchElement),
            element: 'pitch',
            context: _createContext(partId: partId, measureNumber: measureNumber),
          );
        }
      } else {
        // Non-rest note without pitch - this is an error
        throw MusicXmlStructureException(
          'Non-rest note missing pitch element',
          requiredElement: 'pitch',
          parentElement: 'note',
          line: line,
          context: _createContext(partId: partId, measureNumber: measureNumber),
        );
      }
    }

    // Parse duration
    final durationText = _findOptionalTextElement(element, 'duration');
    if (durationText == null) {
      warningSystem.addWarning(
        'Note without duration, skipping',
        category: WarningCategories.duration,
        line: line,
        element: 'note',
        severity: WarningSeverity.minor,
        context: _createContext(partId: partId, measureNumber: measureNumber),
      );
      return null; // Skip notes without duration
    }

    final durationValue = int.tryParse(durationText);
    if (durationValue == null) {
      throw MusicXmlParseException(
        'Invalid duration value "$durationText"',
        line: line,
        element: 'duration',
        context: _createContext(partId: partId, measureNumber: measureNumber),
      );
    }
    
    final divisions = parentDivisions ?? 1; // Default to 1 if not specified

    Duration duration;
    try {
      duration = Duration.validated(
        value: durationValue,
        divisions: divisions,
        line: line,
        context: _createContext(partId: partId, measureNumber: measureNumber),
      );
    } catch (e) {
      if (e is MusicXmlValidationException) {
        rethrow;
      }
      throw MusicXmlParseException(
        'Error creating duration: $e',
        line: line,
        element: 'duration',
        context: _createContext(partId: partId, measureNumber: measureNumber),
      );
    }

    // Parse type
    final type = _findOptionalTextElement(element, 'type');

    // Parse voice
    final voiceText = _findOptionalTextElement(element, 'voice');
    int? voice;
    if (voiceText != null) {
      voice = int.tryParse(voiceText);
      if (voice == null) {
        warningSystem.addWarning(
          'Invalid voice value "$voiceText", ignoring',
          category: WarningCategories.voice,
          line: line,
          element: 'voice',
          severity: WarningSeverity.minor,
          context: _createContext(partId: partId, measureNumber: measureNumber),
        );
      }
    }

    // Parse lyric
    final lyricElement = element.findElements('lyric').firstOrNull;
    final lyric = lyricElement != null
        ? _findOptionalTextElement(lyricElement, 'text')
        : null;

    // Parse tie information
    bool tiedStart = false;
    bool tiedEnd = false;

    for (final tieElement in element.findElements('tie')) {
      final tieType = tieElement.getAttribute('type');
      if (tieType == 'start') {
        tiedStart = true;
      } else if (tieType == 'stop') {
        tiedEnd = true;
      } else if (tieType != null) {
        warningSystem.addWarning(
          'Unknown tie type "$tieType"',
          category: WarningCategories.tie,
          line: _getLineNumber(tieElement),
          element: 'tie',
          severity: WarningSeverity.minor,
          context: _createContext(partId: partId, measureNumber: measureNumber),
        );
      }
    }

    // Create and validate note
    try {
      return Note.validated(
        pitch: pitch,
        duration: duration,
        isRest: isRest,
        lyric: lyric,
        voice: voice,
        type: type,
        tiedStart: tiedStart,
        tiedEnd: tiedEnd,
        line: line,
        context: _createContext(partId: partId, measureNumber: measureNumber),
      );
    } catch (e) {
      if (e is MusicXmlValidationException) {
        rethrow;
      }
      throw MusicXmlParseException(
        'Error creating note: $e',
        line: line,
        element: 'note',
        context: _createContext(partId: partId, measureNumber: measureNumber),
      );
    }
  }

  // Helper methods

  /// Extracts line number from an XML element if available.
  /// Note: Line number tracking is limited in the current xml package version.
  int? _getLineNumber(XmlNode? node) {
    // The xml package doesn't provide direct access to line numbers
    // This is a placeholder for future enhancement
    return null;
  }

  /// Creates a context map with common parsing information.
  Map<String, dynamic> _createContext({
    String? partId,
    String? measureNumber,
    String? elementName,
    Map<String, dynamic>? additional,
  }) {
    final context = <String, dynamic>{};
    if (partId != null) context['partId'] = partId;
    if (measureNumber != null) context['measureNumber'] = measureNumber;
    if (elementName != null) context['elementName'] = elementName;
    if (additional != null) context.addAll(additional);
    return context;
  }

  String? _findOptionalTextElement(XmlElement parent, String path) {
    final parts = path.split('/');
    XmlElement? current = parent;

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];

      // Handle attribute selector syntax (e.g., creator[@type="composer"])
      if (part.contains('[') && part.contains(']')) {
        final elementName = part.substring(0, part.indexOf('['));
        final attributePart =
            part.substring(part.indexOf('[') + 1, part.indexOf(']'));

        if (attributePart.startsWith('@')) {
          final attributeExpression = attributePart.substring(1);
          final attributeParts = attributeExpression.split('=');

          if (attributeParts.length == 2) {
            final attributeName = attributeParts[0];
            final attributeValue =
                attributeParts[1].replaceAll('"', '').replaceAll("'", '');

            current = current
                ?.findElements(elementName)
                .where((e) => e.getAttribute(attributeName) == attributeValue)
                .firstOrNull;
          }
        }
      } else {
        // Regular element name
        current = current?.findElements(part).firstOrNull;
      }

      if (current == null) {
        return null;
      }
    }

    return current!.innerText.trim();
  }
}
