/// Utility functions for working with MusicXML data.
library;

/// Converts a pitch step, octave, and alter to a MIDI note number.
///
/// [step] must be one of 'C', 'D', 'E', 'F', 'G', 'A', or 'B'.
/// [octave] is the octave number.
/// [alter] is the alteration (-1 for flat, 1 for sharp, etc.). Defaults to 0.
///
/// Example:
/// ```dart
/// final midiNote = toMidiNote('C', 4); // Middle C = 60
/// final fSharp = toMidiNote('F', 4, 1); // F# = 66
/// ```
int toMidiNote(String step, int octave, [int? alter]) {
  const noteMap = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11};

  if (!noteMap.containsKey(step)) {
    throw ArgumentError(
        'Invalid step: $step. Must be one of C, D, E, F, G, A, B');
  }

  return 12 * (octave + 1) + noteMap[step]! + (alter ?? 0);
}

/// Converts a MIDI note number to a pitch (step, octave, alter).
///
/// Returns a map with keys 'step', 'octave', and 'alter'.
/// Uses sharps by default. Set [useFlats] to true to use flats.
///
/// Example:
/// ```dart
/// final pitch = fromMidiNote(60); // {'step': 'C', 'octave': 4, 'alter': 0}
/// final pitchFlat = fromMidiNote(61, useFlats: true); // {'step': 'D', 'octave': 4, 'alter': -1}
/// ```
Map<String, dynamic> fromMidiNote(int midiNote, {bool useFlats = false}) {
  final octave = (midiNote ~/ 12) - 1;
  final noteValue = midiNote % 12;

  const sharpSteps = [
    'C',
    'C',
    'D',
    'D',
    'E',
    'F',
    'F',
    'G',
    'G',
    'A',
    'A',
    'B'
  ];
  const flatSteps = [
    'C',
    'D',
    'D',
    'E',
    'E',
    'F',
    'G',
    'G',
    'A',
    'A',
    'B',
    'B'
  ];
  const sharpAlters = [0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0];
  const flatAlters = [0, -1, 0, -1, 0, 0, -1, 0, -1, 0, -1, 0];

  final steps = useFlats ? flatSteps : sharpSteps;
  final alters = useFlats ? flatAlters : sharpAlters;

  return {
    'step': steps[noteValue],
    'octave': octave,
    'alter': alters[noteValue],
  };
}

/// Calculates the real-time duration in seconds for a note.
///
/// [duration] is the note duration value.
/// [divisions] is the number of divisions per quarter note.
/// [tempo] is the tempo in beats per minute. Defaults to 60.
///
/// Example:
/// ```dart
/// final seconds = calculateDurationInSeconds(480, 480, tempo: 120); // 0.5 seconds
/// ```
double calculateDurationInSeconds(int duration, int divisions,
    {double tempo = 60.0}) {
  // Calculate the note duration in quarter notes
  final quarterNotes = duration / divisions;

  // Calculate the duration in seconds
  // (60 seconds / tempo) * quarterNotes
  return (60.0 / tempo) * quarterNotes;
}
