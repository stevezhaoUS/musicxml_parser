import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:musicxml_parser/src/exceptions/invalid_musicxml_exception.dart';
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/measure.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/part.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/models/score.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

/// The main parser class for MusicXML files.
class MusicXmlParser {
  /// Parses a MusicXML string into a [Score] object.
  ///
  /// Throws an [InvalidMusicXmlException] if the XML is invalid or
  /// doesn't conform to the MusicXML specification.
  Score parse(String xmlString) {
    try {
      final document = XmlDocument.parse(xmlString);
      final scorePartwise = document.findElements('score-partwise').firstOrNull;

      if (scorePartwise == null) {
        // Try score-timewise format
        final scoreTimewise =
            document.findElements('score-timewise').firstOrNull;
        if (scoreTimewise == null) {
          throw InvalidMusicXmlException(
              'Document is not a valid MusicXML file. Root element must be either "score-partwise" or "score-timewise".');
        }
        // Convert score-timewise to score-partwise format
        return _parseScoreTimewise(scoreTimewise);
      }

      return _parseScorePartwise(scorePartwise);
    } on XmlException catch (e) {
      throw InvalidMusicXmlException('XML parsing error: ${e.message}');
    } catch (e) {
      if (e is InvalidMusicXmlException) {
        rethrow;
      }
      throw InvalidMusicXmlException('Failed to parse MusicXML: $e');
    }
  }

  /// Parses a MusicXML file into a [Score] object.
  ///
  /// Throws an [InvalidMusicXmlException] if the file doesn't exist or
  /// contains invalid MusicXML.
  Future<Score> parseFromFile(String path) async {
    try {
      final file = File(path);
      final xmlString = await file.readAsString();
      return parse(xmlString);
    } on FileSystemException catch (e) {
      throw InvalidMusicXmlException('File error: ${e.message}');
    }
  }

  /// Parses a MusicXML file in a stream-based manner, which is more efficient for large files.
  ///
  /// Throws an [InvalidMusicXmlException] if the file doesn't exist or
  /// contains invalid MusicXML.
  Future<Score> parseFromFileStream(String path) async {
    final file = File(path);

    if (!await file.exists()) {
      throw InvalidMusicXmlException('File not found: $path');
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
      throw InvalidMusicXmlException('Stream parsing error: $e');
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
    throw InvalidMusicXmlException(
        'Score-timewise format is not fully implemented yet.');
  }

  Part _parsePart(XmlElement element) {
    final id = element.getAttribute('id') ?? '';

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
        }
      }
    }

    // Parse measures
    final measures =
        element.findElements('measure').map(_parseMeasure).toList();

    return Part(
      id: id,
      name: name,
      measures: measures,
    );
  }

  Measure _parseMeasure(XmlElement element) {
    final number = element.getAttribute('number') ?? '1';
    final width = element.getAttribute('width') != null
        ? double.tryParse(element.getAttribute('width')!)
        : null;

    // Parse key signature
    KeySignature? keySignature;
    final keyElement = element
        .findElements('attributes')
        .firstOrNull
        ?.findElements('key')
        .firstOrNull;
    if (keyElement != null) {
      final fifths =
          int.tryParse(_findOptionalTextElement(keyElement, 'fifths') ?? '0') ??
              0;
      final mode = _findOptionalTextElement(keyElement, 'mode');
      keySignature = KeySignature(fifths: fifths, mode: mode);
    }

    // Parse time signature
    TimeSignature? timeSignature;
    final timeElement = element
        .findElements('attributes')
        .firstOrNull
        ?.findElements('time')
        .firstOrNull;
    if (timeElement != null) {
      final beatsText = _findOptionalTextElement(timeElement, 'beats');
      final beatTypeText = _findOptionalTextElement(timeElement, 'beat-type');

      if (beatsText != null && beatTypeText != null) {
        final beats = int.tryParse(beatsText) ?? 4;
        final beatType = int.tryParse(beatTypeText) ?? 4;
        timeSignature = TimeSignature(beats: beats, beatType: beatType);
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
      divisions = int.tryParse(divisionsElement.innerText) ?? 1;
    }

    // Parse notes
    final notes = <Note>[];
    for (final noteElement in element.findElements('note')) {
      final note = _parseNote(noteElement, divisions);
      if (note != null) {
        notes.add(note);
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

  Note? _parseNote(XmlElement element, int? parentDivisions) {
    // Check if it's a rest
    final isRest = element.findElements('rest').isNotEmpty;

    // Parse pitch (if not a rest)
    Pitch? pitch;
    if (!isRest) {
      final pitchElement = element.findElements('pitch').firstOrNull;
      if (pitchElement != null) {
        final step = _findOptionalTextElement(pitchElement, 'step');
        final octaveText = _findOptionalTextElement(pitchElement, 'octave');
        final alterText = _findOptionalTextElement(pitchElement, 'alter');

        if (step != null && octaveText != null) {
          final octave = int.tryParse(octaveText) ?? 4;
          final alter = alterText != null ? int.tryParse(alterText) : null;
          pitch = Pitch(step: step, octave: octave, alter: alter);
        }
      }
    }

    // Parse duration
    final durationText = _findOptionalTextElement(element, 'duration');
    if (durationText == null) {
      return null; // Skip notes without duration
    }

    final durationValue = int.tryParse(durationText) ?? 0;
    final divisions = parentDivisions ?? 1; // Default to 1 if not specified

    // Parse type
    final type = _findOptionalTextElement(element, 'type');

    // Parse voice
    final voiceText = _findOptionalTextElement(element, 'voice');
    final voice = voiceText != null ? int.tryParse(voiceText) : null;

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
      }
    }

    // Create note
    return Note(
      pitch: pitch,
      duration: Duration(value: durationValue, divisions: divisions),
      isRest: isRest,
      lyric: lyric,
      voice: voice,
      type: type,
      tiedStart: tiedStart,
      tiedEnd: tiedEnd,
    );
  }

  // Helper methods

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
