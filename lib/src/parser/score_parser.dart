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

    // Parse defaults section if it exists
    final defaultsElement = element.getElement('defaults');
    Scaling? scaling;
    PageLayout? pageLayout; // This will be defaultPageLayout
    SystemLayout? defaultSystemLayout;
    List<StaffLayout> defaultStaffLayouts = [];
    Appearance? appearance;

    if (defaultsElement != null) {
      final scalingElement = defaultsElement.getElement('scaling');
      if (scalingElement != null) {
        scaling = ScalingParser().parse(scalingElement);
      }

      final pageLayoutElement = defaultsElement.getElement('page-layout');
      if (pageLayoutElement != null) {
        pageLayout = PageLayoutParser().parse(pageLayoutElement);
      }

      final systemLayoutElement = defaultsElement.getElement('system-layout');
      if (systemLayoutElement != null) {
        defaultSystemLayout = SystemLayoutParser().parse(systemLayoutElement);
      }

      for (final staffLayoutElement in defaultsElement.findElements('staff-layout')) {
        defaultStaffLayouts.add(StaffLayoutParser().parse(staffLayoutElement));
      }

      appearance = _parseAppearance(defaultsElement); // Keep existing appearance parsing
    }

    // Create work object if title is available
    Work? work;
    if (title != null) {
      work = Work(title: title);
    }

    // Create identification object if composer is available
    Identification? identification;
    if (composer != null) {
      identification = Identification(composer: composer);
    }

    // Parse credits
    List<Credit> parsedCredits = [];
    final creditElements = element.findElements('credit');
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
      // Only add credit if it has some content (either type or words)
      // This avoids adding empty Credit objects if a <credit> tag is empty or only has a page number.
      if ((creditType != null && creditType.isNotEmpty) || creditWordsList.isNotEmpty) {
         parsedCredits.add(Credit(page: page, creditType: creditType, creditWords: creditWordsList));
      } else if (page != null) {
        // If only a page number is present with no other content, we might still want to record it,
        // or log a warning if such a credit is considered incomplete.
        // For now, let's add it if it has a page, even if type/words are empty.
        // Alternatively, one could decide that a credit needs at least a type or some words.
        // The current Credit model defaults creditWords to const [], so an empty list is fine.
         parsedCredits.add(Credit(page: page, creditType: creditType, creditWords: creditWordsList));
      }
    }

    return Score(
      version: version ?? "3.0", // Default to "3.0" if version is not specified
      work: work,
      identification: identification,
      parts: parts,
      pageLayout: pageLayout, // This is the defaultPageLayout
      defaultSystemLayout: defaultSystemLayout,
      defaultStaffLayouts: defaultStaffLayouts,
      scaling: scaling,
      appearance: appearance,
      title: title,
      composer: composer,
      credits: parsedCredits.isNotEmpty ? parsedCredits : null,
    );
  }

  // _parseScaling and _parsePageLayout are no longer needed as we use dedicated parsers.

  /// Parses the appearance information from the defaults element.
  Appearance? _parseAppearance(XmlElement defaultsElement) {
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
