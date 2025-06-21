import 'package:musicxml_parser/src/exceptions/musicxml_structure_exception.dart';
import 'package:musicxml_parser/src/exceptions/musicxml_validation_exception.dart';
import 'package:musicxml_parser/src/models/articulation.dart'; // Import for Articulation
import 'package:musicxml_parser/src/models/duration.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/pitch.dart';
import 'package:musicxml_parser/src/models/slur.dart'; // Import for Slur
import 'package:musicxml_parser/src/models/tie.dart'; // Import for Tie
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
    int? effectiveParentDivisions = parentDivisions;

    if (durationElement != null) {
      final durationValue = XmlHelper.getElementTextAsInt(durationElement);

      // Only validate/use parentDivisions if a duration value is present
      if (durationValue != null && durationValue >= 0) {
        if (effectiveParentDivisions == null || effectiveParentDivisions <= 0) {
          warningSystem.addWarning(
            'No valid divisions specified for note with duration. Using default divisions value 1.',
            category: 'note_divisions',
            context: {
              'part': partId,
              'measure': measureNumber,
              'line': line,
              'original_divisions': parentDivisions
            },
          );
          effectiveParentDivisions = 1;
        }
        duration = Duration(
          value: durationValue,
          divisions: effectiveParentDivisions,
        );
      } else {
        warningSystem.addWarning(
          'Invalid duration value: $durationValue for note.',
          category: 'note_duration',
          context: {
            'part': partId,
            'measure': measureNumber,
            'line': line,
          },
        );
        // Consider if returning null is the best strategy, or if a Note
        // without a valid duration (but other properties) is permissible.
        // For now, if duration is present but invalid, skip the note.
        return null;
      }
    } else {
      // Duration element is not present. This is a valid state for some MusicXML notes (e.g. grace notes, cue notes)
      // or if duration is implied. The Note model allows null duration.
      // The existing warning for "Note without duration" is kept as it might be informative.
      warningSystem.addWarning(
        'Note without duration element present.', // Clarified message
        category: WarningCategories.duration,
        context: {
          'part': partId,
          'measure': measureNumber,
          'line': line,
        },
      );
      // `duration` remains null, which is acceptable for the Note object.
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
    final timeModification = _parseTimeModification(
        element.findElements('time-modification').firstOrNull,
        partId,
        measureNumber,
        line);

    // Parse notations
    final notations = _parseNotations(
        element.findElements('notations').firstOrNull,
        partId,
        measureNumber,
        line);

    // Check for <chord/> element
    final bool isChord = element.findElements('chord').isNotEmpty;

    // Use NoteBuilder to construct the note
    final noteBuilder = NoteBuilder(line: line, context: {
      'part': partId,
      'measure': measureNumber,
    });

    noteBuilder
        .setIsRest(isRest)
        .setPitch(pitch) // Will be null if isRest is true
        .setDuration(duration)
        .setType(type)
        .setVoice(voiceNum)
        .setDots(dotsCount)
        .setTimeModification(timeModification)
        .setSlurs(notations.slurs)
        .setArticulations(notations.articulations)
        .setTies(notations.ties)
        .setIsChordElementPresent(isChord);

    try {
      return noteBuilder.build();
    } on MusicXmlValidationException catch (e) {
      // It's possible the builder.build() (which calls Note.validated)
      // could throw a validation exception if some combination is invalid
      // that wasn't caught by individual component parsing.
      warningSystem.addWarning(
        'Invalid note constructed: ${e.message}',
        category: 'note_validation',
        rule: e.rule,
        line: line,
        context: {
          'part': partId,
          'measure': measureNumber,
          ...?e.context,
        },
      );
      return null; // Or rethrow, depending on desired strictness
    }
  }

  /// Parses a <time-modification> element.
  TimeModification? _parseTimeModification(
    XmlElement? timeModificationElement,
    String partId,
    String measureNumber,
    int noteLine,
  ) {
    if (timeModificationElement == null) return null;

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
      return TimeModification.validated(
        actualNotes: actualNotes,
        normalNotes: normalNotes,
        normalType: normalType,
        normalDotCount: normalDotCount,
        line: tmLine,
        context: {'part': partId, 'measure': measureNumber, 'noteLine': noteLine},
      );
    } on MusicXmlValidationException catch (e) {
      warningSystem.addWarning(
        'Invalid time-modification: ${e.message}',
        category: 'time_modification_validation',
        rule: e.rule,
        line: tmLine,
        context: {
          'part': partId,
          'measure': measureNumber,
          'noteLine': noteLine,
          ...?e.context
        },
      );
      return null;
    }
  }

  /// Parses a <notations> element.
  _NotationsData _parseNotations(
    XmlElement? notationsElement,
    String partId,
    String measureNumber,
    int noteLine,
  ) {
    if (notationsElement == null) return _NotationsData();

    List<Slur> slurs = [];
    List<Articulation> articulations = [];
    List<Tie> ties = [];

    for (final notationChild in notationsElement.childElements) {
      switch (notationChild.name.local) {
        case 'slur':
          final String? typeAttr = notationChild.getAttribute('type');
          if (typeAttr == null) {
            throw MusicXmlStructureException(
              '<slur> element missing required "type" attribute',
              parentElement: 'notations',
              line: XmlHelper.getLineNumber(notationChild),
              context: {'part': partId, 'measure': measureNumber, 'noteLine': noteLine},
            );
          }
          final String? numberStr = notationChild.getAttribute('number');
          final int numberAttr = (numberStr != null && numberStr.isNotEmpty ? int.tryParse(numberStr) : null) ?? 1;
          final String? placementAttr = notationChild.getAttribute('placement');
          slurs.add(Slur(type: typeAttr, number: numberAttr, placement: placementAttr));
          break;
        case 'articulations':
          for (final specificArtElement in notationChild.childElements) {
            final String artType = specificArtElement.name.local;
            if (artType.isNotEmpty) {
              final String? placementAttr = specificArtElement.getAttribute('placement');
              articulations.add(Articulation(type: artType, placement: placementAttr));
            }
          }
          break;
        case 'tied':
          final String? typeAttr = notationChild.getAttribute('type');
          if (typeAttr == null || (typeAttr != 'start' && typeAttr != 'stop' && typeAttr != 'continue')) {
            warningSystem.addWarning(
              '<tied> element has invalid or missing "type" attribute. Found: "$typeAttr". Skipping tie.',
              category: WarningCategories.structure,
              line: XmlHelper.getLineNumber(notationChild),
              context: {'part': partId, 'measure': measureNumber, 'noteLine': noteLine},
            );
          } else {
            final String? placementAttr = notationChild.getAttribute('placement');
            ties.add(Tie(type: typeAttr, placement: placementAttr));
          }
          break;
      }
    }
    return _NotationsData(
        slurs: slurs.isNotEmpty ? slurs : null,
        articulations: articulations.isNotEmpty ? articulations : null,
        ties: ties.isNotEmpty ? ties : null);
  }

  /// Parses a pitch element into a [Pitch] object using the Pitch.fromXmlElement factory.
  Pitch _parsePitch(XmlElement element, String partId, String measureNumber) {
    try {
      return Pitch.fromXmlElement(element, partId, measureNumber);
    } on MusicXmlStructureException catch (e) {
      // Re-throw with more specific context if needed, or let it propagate
      // For now, just rethrowing as the factory method should provide good context.
      rethrow;
    } on MusicXmlValidationException catch (e) {
      // Similarly, re-throw or handle/log
      rethrow;
    }
    // Add a general catch if other unexpected errors could occur from Pitch.fromXmlElement
    // though it's designed to throw specific MusicXML exceptions.
  }
}

/// Helper class to store parsed data from the <notations> element.
class _NotationsData {
  final List<Slur>? slurs;
  final List<Articulation>? articulations;
  final List<Tie>? ties;

  _NotationsData({this.slurs, this.articulations, this.ties});
}
