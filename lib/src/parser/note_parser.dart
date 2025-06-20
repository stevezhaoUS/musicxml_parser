import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
// Removed duplicate import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/articulation.dart'; // Import for Articulation
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/models/slur.dart'; // Import for Slur
import 'package:musicxml_parser/src/models/time_modification.dart';
import 'package:musicxml_parser/src/parser/xml_helper.dart';
import 'package:musicxml_parser/src/utils/validation_utils.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';
import 'package:xml/xml.dart';

/// Parser for MusicXML note elements.
class NoteParser {
  /// The warning system for collecting non-critical issues.
  final WarningSystem warningSystem;

  /// Creates a new [NoteParser].
  ///
  /// [warningSystem] - Optional warning system. If not provided, a new one will be created.
  NoteParser({WarningSystem? warningSystem})
      : warningSystem = warningSystem ?? WarningSystem();

  /// Parses a note element into a [Note] object.
  ///
  /// [element] - The XML element representing the note.
  /// [parentDivisions] - The divisions value from the parent measure.
  /// [partId] - The ID of the part containing this note.
  /// [measureNumber] - The number of the measure containing this note.
  Note? parse(
    XmlElement element,
    int? parentDivisions,
    String partId,
    String measureNumber,
  ) {
    final line = XmlHelper.getLineNumber(element);

    // Check if it's a rest
    final isRest = element.findElements('rest').isNotEmpty;

    // Parse pitch (if not a rest)
    Pitch? pitch;
    if (!isRest) {
      final pitchElement = element.findElements('pitch').firstOrNull;
      if (pitchElement == null) {
        throw MusicXmlStructureException(
          'Non-rest note is missing pitch element',
          requiredElement: 'pitch',
          parentElement: 'note',
          line: line,
        );
      }
      pitch = _parsePitch(pitchElement, partId, measureNumber);
    }

    // Parse duration
    final durationElement = element.findElements('duration').firstOrNull;
    Duration? duration;
    if (durationElement != null) {
      final durationValue = XmlHelper.getElementTextAsInt(durationElement);

      if (durationValue != null && durationValue >= 0) {
        if (parentDivisions == null || parentDivisions <= 0) {
          warningSystem.addWarning(
            'No valid divisions specified for note. Using default value 1.',
            category: 'note_divisions',
            context: {
              'part': partId,
              'measure': measureNumber,
              'line': line,
            },
          );
          parentDivisions = 1;
        }

        duration = Duration(
          value: durationValue,
          divisions: parentDivisions,
        );
      } else {
        warningSystem.addWarning(
          'Invalid duration value: $durationValue',
          category: 'note_duration',
          context: {
            'part': partId,
            'measure': measureNumber,
            'line': line,
          },
        );
        return null;
      }
    } else {
      // Duration is optional but recommended for most notes
      warningSystem.addWarning(
        'Note without duration',
        category: WarningCategories.duration,
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    // Parse note type
    final typeElement = element.findElements('type').firstOrNull;
    final type = typeElement?.innerText.trim();

    // Parse voice
    final voiceElement = element.findElements('voice').firstOrNull;
    final voice = voiceElement?.innerText.trim();
    final voiceNum = voice != null ? int.tryParse(voice) : null;

    // Parse dots
    final dotElements = element.findElements('dot');
    final int? dotsCount = dotElements.isNotEmpty ? dotElements.length : null;

    // Parse time modification
    TimeModification? timeModification;
    final timeModificationElement = element.findElements('time-modification').firstOrNull;

    if (timeModificationElement != null) {
      final tmLine = XmlHelper.getLineNumber(timeModificationElement);
      final actualNotesElement = timeModificationElement.findElements('actual-notes').firstOrNull;
      final normalNotesElement = timeModificationElement.findElements('normal-notes').firstOrNull;

      if (actualNotesElement == null) {
        throw MusicXmlStructureException(
          '<time-modification> is missing <actual-notes> element',
          requiredElement: 'actual-notes',
          parentElement: 'time-modification',
          line: tmLine,
          context: {'part': partId, 'measure': measureNumber},
        );
      }
      if (normalNotesElement == null) {
        throw MusicXmlStructureException(
          '<time-modification> is missing <normal-notes> element',
          requiredElement: 'normal-notes',
          parentElement: 'time-modification',
          line: tmLine,
          context: {'part': partId, 'measure': measureNumber},
        );
      }

      final actualNotes = XmlHelper.getElementTextAsInt(actualNotesElement);
      final normalNotes = XmlHelper.getElementTextAsInt(normalNotesElement);

      if (actualNotes == null) {
        throw MusicXmlStructureException(
          '<actual-notes> must contain an integer value',
          parentElement: 'time-modification',
          line: XmlHelper.getLineNumber(actualNotesElement),
          context: {'part': partId, 'measure': measureNumber},
        );
      }
      if (normalNotes == null) {
        throw MusicXmlStructureException(
          '<normal-notes> must contain an integer value',
          parentElement: 'time-modification',
          line: XmlHelper.getLineNumber(normalNotesElement),
          context: {'part': partId, 'measure': measureNumber},
        );
      }

      final normalTypeElement = timeModificationElement.findElements('normal-type').firstOrNull;
      final normalType = normalTypeElement?.innerText.trim();

      final normalDotElements = timeModificationElement.findElements('normal-dot');
      final int? normalDotCount = normalDotElements.isNotEmpty ? normalDotElements.length : null;

      try {
        timeModification = TimeModification.validated(
          actualNotes: actualNotes,
          normalNotes: normalNotes,
          normalType: normalType,
          normalDotCount: normalDotCount,
          line: tmLine,
          context: {'part': partId, 'measure': measureNumber, 'noteLine': line},
        );
      } on MusicXmlValidationException catch (e) {
        // Add more context or re-throw if needed, or log to warningSystem
        warningSystem.addWarning(
          'Invalid time-modification: ${e.message}',
          category: 'time_modification_validation',
          rule: e.rule,
          line: tmLine,
          context: {
            'part': partId,
            'measure': measureNumber,
            'noteLine': line,
            ...?e.context
          },
        );
        // Depending on severity, you might choose to nullify timeModification or rethrow
      }
    }

    // Parse notations for slurs and articulations
    List<Slur>? slursList;
    List<Articulation>? articulationsList; // Declare articulationsList here
    final notationsElement = element.findElements('notations').firstOrNull;
    if (notationsElement != null) {
      List<Slur> foundSlurs = []; // Keep this local to slur processing within the loop if multiple <slurs> tags were possible
                                 // but since we process all children of <notations> once, it's fine.
      // For articulations, we need to find the <articulations> container first
      // List<Articulation> foundArticulations = []; // This would be inside the 'if articulationsContainerElement != null'

      for (final notationChild in notationsElement.childElements) {
        if (notationChild.name.local == 'slur') {
          final String? typeAttr = notationChild.getAttribute('type');
          if (typeAttr == null) {
            throw MusicXmlStructureException(
              '<slur> element missing required "type" attribute',
              parentElement: 'notations',
              line: XmlHelper.getLineNumber(notationChild),
              context: {'part': partId, 'measure': measureNumber, 'noteLine': line},
            );
          }

          final String? numberStr = notationChild.getAttribute('number');
          final int numberAttr = (numberStr != null && numberStr.isNotEmpty ? int.tryParse(numberStr) : null) ?? 1;

          final String? placementAttr = notationChild.getAttribute('placement');

          foundSlurs.add(Slur(type: typeAttr, number: numberAttr, placement: placementAttr));
        } else if (notationChild.name.local == 'articulations') {
          // Found an <articulations> container element
          List<Articulation> currentGroupArticulations = [];
          for (final specificArtElement in notationChild.childElements) {
            final String artType = specificArtElement.name.local;
            // MusicXML schema lists specific elements like <accent>, <staccato> etc.
            // We'll use the element name as the articulation type.
            if (artType.isNotEmpty) {
              final String? placementAttr = specificArtElement.getAttribute('placement');
              currentGroupArticulations.add(Articulation(type: artType, placement: placementAttr));
            }
          }
          if (currentGroupArticulations.isNotEmpty) {
            // If multiple <articulations> tags were allowed, we'd use addAll.
            // Assuming only one <articulations> container per <notations>.
            articulationsList = currentGroupArticulations;
          }
        }
        // TODO: Parse other notations like <tied> here
      }
      if (foundSlurs.isNotEmpty) {
        slursList = foundSlurs;
      }
      // articulationsList is already populated if an <articulations> group was found and had items
    }

    // Create and return the note
    return Note(
      pitch: pitch,
      duration: duration,
      isRest: isRest,
      type: type,
      voice: voiceNum,
      dots: dotsCount,
      timeModification: timeModification,
      slurs: slursList,
      articulations: articulationsList,
    );
  }

  /// Parses a pitch element into a [Pitch] object.
  Pitch _parsePitch(XmlElement element, String partId, String measureNumber) {
    final line = XmlHelper.getLineNumber(element);

    // Parse step (required)
    final stepElement = element.findElements('step').firstOrNull;
    final step = stepElement?.innerText.trim();

    // Validate step
    if (step == null || !ValidationUtils.validPitchSteps.contains(step)) {
      throw MusicXmlValidationException(
        'Invalid pitch step: $step',
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    // Parse octave (required)
    final octaveElement = element.findElements('octave').firstOrNull;
    final octaveText = octaveElement?.innerText.trim();
    final octave = octaveText != null ? int.tryParse(octaveText) : null;

    // Validate octave
    if (octave == null ||
        octave < ValidationUtils.minOctave ||
        octave > ValidationUtils.maxOctave) {
      throw MusicXmlValidationException(
        'Invalid octave: $octaveText',
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    // Parse alter (optional)
    final alterElement = element.findElements('alter').firstOrNull;
    final alterText = alterElement?.innerText.trim();
    final alter = alterText != null ? int.tryParse(alterText) : null;

    // Validate alter if present
    if (alterText != null && (alter == null || alter < -2 || alter > 2)) {
      throw MusicXmlValidationException(
        'Invalid alter value: $alterText',
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
    }

    return Pitch(
      step: step,
      octave: octave,
      alter: alter,
    );
  }
}
