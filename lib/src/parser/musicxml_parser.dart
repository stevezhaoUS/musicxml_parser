import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
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
  /// This method handles both plain XML files (.xml, .musicxml) and
  /// compressed MXL files (.mxl).
  Future<Score> parseFromFile(String path) async {
    try {
      final file = File(path);
      final xmlString = await file.readAsString();
      return parse(xmlString);
    } catch (e) {
      throw MusicXmlParseException(
        'Failed to parse file $path: ${e.toString()}',
      );
    }
  }

  /// contains invalid MusicXML.
  @Deprecated('Use parseFile instead, which provides better error handling')
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

  /// Parses a MusicXML string or compressed MXL data into a [Score] object.
  ///
  /// This method automatically detects whether the input is plain XML text or
  /// compressed MXL data (ZIP format) and handles it accordingly.
  ///
  /// Throws specific exception types based on the error:
  /// - [MusicXmlParseException] for XML parsing or decompression issues
  /// - [MusicXmlStructureException] for structural problems
  /// - [MusicXmlValidationException] for validation issues
  Score parseData(List<int> data) {
    try {
      // Check if this is a compressed MXL file (ZIP format)
      if (_isCompressedMxl(data)) {
        final xmlString = _extractMusicXmlFromMxl(data);
        return parse(xmlString);
      } else {
        // Try to parse as plain XML
        final xmlString = utf8.decode(data);
        return parse(xmlString);
      }
    } catch (e) {
      if (e is MusicXmlParseException ||
          e is MusicXmlStructureException ||
          e is MusicXmlValidationException) {
        rethrow;
      }
      throw MusicXmlParseException(
        'Failed to parse MusicXML data: ${e.toString()}',
      );
    }
  }

  /// Parses a MusicXML file into a [Score] object.
  ///
  /// This method handles both plain XML files (.xml, .musicxml) and
  /// compressed MXL files (.mxl).
  ///
  /// Throws specific exception types based on the error:
  /// - [MusicXmlParseException] for XML parsing or file access issues
  /// - [MusicXmlStructureException] for structural problems
  /// - [MusicXmlValidationException] for validation issues
  Future<Score> parseFile(String filePath) async {
    try {
      final file = File(filePath);
      final data = await file.readAsBytes();
      return parseData(data);
    } catch (e) {
      if (e is MusicXmlParseException ||
          e is MusicXmlStructureException ||
          e is MusicXmlValidationException) {
        rethrow;
      }
      throw MusicXmlParseException(
        'Failed to read or parse file $filePath: ${e.toString()}',
      );
    }
  }

  /// Synchronous version of [parseFile].
  ///
  /// This method handles both plain XML files (.xml, .musicxml) and
  /// compressed MXL files (.mxl).
  ///
  /// Throws specific exception types based on the error:
  /// - [MusicXmlParseException] for XML parsing or file access issues
  /// - [MusicXmlStructureException] for structural problems
  /// - [MusicXmlValidationException] for validation issues
  Score parseFileSync(String filePath) {
    try {
      final file = File(filePath);
      final data = file.readAsBytesSync();
      return parseData(data);
    } catch (e) {
      if (e is MusicXmlParseException ||
          e is MusicXmlStructureException ||
          e is MusicXmlValidationException) {
        rethrow;
      }
      throw MusicXmlParseException(
        'Failed to read or parse file $filePath: ${e.toString()}',
      );
    }
  }

  /// Checks if the given data is a compressed MXL file (ZIP format).
  bool _isCompressedMxl(List<int> data) {
    // ZIP files start with the signature PK\x03\x04 (0x50 0x4B 0x03 0x04)
    if (data.length < 4) return false;
    return data[0] == 0x50 &&
        data[1] == 0x4B &&
        data[2] == 0x03 &&
        data[3] == 0x04;
  }

  /// Extracts the MusicXML content from a compressed MXL file.
  String _extractMusicXmlFromMxl(List<int> data) {
    try {
      // Decode the ZIP archive
      final archive = ZipDecoder().decodeBytes(data);

      // First, try to find a container.xml file which specifies the main MusicXML file
      final containerFile = archive.findFile('META-INF/container.xml');
      if (containerFile != null) {
        final containerContent =
            utf8.decode(containerFile.content as List<int>);
        final containerDoc = XmlDocument.parse(containerContent);

        // Extract the rootfile path from container.xml
        final rootfileElement =
            containerDoc.findAllElements('rootfile').firstOrNull;
        if (rootfileElement != null) {
          final fullPath = rootfileElement.getAttribute('full-path');
          if (fullPath != null) {
            final mainFile = archive.findFile(fullPath);
            if (mainFile != null) {
              return utf8.decode(mainFile.content as List<int>);
            }
          }
        }
      }

      // If no container.xml or couldn't find the specified file,
      // look for any .xml file (preferably one that seems like MusicXML)
      for (final file in archive.files) {
        if (file.name.endsWith('.xml') || file.name.endsWith('.musicxml')) {
          // Prefer files in the root directory
          if (!file.name.contains('/')) {
            return utf8.decode(file.content as List<int>);
          }
        }
      }

      // Still no luck, try any XML file in the archive
      for (final file in archive.files) {
        if (file.name.endsWith('.xml')) {
          return utf8.decode(file.content as List<int>);
        }
      }

      throw MusicXmlParseException(
        'No valid MusicXML content found in the compressed MXL file.',
      );
    } catch (e) {
      if (e is MusicXmlParseException) rethrow;
      throw MusicXmlParseException(
        'Failed to extract MusicXML from compressed MXL file: ${e.toString()}',
      );
    }
  }
}
