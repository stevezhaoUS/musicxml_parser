import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart'; // Added for backup/forward
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/barline.dart'; // Import for Barline
import 'package:musicxml_parser/src/models/beam.dart';
import 'package:musicxml_parser/src/models/ending.dart'; // Import for Ending
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/measure.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/models/direction_words.dart';
import 'package:musicxml_parser/src/models/print_object.dart'; // New import
import 'package:musicxml_parser/src/models/page_layout.dart'; // For PageLayout in PrintObject
import 'package:musicxml_parser/src/models/system_layout.dart'; // For SystemLayout in PrintObject
import 'package:musicxml_parser/src/models/staff_layout.dart'; // For StaffLayout in PrintObject
import 'package:musicxml_parser/src/parser/attributes_parser.dart';
import 'package:musicxml_parser/src/parser/page_layout_parser.dart'; // New import
import 'package:musicxml_parser/src/parser/system_layout_parser.dart'; // New import
import 'package:musicxml_parser/src/parser/staff_layout_parser.dart'; // New import
import 'package:musicxml_parser/src/parser/beam_parser.dart';
import 'package:musicxml_parser/src/parser/note_parser.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:xml/xml.dart';

/// Parser for MusicXML measure elements.
class MeasureParser {
  /// The parser for note elements.
  final NoteParser _noteParser;

  /// The parser for attributes elements.
  final AttributesParser _attributesParser;

  /// The warning system for collecting non-critical issues.
  final WarningSystem warningSystem;

  /// Creates a new [MeasureParser].
  ///
  /// [noteParser] - Optional note parser. If not provided, a new one will be created.
  /// [attributesParser] - Optional attributes parser. If not provided, a new one will be created.
  /// [warningSystem] - Optional warning system. If not provided, a new one will be created.
  MeasureParser({
    NoteParser? noteParser,
    AttributesParser? attributesParser,
    WarningSystem? warningSystem,
  })  : warningSystem = warningSystem ?? WarningSystem(),
        _noteParser = noteParser ??
            NoteParser(warningSystem: warningSystem ?? WarningSystem()),
        _attributesParser = attributesParser ?? const AttributesParser();

  /// Parses a measure element into a [Measure] object.
  ///
  /// [element] - The XML element representing the measure.
  /// [partId] - The ID of the part containing this measure.
  /// [inheritedDivisions] - The divisions value inherited from previous measures (if any).
  /// [inheritedKeySignature] - The key signature inherited from previous measures (if any).
  /// [inheritedTimeSignature] - The time signature inherited from previous measures (if any).
  Measure parse(
    XmlElement element,
    String partId, {
    int? inheritedDivisions,
    KeySignature? inheritedKeySignature,
    TimeSignature? inheritedTimeSignature,
  }) {
    final line = XmlHelper.getLineNumber(element);
    final implicit = element.getAttribute('implicit');
    // Get measure number (required)
    final number = element.getAttribute('number');

    if (number == null || number.isEmpty) {
      throw MusicXmlValidationException(
        'Measure number is required',
        context: {
          'part': partId,
          'line': line,
        },
      );
    }

    // Validate measure number
    final measureNum = int.tryParse(number);
    if (measureNum == null || measureNum < 0) {
      throw MusicXmlValidationException(
        'Invalid measure number: $number',
        context: {
          'part': partId,
          'measure': number,
          'line': line,
        },
      );
    }

    // Check for measure "0" - only valid for pickup measures with implicit="yes"
    final isPickup = (number == '0' && implicit == 'yes');
    if (measureNum == 0 && !isPickup) {
      throw MusicXmlValidationException(
        'Invalid measure number: $number',
        context: {
          'part': partId,
          'measure': number,
          'line': line,
        },
      );
    }

    // Get measure width (optional)
    final widthAttr = element.getAttribute('width');
    final width = widthAttr != null ? double.tryParse(widthAttr) : null;

    // Initialize MeasureBuilder
    final measureBuilder = MeasureBuilder(number, line: line, context: {'part': partId})
        .setIsPickup(isPickup)
        .setWidth(width)
        .setKeySignature(inheritedKeySignature) // Set initial inherited values
        .setTimeSignature(inheritedTimeSignature);

    int? currentDivisions = inheritedDivisions;
    final List<Beam> individualBeams = []; // Collect individual beams for later merging

    // Process measure content
    for (final child in element.childElements) {
      switch (child.name.local) {
        case 'attributes':
          final attributesData = _attributesParser.parse(child, partId, number, currentDivisions);
          currentDivisions = attributesData['divisions'] ?? currentDivisions;
          // Use the new values if present, otherwise keep what was inherited or previously set in the builder.
          if (attributesData['keySignature'] != null) {
            measureBuilder.setKeySignature(attributesData['keySignature']);
          }
          if (attributesData['timeSignature'] != null) {
            measureBuilder.setTimeSignature(attributesData['timeSignature']);
          }
          break;
        case 'note':
          final note = _noteParser.parse(child, currentDivisions, partId, number);
          if (note != null) {
            // To get the noteIndex, we need to know how many notes are already in the builder.
            // Assuming MeasureBuilder._notes is not directly accessible,
            // we might need a getter in MeasureBuilder or manage notes list temporarily here.
            // For simplicity, if MeasureBuilder's addNote is the only way notes are added,
            // the current length *before* adding is the index.
            final noteIndex = measureBuilder.debugGetNotesCount(); // Needs a temporary getter or local list
            measureBuilder.addNote(note);
            individualBeams.addAll(BeamParser.parse(child, noteIndex, number));
          }
          break;
        case 'backup':
          _parseBackupOrForward(child, 'backup', partId, number);
          break;
        case 'forward':
          _parseBackupOrForward(child, 'forward', partId, number);
          break;
        case 'barline':
          measureBuilder.addBarline(_parseBarline(child));
          break;
        case 'ending':
          measureBuilder.setEnding(_parseEnding(child, partId, number));
          break;
        case 'direction':
          // Assuming _parseDirection returns a list and builder has addAll or set method
          final directions = _parseDirection(child, partId, number);
          for (final dir in directions) {
            measureBuilder.addWordsDirection(dir);
          }
          break;
        case 'print':
          measureBuilder.setPrintObject(_parsePrint(child));
          break;
        // Other elements like harmony, figured-bass, sound, etc. can be added here
      }
    }

    // Merge beams
    measureBuilder.setBeams(BeamParser.mergeBeams(individualBeams, number));

    return measureBuilder.build();
  }

  /// Parses a <backup> or <forward> element.
  void _parseBackupOrForward(XmlElement element, String type, String partId, String measureNumber) {
    final durationElement = element.findElements('duration').firstOrNull;
    if (durationElement == null) {
      throw MusicXmlStructureException(
        "<$type> element missing required <duration> child.",
        parentElement: type,
        line: XmlHelper.getLineNumber(element),
        context: {'part': partId, 'measure': measureNumber},
      );
    }
    final int? duration = XmlHelper.getElementTextAsInt(durationElement);
    if (duration == null || duration < 0) {
      throw MusicXmlStructureException(
        "Invalid or missing duration value for <$type>.",
        parentElement: type,
        line: XmlHelper.getLineNumber(durationElement),
        context: {'part': partId, 'measure': measureNumber, 'parsedDuration': duration},
      );
    }
    warningSystem.addWarning(
      "Encountered <$type> with duration $duration. Full timeline impact not yet implemented.",
      category: 'partial_processing',
      rule: '${type}_partially_processed',
      context: {
        'element': type,
        'part': partId,
        'measure': measureNumber,
        'duration': duration,
        'line': XmlHelper.getLineNumber(element)
      },
    );
  }

  /// Parses a <barline> element.
  Barline _parseBarline(XmlElement barlineElement) {
    String? location = barlineElement.getAttribute('location');
    XmlElement? barStyleElement = barlineElement.findElements('bar-style').firstOrNull;
    String? barStyle = barStyleElement?.innerText.trim();
    XmlElement? repeatElement = barlineElement.findElements('repeat').firstOrNull;
    String? repeatDirection;
    int? repeatTimes;
    if (repeatElement != null) {
      repeatDirection = repeatElement.getAttribute('direction');
      String? timesStr = repeatElement.getAttribute('times');
      if (timesStr != null && timesStr.isNotEmpty) {
        repeatTimes = int.tryParse(timesStr);
      }
    }
    return Barline(
        location: location,
        barStyle: barStyle,
        repeatDirection: repeatDirection,
        times: repeatTimes);
  }

  /// Parses an <ending> element.
  Ending? _parseEnding(XmlElement endingElement, String partId, String measureNumber) {
    String? endingNumber = endingElement.getAttribute('number');
    if (endingNumber == null || endingNumber.isEmpty) {
        final textContent = endingElement.innerText.trim();
        if (textContent.isNotEmpty) {
            endingNumber = textContent;
        }
    }
    String? type = endingElement.getAttribute('type');
    String? printObjectAttr = endingElement.getAttribute('print-object');

    if (endingNumber != null && endingNumber.isNotEmpty && type != null && type.isNotEmpty) {
      return Ending(
          number: endingNumber,
          type: type,
          printObject: printObjectAttr ?? "yes");
    } else {
      warningSystem.addWarning(
        'Incomplete <ending> element in measure $measureNumber. Missing "number" or "type" attribute, or number text content.',
        category: WarningCategories.structure,
        line: XmlHelper.getLineNumber(endingElement),
        context: {'part': partId, 'measure': measureNumber},
      );
      return null;
    }
  }

  /// Parses a <direction> element for <words>.
  List<WordsDirection> _parseDirection(XmlElement directionElement, String partId, String measureNumber) {
    final wordsDirections = <WordsDirection>[];
    for (final directionTypeElement in directionElement.findElements('direction-type')) {
      for (final wordsElement in directionTypeElement.findElements('words')) {
        final text = wordsElement.innerText.trim();
        if (text.isNotEmpty) {
          wordsDirections.add(WordsDirection(text: text));
        } else {
          warningSystem.addWarning(
            'Empty <words> element found in direction.',
            category: WarningCategories.structure,
            line: XmlHelper.getLineNumber(wordsElement),
            context: {'part': partId, 'measure': measureNumber},
          );
        }
      }
      // TODO: Handle other direction-type children like <segno>, <coda>, <dynamics> etc. if needed in the future
    }
    // TODO: Handle other <direction> children like <offset>, <staff>, <sound> if needed
    return wordsDirections;
  }

  /// Parses a <print> element.
  PrintObject _parsePrint(XmlElement printElement) {
    final newPageAttr = printElement.getAttribute('new-page');
    final newSystemAttr = printElement.getAttribute('new-system');
    final blankPageStr = printElement.getAttribute('blank-page');
    final pageNumberStr = printElement.getAttribute('page-number');

    final newPage = newPageAttr == 'yes';
    final newSystem = newSystemAttr == 'yes';
    final blankPage = blankPageStr != null ? int.tryParse(blankPageStr) : null;

    PageLayout? localPageLayout;
    final pageLayoutElement = printElement.findElements('page-layout').firstOrNull;
    if (pageLayoutElement != null) {
      localPageLayout = PageLayoutParser().parse(pageLayoutElement);
    }

    SystemLayout? localSystemLayout;
    final systemLayoutElement = printElement.findElements('system-layout').firstOrNull;
    if (systemLayoutElement != null) {
      localSystemLayout = SystemLayoutParser().parse(systemLayoutElement);
    }

    List<StaffLayout> localStaffLayouts = [];
    for (final staffLayoutElement in printElement.findElements('staff-layout')) {
      localStaffLayouts.add(StaffLayoutParser().parse(staffLayoutElement));
    }

    // TODO: Parse <measure-layout> and <measure-numbering> if needed in the future

    return PrintObject(
      newPage: newPage,
      newSystem: newSystem,
      blankPage: blankPage,
      pageNumber: pageNumberStr,
      localPageLayout: localPageLayout,
      localSystemLayout: localSystemLayout,
      localStaffLayouts: localStaffLayouts,
    );
  }
}
