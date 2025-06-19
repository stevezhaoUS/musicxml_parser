import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/models/score.dart';
import 'package:musicxml_parser/src/parser/part_parser.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:xml/xml.dart';

/// Parser for MusicXML score elements.
class ScoreParser {
  /// The parser for part elements.
  final PartParser _partParser;

  /// The warning system for collecting non-critical issues.
  final WarningSystem warningSystem;

  /// Creates a new [ScoreParser].
  ///
  /// [partParser] - Optional part parser. If not provided, a new one will be created.
  /// [warningSystem] - Optional warning system. If not provided, a new one will be created.
  ScoreParser({
    PartParser? partParser,
    WarningSystem? warningSystem,
  })  : warningSystem = warningSystem ?? WarningSystem(),
        _partParser = partParser ?? PartParser(warningSystem: warningSystem ?? WarningSystem());

  /// Parses a MusicXML document into a [Score] object.
  ///
  /// [document] - The XML document to parse.
  Score parse(XmlDocument document) {
    // Check for score-partwise format (most common)
    final scorePartwise = document.findElements('score-partwise').firstOrNull;
    if (scorePartwise != null) {
      return _parseScorePartwise(scorePartwise);
    }

    // Check for score-timewise format
    final scoreTimewise = document.findElements('score-timewise').firstOrNull;
    if (scoreTimewise != null) {
      throw MusicXmlStructureException(
        'Score-timewise format is not fully implemented',
        requiredElement: 'score-partwise',
        parentElement: 'score-timewise',
        line: XmlHelper.getLineNumber(scoreTimewise),
      );
    }

    // Invalid MusicXML document
    throw MusicXmlStructureException(
      'Document is not a valid MusicXML file. Root element must be either "score-partwise" or "score-timewise"',
      requiredElement: 'score-partwise or score-timewise',
      line: XmlHelper.getLineNumber(document.rootElement),
    );
  }

  /// Parses a score-partwise element into a [Score] object.
  Score _parseScorePartwise(XmlElement element) {
    // Extract score metadata
    final title = XmlHelper.findOptionalTextElement(element, 'work/work-title') ??
        XmlHelper.findOptionalTextElement(element, 'movement-title');
    final composer = XmlHelper.findOptionalTextElement(
        element, 'identification/creator[@type="composer"]');
    final version = element.getAttribute('version');

    // Find part-list
    final partList = element.findElements('part-list').firstOrNull;
    
    if (partList == null) {
      warningSystem.addWarning(
        'Missing part-list element in score',
        category: 'structure',
        context: {
          'line': XmlHelper.getLineNumber(element),
        },
      );
    }

    // Parse parts
    final parts = element.findElements('part').map(
      (part) => _partParser.parse(part, partList),
    ).toList();

    return Score(
      title: title,
      composer: composer,
      parts: parts,
      version: version,
    );
  }
}
