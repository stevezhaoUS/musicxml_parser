import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:musicxml_parser/src/exceptions/musicxml_parse_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/score.dart';
import 'package:musicxml_parser/src/parser/score_parser.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

/// The main parser class for MusicXML files.
///
/// This class serves as the entry point for parsing MusicXML content.
/// It delegates the actual parsing to specialized parser components.
class MusicXmlParser {
  /// The score parser component.
  final ScoreParser _scoreParser;
  
  /// The warning system for collecting non-critical issues.
  final WarningSystem warningSystem;

  /// Creates a new [MusicXmlParser].
  ///
  /// [scoreParser] - Optional score parser. If not provided, a new one will be created.
  /// [warningSystem] - Optional warning system. If not provided, a new one will be created.
  MusicXmlParser({
    ScoreParser? scoreParser,
    WarningSystem? warningSystem,
  })  : _scoreParser = scoreParser ?? ScoreParser(warningSystem: warningSystem),
        warningSystem = warningSystem ?? WarningSystem();

  /// Parses a MusicXML string into a [Score] object.
  ///
  /// Throws specific exception types based on the error:
  /// - [MusicXmlParseException] for XML parsing issues
  /// - [MusicXmlStructureException] for structural problems
  /// - [MusicXmlValidationException] for validation issues
  Score parse(String xmlString) {
    try {
      final document = XmlDocument.parse(xmlString);
      return _scoreParser.parse(document);
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
}
