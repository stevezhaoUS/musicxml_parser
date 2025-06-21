import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/models/appearance.dart';
import 'package:musicxml_parser/src/models/credit.dart'; // Import for Credit
import 'package:musicxml_parser/src/models/identification.dart';
import 'package:musicxml_parser/src/models/page_layout.dart';
import 'package:musicxml_parser/src/models/score.dart';
import 'package:musicxml_parser/src/models/staff_layout.dart'; // New import
import 'package:musicxml_parser/src/models/system_layout.dart'; // New import
import 'package:musicxml_parser/src/models/work.dart';
import 'package:musicxml_parser/src/parser/page_layout_parser.dart'; // New import
import 'package:musicxml_parser/src/parser/part_parser.dart';
import 'package:musicxml_parser/src/parser/staff_layout_parser.dart'; // New import
import 'package:musicxml_parser/src/parser/system_layout_parser.dart'; // New import
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
        _partParser = partParser ??
            PartParser(warningSystem: warningSystem ?? WarningSystem());

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
    final title =
        XmlHelper.findOptionalTextElement(element, 'work/work-title') ??
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
    final parts = element
        .findElements('part')
        .map(
          (part) => _partParser.parse(part, partList),
        )
        .toList();

    // Parse defaults section
    final defaults = _parseDefaults(element.getElement('defaults'));

    // Initialize ScoreBuilder
    final scoreBuilder = ScoreBuilder(version: version, line: XmlHelper.getLineNumber(element))
        .setTitle(title)
        .setComposer(composer);

    // Set parts
    scoreBuilder.setParts(parts);

    // Set defaults
    scoreBuilder
        .setPageLayout(defaults.pageLayout)
        .setDefaultSystemLayout(defaults.systemLayout)
        .setDefaultStaffLayouts(defaults.staffLayouts)
        .setScaling(defaults.scaling)
        .setAppearance(defaults.appearance);

    // Set work and identification
    if (title != null) {
      scoreBuilder.setWork(Work(title: title));
    }
    if (composer != null) {
      scoreBuilder.setIdentification(Identification(composer: composer));
    }

    // Set credits
    final parsedCredits = _parseCredits(element);
    if (parsedCredits.isNotEmpty) {
      scoreBuilder.setCredits(parsedCredits);
    }

    return scoreBuilder.build();
  }

  /// Helper structure to hold parsed default values.
  _DefaultsData _parseDefaults(XmlElement? defaultsElement) {
    if (defaultsElement == null) {
      return _DefaultsData();
    }

    final scaling = defaultsElement.getElement('scaling') != null
        ? ScalingParser().parse(defaultsElement.getElement('scaling')!)
        : null;

    final pageLayout = defaultsElement.getElement('page-layout') != null
        ? PageLayoutParser().parse(defaultsElement.getElement('page-layout')!)
        : null;

    final systemLayout = defaultsElement.getElement('system-layout') != null
        ? SystemLayoutParser().parse(defaultsElement.getElement('system-layout')!)
        : null;

    final staffLayouts = defaultsElement
        .findElements('staff-layout')
        .map((el) => StaffLayoutParser().parse(el))
        .toList();

    final appearance = _parseAppearance(defaultsElement);

    return _DefaultsData(
      scaling: scaling,
      pageLayout: pageLayout,
      systemLayout: systemLayout,
      staffLayouts: staffLayouts,
      appearance: appearance,
    );
  }

  List<Credit> _parseCredits(XmlElement scoreElement) {
    List<Credit> parsedCredits = [];
    final creditElements = scoreElement.findElements('credit');
    for (final creditElement in creditElements) {
      String? pageStr = creditElement.getAttribute('page');
      int? page = (pageStr != null && pageStr.isNotEmpty ? int.tryParse(pageStr) : null);

      XmlElement? creditTypeElement = creditElement.findElements('credit-type').firstOrNull;
      String? creditType = creditTypeElement?.innerText.trim();

      List<String> creditWordsList = [];
      final creditWordsElements = creditElement.findElements('credit-words');
      for (final wordsElement in creditWordsElements) {
        final text = wordsElement.innerText.trim();
        if (text.isNotEmpty) {
            creditWordsList.add(text);
        }
      }

      if ((creditType != null && creditType.isNotEmpty) || creditWordsList.isNotEmpty) {
         parsedCredits.add(Credit(page: page, creditType: creditType, creditWords: creditWordsList));
      } else if (page != null) {
         parsedCredits.add(Credit(page: page, creditType: creditType, creditWords: creditWordsList));
      }
    }
    return parsedCredits;
  }

  /// Parses the appearance information from the defaults element.
  Appearance? _parseAppearance(XmlElement? defaultsElement) {
    if (defaultsElement == null) return null;
    final appearanceElement = defaultsElement.getElement('appearance');
    if (appearanceElement == null) return null;

    final lineWidths = <LineWidth>[];
    final noteSizes = <NoteSize>[];

    // Parse line widths
    for (final lineWidthElement
        in appearanceElement.findElements('line-width')) {
      final type = lineWidthElement.getAttribute('type');
      if (type == null) continue;

      final width = double.tryParse(lineWidthElement.innerText);
      if (width == null) continue;

      lineWidths.add(LineWidth(
        type: type,
        width: width,
      ));
    }

    // Parse note sizes
    for (final noteSizeElement in appearanceElement.findElements('note-size')) {
      final type = noteSizeElement.getAttribute('type');
      if (type == null) continue;

      final size = double.tryParse(noteSizeElement.innerText);
      if (size == null) continue;

      noteSizes.add(NoteSize(
        type: type,
        size: size,
      ));
    }

    return Appearance(
      lineWidths: lineWidths,
      noteSizes: noteSizes,
    );
  }
}

/// Helper class to store parsed data from the <defaults> element.
class _DefaultsData {
  final Scaling? scaling;
  final PageLayout? pageLayout;
  final SystemLayout? systemLayout;
  final List<StaffLayout> staffLayouts;
  final Appearance? appearance;

  _DefaultsData({
    this.scaling,
    this.pageLayout,
    this.systemLayout,
    this.staffLayouts = const [],
    this.appearance,
  });
}
