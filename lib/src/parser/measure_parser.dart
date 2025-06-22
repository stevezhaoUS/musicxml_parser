import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart'; // Added for backup/forward
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/barline.dart'; // Import for Barline
import 'package:musicxml_parser/src/models/beam.dart';
import 'package:musicxml_parser/src/models/ending.dart'; // Import for Ending
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/measure.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/models/direction.dart';
import 'package:musicxml_parser/src/models/direction_words.dart';
import 'package:musicxml_parser/src/models/direction_type_elements.dart';
import 'package:musicxml_parser/src/models/print_object.dart'; // New import
import 'package:musicxml_parser/src/models/page_layout.dart'; // For PageLayout in PrintObject
import 'package:musicxml_parser/src/models/system_layout.dart'; // For SystemLayout in PrintObject
import 'package:musicxml_parser/src/models/staff_layout.dart'; // For StaffLayout in PrintObject
import 'package:musicxml_parser/src/models/measure_layout_info.dart'; // For MeasureLayout and MeasureNumbering
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
    final implicit = XmlHelper.getAttributeValue(element, 'implicit');
    // Get measure number (required)
    final number = XmlHelper.getAttributeValue(element, 'number');

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
    final widthAttr = XmlHelper.getAttributeValue(element, 'width');
    final width = widthAttr != null ? double.tryParse(widthAttr) : null;

    // Initialize MeasureBuilder
    final measureBuilder = MeasureBuilder(number,
            line: line, context: {'part': partId})
        .setIsPickup(isPickup)
        .setWidth(width)
        .setKeySignature(inheritedKeySignature) // Set initial inherited values
        .setTimeSignature(inheritedTimeSignature);

    int? currentDivisions = inheritedDivisions;
    final List<Beam> individualBeams =
        []; // Collect individual beams for later merging

    // Process measure content
    for (final child in element.childElements) {
      switch (child.name.local) {
        case 'attributes':
          final attributesData =
              _attributesParser.parse(child, partId, number, currentDivisions);
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
          final note =
              _noteParser.parse(child, currentDivisions, partId, number);
          if (note != null) {
            // To get the noteIndex, we need to know how many notes are already in the builder.
            // Assuming MeasureBuilder._notes is not directly accessible,
            // we might need a getter in MeasureBuilder or manage notes list temporarily here.
            // For simplicity, if MeasureBuilder's addNote is the only way notes are added,
            // the current length *before* adding is the index.
            final noteIndex = measureBuilder
                .debugGetNotesCount(); // Needs a temporary getter or local list
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
          final direction = _parseDirection(child, partId, number);
          if (direction != null) {
            measureBuilder.addDirection(direction);
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
  void _parseBackupOrForward(
      XmlElement element, String type, String partId, String measureNumber) {
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
        context: {
          'part': partId,
          'measure': measureNumber,
          'parsedDuration': duration
        },
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
    String? location = XmlHelper.getAttributeValue(barlineElement, 'location');
    XmlElement? barStyleElement =
        barlineElement.findElements('bar-style').firstOrNull;
    String? barStyle = barStyleElement?.innerText.trim();
    XmlElement? repeatElement =
        barlineElement.findElements('repeat').firstOrNull;
    String? repeatDirection;
    int? repeatTimes;
    if (repeatElement != null) {
      repeatDirection = XmlHelper.getAttributeValue(repeatElement, 'direction');
      String? timesStr = XmlHelper.getAttributeValue(repeatElement, 'times');
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
  Ending? _parseEnding(
      XmlElement endingElement, String partId, String measureNumber) {
    String? endingNumber = XmlHelper.getAttributeValue(endingElement, 'number');
    if (endingNumber == null || endingNumber.isEmpty) {
      final textContent = endingElement.innerText.trim();
      if (textContent.isNotEmpty) {
        endingNumber = textContent;
      }
    }
    String? type = XmlHelper.getAttributeValue(endingElement, 'type');
    String? printObjectAttr =
        XmlHelper.getAttributeValue(endingElement, 'print-object');

    if (endingNumber != null &&
        endingNumber.isNotEmpty &&
        type != null &&
        type.isNotEmpty) {
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

  /// Parses a <direction> element.
  Direction? _parseDirection(
      XmlElement directionElement, String partId, String measureNumber) {
    final directionTypeElements = <DirectionTypeElement>[];
    Offset? parsedOffset;
    Staff? parsedStaff;
    Sound? parsedSound;

    // Parse <direction-type> elements first
    for (final directionTypeElementXml
        in directionElement.findElements('direction-type')) {
      for (final childElement in directionTypeElementXml.childElements) {
        switch (childElement.name.local) {
          case 'words':
            final text = childElement.innerText.trim();
            // Always add the WordsDirection, even if the text is empty
            directionTypeElements.add(WordsDirection(
              text: text,
              color: XmlHelper.getAttributeValue(childElement, 'color'),
              defaultX: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'default-x'),
              defaultY: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'default-y'),
              dir: XmlHelper.getAttributeValue(childElement, 'dir'),
              enclosure: XmlHelper.getAttributeValue(childElement, 'enclosure'),
              fontFamily:
                  XmlHelper.getAttributeValue(childElement, 'font-family'),
              fontSize: XmlHelper.getAttributeValue(childElement, 'font-size'),
              fontStyle:
                  XmlHelper.getAttributeValue(childElement, 'font-style'),
              fontWeight:
                  XmlHelper.getAttributeValue(childElement, 'font-weight'),
              halign: XmlHelper.getAttributeValue(childElement, 'halign'),
              id: XmlHelper.getAttributeValue(childElement, 'id'),
              justify: XmlHelper.getAttributeValue(childElement, 'justify'),
              letterSpacing:
                  XmlHelper.getAttributeValue(childElement, 'letter-spacing'),
              lineHeight:
                  XmlHelper.getAttributeValue(childElement, 'line-height'),
              lineThrough: XmlHelper.getAttributeValueAsInt(
                  childElement, 'line-through'),
              overline:
                  XmlHelper.getAttributeValueAsInt(childElement, 'overline'),
              relativeX: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'relative-x'),
              relativeY: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'relative-y'),
              rotation:
                  XmlHelper.getAttributeValueAsDouble(childElement, 'rotation'),
              underline:
                  XmlHelper.getAttributeValueAsInt(childElement, 'underline'),
              valign: XmlHelper.getAttributeValue(childElement, 'valign'),
              xmlLang: XmlHelper.getAttributeValue(childElement, 'xml:lang'),
              xmlSpace: XmlHelper.getAttributeValue(childElement, 'xml:space'),
            ));

            // Add a warning if text is empty
            if (text.isEmpty) {
              warningSystem.addWarning(
                'Empty <words> element found in direction.',
                category: WarningCategories.structure,
                line: XmlHelper.getLineNumber(childElement),
                context: {'part': partId, 'measure': measureNumber},
              );
            }
            break;
          case 'segno':
            directionTypeElements.add(Segno(
              color: XmlHelper.getAttributeValue(childElement, 'color'),
              defaultX: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'default-x'),
              defaultY: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'default-y'),
              fontFamily:
                  XmlHelper.getAttributeValue(childElement, 'font-family'),
              fontSize: XmlHelper.getAttributeValue(childElement, 'font-size'),
              fontStyle:
                  XmlHelper.getAttributeValue(childElement, 'font-style'),
              fontWeight:
                  XmlHelper.getAttributeValue(childElement, 'font-weight'),
              halign: XmlHelper.getAttributeValue(childElement, 'halign'),
              id: XmlHelper.getAttributeValue(childElement, 'id'),
              relativeX: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'relative-x'),
              relativeY: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'relative-y'),
              smufl: XmlHelper.getAttributeValue(childElement, 'smufl'),
              valign: XmlHelper.getAttributeValue(childElement, 'valign'),
            ));
            break;
          case 'coda':
            directionTypeElements.add(Coda(
              color: XmlHelper.getAttributeValue(childElement, 'color'),
              defaultX: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'default-x'),
              defaultY: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'default-y'),
              fontFamily:
                  XmlHelper.getAttributeValue(childElement, 'font-family'),
              fontSize: XmlHelper.getAttributeValue(childElement, 'font-size'),
              fontStyle:
                  XmlHelper.getAttributeValue(childElement, 'font-style'),
              fontWeight:
                  XmlHelper.getAttributeValue(childElement, 'font-weight'),
              halign: XmlHelper.getAttributeValue(childElement, 'halign'),
              id: XmlHelper.getAttributeValue(childElement, 'id'),
              relativeX: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'relative-x'),
              relativeY: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'relative-y'),
              smufl: XmlHelper.getAttributeValue(childElement, 'smufl'),
              valign: XmlHelper.getAttributeValue(childElement, 'valign'),
            ));
            break;
          case 'dynamics':
            final dynamicValues = <String>[];
            for (final dynamicChild in childElement.childElements) {
              if (dynamicChild.name.local == 'other-dynamics') {
                final text = dynamicChild.innerText.trim();
                if (text.isNotEmpty) {
                  dynamicValues.add(text);
                }
              } else {
                dynamicValues.add(dynamicChild.name.local);
              }
            }
            directionTypeElements.add(Dynamics(
              values: dynamicValues,
              color: XmlHelper.getAttributeValue(childElement, 'color'),
              defaultX: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'default-x'),
              defaultY: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'default-y'),
              enclosure: XmlHelper.getAttributeValue(childElement, 'enclosure'),
              fontFamily:
                  XmlHelper.getAttributeValue(childElement, 'font-family'),
              fontSize: XmlHelper.getAttributeValue(childElement, 'font-size'),
              fontStyle:
                  XmlHelper.getAttributeValue(childElement, 'font-style'),
              fontWeight:
                  XmlHelper.getAttributeValue(childElement, 'font-weight'),
              halign: XmlHelper.getAttributeValue(childElement, 'halign'),
              id: XmlHelper.getAttributeValue(childElement, 'id'),
              lineThrough: XmlHelper.getAttributeValueAsInt(
                  childElement, 'line-through'),
              overline:
                  XmlHelper.getAttributeValueAsInt(childElement, 'overline'),
              placement: XmlHelper.getAttributeValue(childElement, 'placement'),
              relativeX: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'relative-x'),
              relativeY: XmlHelper.getAttributeValueAsDouble(
                  childElement, 'relative-y'),
              underline:
                  XmlHelper.getAttributeValueAsInt(childElement, 'underline'),
              valign: XmlHelper.getAttributeValue(childElement, 'valign'),
            ));
            break;
        }
      }
    }

    // Parse other direct children of <direction>
    final offsetElement = directionElement.findElements('offset').firstOrNull;
    if (offsetElement != null) {
      final value = XmlHelper.getElementTextAsDouble(offsetElement);
      if (value != null) {
        parsedOffset = Offset(
          value: value,
          sound: XmlHelper.getAttributeValue(offsetElement, 'sound') == 'yes',
        );
      }
    }

    final staffElement = directionElement.findElements('staff').firstOrNull;
    if (staffElement != null) {
      final value = XmlHelper.getElementTextAsInt(staffElement);
      if (value != null) {
        parsedStaff = Staff(value: value);
      }
    }

    final soundElement = directionElement.findElements('sound').firstOrNull;
    if (soundElement != null) {
      final timeOnlyValue =
          XmlHelper.getAttributeValue(soundElement, 'time-only');
      parsedSound = Sound(
        tempo: XmlHelper.getAttributeValueAsDouble(soundElement, 'tempo'),
        dynamics: XmlHelper.getAttributeValueAsDouble(soundElement, 'dynamics'),
        dacapo: XmlHelper.getAttributeValue(soundElement, 'dacapo') == 'yes',
        segno: XmlHelper.getAttributeValue(soundElement, 'segno'),
        coda: XmlHelper.getAttributeValue(soundElement, 'coda'),
        fine: XmlHelper.getAttributeValue(soundElement, 'fine'),
        timeOnly: timeOnlyValue == null ? null : timeOnlyValue == 'yes',
        pizzicato:
            XmlHelper.getAttributeValue(soundElement, 'pizzicato') == 'yes',
        pan: XmlHelper.getAttributeValueAsDouble(soundElement, 'pan'),
        elevation:
            XmlHelper.getAttributeValueAsDouble(soundElement, 'elevation'),
      );
    }

    // A <direction> element MUST have at least one <direction-type> child
    // to be considered valid by this parser.
    // Other elements like <offset>, <staff>, <sound>, or attributes on <direction> itself
    // are considered supplementary if <direction-type> is present, but do not
    // make a <direction> valid on their own without a <direction-type>.
    if (directionTypeElements.isEmpty) {
      warningSystem.addWarning(
        'Direction element without any <direction-type> children. Skipping this direction.', // Positional message
        category: WarningCategories.structure,
        element: directionElement.name.local, // Corrected parameter name
        line: XmlHelper.getLineNumber(directionElement),
        context: {'part': partId, 'measure': measureNumber},
      );
      return null;
    }

    return Direction(
      directionTypes: directionTypeElements,
      offset: parsedOffset,
      staff: parsedStaff,
      sound: parsedSound,
      placement: XmlHelper.getAttributeValue(directionElement, 'placement'),
      directive: XmlHelper.getAttributeValue(directionElement, 'directive'),
      system: XmlHelper.getAttributeValue(directionElement, 'system'),
      id: XmlHelper.getAttributeValue(directionElement, 'id'),
    );
  }

  /// Parses a <print> element.
  PrintObject _parsePrint(XmlElement printElement) {
    final newPageAttr = XmlHelper.getAttributeValue(printElement, 'new-page');
    final newSystemAttr =
        XmlHelper.getAttributeValue(printElement, 'new-system');
    final blankPageStr =
        XmlHelper.getAttributeValue(printElement, 'blank-page');
    final pageNumberStr =
        XmlHelper.getAttributeValue(printElement, 'page-number');

    final newPage = newPageAttr == 'yes';
    final newSystem = newSystemAttr == 'yes';
    final blankPage = blankPageStr != null ? int.tryParse(blankPageStr) : null;

    PageLayout? localPageLayout;
    final pageLayoutElement =
        printElement.findElements('page-layout').firstOrNull;
    if (pageLayoutElement != null) {
      localPageLayout = PageLayoutParser().parse(pageLayoutElement);
    }

    SystemLayout? localSystemLayout;
    final systemLayoutElement =
        printElement.findElements('system-layout').firstOrNull;
    if (systemLayoutElement != null) {
      localSystemLayout = SystemLayoutParser().parse(systemLayoutElement);
    }

    List<StaffLayout> localStaffLayouts = [];
    for (final staffLayoutElement
        in printElement.findElements('staff-layout')) {
      localStaffLayouts.add(StaffLayoutParser().parse(staffLayoutElement));
    }

    MeasureLayout? measureLayout;
    final measureLayoutElement =
        printElement.findElements('measure-layout').firstOrNull;
    if (measureLayoutElement != null) {
      final measureDistanceElement =
          measureLayoutElement.findElements('measure-distance').firstOrNull;
      if (measureDistanceElement != null) {
        measureLayout = MeasureLayout(
            measureDistance:
                XmlHelper.getElementTextAsDouble(measureDistanceElement));
      } else {
        measureLayout = const MeasureLayout(); // Element present but empty
      }
    }

    MeasureNumbering? measureNumbering;
    final measureNumberingElement =
        printElement.findElements('measure-numbering').firstOrNull;
    if (measureNumberingElement != null) {
      measureNumbering = MeasureNumbering(
        value: MeasureNumbering.parseValue(
            measureNumberingElement.innerText.trim()),
        color: XmlHelper.getAttributeValue(measureNumberingElement, 'color'),
        defaultX: XmlHelper.getAttributeValueAsDouble(
            measureNumberingElement, 'default-x'),
        defaultY: XmlHelper.getAttributeValueAsDouble(
            measureNumberingElement, 'default-y'),
        fontFamily:
            XmlHelper.getAttributeValue(measureNumberingElement, 'font-family'),
        fontSize:
            XmlHelper.getAttributeValue(measureNumberingElement, 'font-size'),
        fontStyle:
            XmlHelper.getAttributeValue(measureNumberingElement, 'font-style'),
        fontWeight:
            XmlHelper.getAttributeValue(measureNumberingElement, 'font-weight'),
        halign: XmlHelper.getAttributeValue(measureNumberingElement, 'halign'),
        multipleRestAlways: XmlHelper.getAttributeValue(
                measureNumberingElement, 'multiple-rest-always') ==
            'yes',
        multipleRestRange: XmlHelper.getAttributeValue(
                measureNumberingElement, 'multiple-rest-range') ==
            'yes',
        relativeX: XmlHelper.getAttributeValueAsDouble(
            measureNumberingElement, 'relative-x'),
        relativeY: XmlHelper.getAttributeValueAsDouble(
            measureNumberingElement, 'relative-y'),
        staff:
            XmlHelper.getAttributeValueAsInt(measureNumberingElement, 'staff'),
        system: XmlHelper.getAttributeValue(measureNumberingElement, 'system'),
        valign: XmlHelper.getAttributeValue(measureNumberingElement, 'valign'),
      );
    }

    return PrintObject(
      newPage: newPage,
      newSystem: newSystem,
      blankPage: blankPage,
      pageNumber: pageNumberStr,
      localPageLayout: localPageLayout,
      localSystemLayout: localSystemLayout,
      localStaffLayouts: localStaffLayouts,
      measureLayout: measureLayout,
      measureNumbering: measureNumbering,
    );
  }
}
