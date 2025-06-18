# Music Theory Guide for MusicXML Parsing

This document provides essential music theory knowledge for accurate MusicXML parsing and implementation.

## Pitch and Notes

### Basic Concepts
- **Pitch Classes**: C, D, E, F, G, A, B (7 natural notes)
- **Accidentals**: Sharp (#, +1 semitone), Flat (♭, -1 semitone), Natural (♮, cancels accidental)
- **Octave Numbers**: Scientific pitch notation (C4 = Middle C, A4 = 440Hz)
- **Enharmonic Equivalents**: Same pitch, different names (F# = G♭)

### Pitch Validation Rules
- Pitch step must be A-G
- Octave typically ranges from 0-9
- Alter (accidental) typically ranges from -2 to +2

## Time and Rhythm

### Note Values
- **Whole Note**: 4 beats
- **Half Note**: 2 beats
- **Quarter Note**: 1 beat
- **Eighth Note**: 0.5 beats
- **Sixteenth Note**: 0.25 beats

### Dotted Notes
- **Single Dot**: Adds half the note's value to itself
  - Dotted quarter = 1 + 0.5 = 1.5 beats
  - Dotted half = 2 + 1 = 3 beats
- **Double Dots**: Second dot adds half of first dot's value
  - Double-dotted quarter = 1 + 0.5 + 0.25 = 1.75 beats

### Time Signatures
- **4/4**: 4 quarter notes per measure (most common)
- **3/4**: 3 quarter notes per measure (waltz time)
- **2/2**: 2 half notes per measure (cut time)
- **6/8**: 6 eighth notes per measure (compound time)

### MusicXML Divisions
- MusicXML uses "divisions" to represent the smallest time unit
- Typically quarter note = 480 divisions
- All durations are expressed as multiples of this division value

## Key Signatures

### Major Keys
- Follow pattern of whole and half steps: W-W-H-W-W-W-H
- Example: C major = C-D-E-F-G-A-B

### Minor Keys
- **Natural Minor**: W-H-W-W-H-W-W
- **Harmonic Minor**: W-H-W-W-H-W+H-H
- **Melodic Minor**: W-H-W-W-W-W-H (ascending), natural minor (descending)

### Circle of Fifths
- **Sharp Keys**: C-G-D-A-E-B-F#-C#
- **Flat Keys**: C-F-B♭-E♭-A♭-D♭-G♭-C♭

### Key Signature Order
- **Sharps**: F#, C#, G#, D#, A#, E#, B#
- **Flats**: B♭, E♭, A♭, D♭, G♭, C♭, F♭

### Fifths Value in MusicXML
- Range: -7 to +7
- Positive values = sharps
- Negative values = flats
- 0 = C major/A minor (no accidentals)

## MIDI Conversion

### MIDI Note Numbers
- **C4 = 60** (Middle C)
- **A4 = 69** (440Hz reference)
- Range: 0-127

### Conversion Formula
```
MIDI = (octave + 1) × 12 + pitch_class_number + alteration
```

### Pitch Class Numbers
- C=0, C#=1, D=2, D#=3, E=4, F=5, F#=6, G=7, G#=8, A=9, A#=10, B=11

### Enharmonic Handling
- E# = F, B# = C (next octave)
- Cb = B (previous octave), Fb = E

## MusicXML Specific Concepts

### Score Structure
- **Parts**: Individual instruments or voices in a score
- **Measures**: Vertical divisions of music based on time signature
- **Voices**: Multiple melodic lines within a single part

### Musical Connections
- **Ties**: Connect notes of same pitch across measure boundaries
- **Slurs**: Connect notes of different pitches for phrasing
- **Tuplets**: Irregular groupings (triplets, quintuplets, etc.)

### Metadata Elements
- **Work**: Title, composer, opus information
- **Identification**: Creator, software, encoding date
- **Part-list**: Instrument definitions and ordering

## Common Validation Rules

### Duration Validation
- Duration must be positive
- Should align with time signature constraints
- Measure durations should match time signature

### Measure Validation
- Measure numbers should be sequential
- Total duration should match time signature
- Backup and forward elements must be valid

### Time Signature Validation
- Denominators are typically powers of 2 (1, 2, 4, 8, 16, 32)
- Numerator should be positive
- Changes should occur at measure boundaries

## Implementation Guidelines

### Pitch Processing
```dart
// Validate pitch step
if (!['C', 'D', 'E', 'F', 'G', 'A', 'B'].contains(step)) {
  throw InvalidMusicXmlException('Invalid pitch step: $step');
}

// Validate octave range
if (octave < 0 || octave > 9) {
  throw InvalidMusicXmlException('Octave out of range: $octave');
}
```

### Duration Calculations
```dart
// Handle dotted notes
double calculateDottedDuration(double baseDuration, int dots) {
  double totalDuration = baseDuration;
  double dotValue = baseDuration;
  
  for (int i = 0; i < dots; i++) {
    dotValue /= 2;
    totalDuration += dotValue;
  }
  
  return totalDuration;
}
```

### Key Signature Processing
```dart
// Convert fifths to accidental list
List<String> getKeySignatureAccidentals(int fifths) {
  if (fifths > 0) {
    // Sharps: F#, C#, G#, D#, A#, E#, B#
    const sharps = ['F', 'C', 'G', 'D', 'A', 'E', 'B'];
    return sharps.take(fifths).toList();
  } else if (fifths < 0) {
    // Flats: Bb, Eb, Ab, Db, Gb, Cb, Fb
    const flats = ['B', 'E', 'A', 'D', 'G', 'C', 'F'];
    return flats.take(-fifths).toList();
  }
  return []; // C major/A minor
}
```

### MIDI Conversion
```dart
int toMidiNote(String step, int octave, int? alter) {
  const noteMap = {
    'C': 0, 'D': 2, 'E': 4, 'F': 5, 
    'G': 7, 'A': 9, 'B': 11
  };
  
  int midiNote = 12 * (octave + 1) + noteMap[step]! + (alter ?? 0);
  
  // Clamp to valid MIDI range
  return midiNote.clamp(0, 127);
}
```

## References

- [MusicXML 4.0 Specification](https://www.w3.org/2021/06/musicxml40/)
- [MIDI 1.0 Specification](https://www.midi.org/specifications)
- [Music Theory Fundamentals](https://en.wikipedia.org/wiki/Music_theory)

## Last Updated
June 18, 2025
