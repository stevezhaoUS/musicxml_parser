#!/usr/bin/env dart

import 'dart:io';
import 'package:musicxml_parser/musicxml_parser.dart';
import 'package:dart_console/dart_console.dart';

// Create a console instance for single-key input
final console = Console();

void main(List<String> args) async {
  print('MusicXML Parser Interactive Tester');
  print('==================================');

  String? filePath;

  if (args.isNotEmpty) {
    filePath = args.first;
  } else {
    print('Enter the path to a MusicXML file:');
    filePath = stdin.readLineSync();
  }

  if (filePath == null || filePath.isEmpty) {
    print('No file path provided. Exiting.');
    return;
  }

  final file = File(filePath);
  if (!file.existsSync()) {
    print('File not found: $filePath');
    return;
  }

  try {
    print('\nParsing file: $filePath');

    final parser = MusicXmlParser();
    final score = parser.parseFileSync(filePath);

    printScoreSummary(score);

    while (true) {
      print('\nWhat would you like to inspect?');
      print('1. Parts');
      print('2. Measures');
      print('3. Notes');
      print('4. Time Signatures');
      print('5. Key Signatures');
      print('6. Clefs');
      print('7. Beams');
      print('8. Parser Warnings');
      print('9. MIDI Conversion');
      print('10. Export Summary');
      print('0. Exit');
      print(
          '\nPress a key to select an option. In submenus, press ESC to go back.');

      final choice = readSingleKey();

      if (choice == 'ESC') {
        // At the main menu, ESC is equivalent to Exit
        print('Exiting.');
        return;
      }

      switch (choice) {
        case '1':
          inspectParts(score);
          break;
        case '2':
          inspectMeasures(score);
          break;
        case '3':
          inspectNotes(score);
          break;
        case '4':
          inspectTimeSignatures(score);
          break;
        case '5':
          inspectKeySignatures(score);
          break;
        case '6':
          inspectClefs(score);
          break;
        case '7':
          inspectBeams(score);
          break;
        case '8':
          inspectParserWarnings(parser);
          break;
        case '9':
          testMidiConversion(score);
          break;
        case '10':
          exportSummary(score, filePath);
          break;
        case '0':
          print('Exiting.');
          return;
        default:
          print('Invalid choice. Please try again.');
      }
    }
  } catch (e, stackTrace) {
    print('Error parsing file:');
    print(e);
    print('\nStack trace:');
    print(stackTrace);
  }
}

/// Reads a single key from the console without requiring Enter
String readSingleKey() {
  final key = console.readKey();

  // Check for special control characters
  if (key.controlChar == ControlCharacter.enter) {
    return '';
  } else if (key.controlChar == ControlCharacter.escape) {
    print('ESC');
    return 'ESC';
  }

  // Print the key so user can see what was pressed
  print(key.char);
  return key.char;
}

/// Reads a number using single key input or falls back to stdin for complex input
String readNumberInput() {
  final buffer = StringBuffer();
  bool done = false;

  while (!done) {
    final key = console.readKey();

    switch (key.controlChar) {
      case ControlCharacter.enter:
        done = true;
        print(''); // New line after enter
        break;
      case ControlCharacter.escape:
        // Return ESC as a special marker for navigation
        print('ESC'); // Show that ESC was pressed
        return 'ESC';
      case ControlCharacter.backspace:
        if (buffer.length > 0) {
          // Remove last character from buffer
          final currentText = buffer.toString();
          buffer.clear();
          buffer.write(currentText.substring(0, currentText.length - 1));

          // Update display (backspace, space, backspace)
          stdout.write('\b \b');
        }
        break;
      default:
        // Only accept digits
        if (key.char.length == 1 && key.char.contains(RegExp(r'[0-9]'))) {
          buffer.write(key.char);
          stdout.write(key.char); // Echo the character
        }
    }
  }

  return buffer.toString();
}

void printScoreSummary(Score score) {
  print('\nScore Summary:');
  print('Title: ${score.title ?? 'Unknown'}');
  print('Composer: ${score.composer ?? 'Unknown'}');
  print('Parts: ${score.parts.length}');

  int totalMeasures = 0;
  int totalNotes = 0;

  for (final part in score.parts) {
    totalMeasures += part.measures.length;
    for (final measure in part.measures) {
      totalNotes += measure.notes.length;
    }
  }

  print('Total measures: $totalMeasures');
  print('Total notes: $totalNotes');
}

void inspectParts(Score score) {
  print('\nParts:');
  for (int i = 0; i < score.parts.length; i++) {
    final part = score.parts[i];
    print('${i + 1}. ${part.name ?? 'Part ${i + 1}'} (ID: ${part.id})');
  }

  print(
      '\nEnter part number to inspect (or press ESC to go back, default: 1):');
  final input = readNumberInput();
  int partIndex;

  if (input.isEmpty) {
    // Default to part 1 if no input provided
    partIndex = 1;
    print('Using default: 1');
  } else if (input == 'ESC') {
    return; // Go back to main menu
  } else {
    partIndex = int.tryParse(input) ?? 0;
  }

  if (partIndex < 1 || partIndex > score.parts.length) {
    print('Invalid part number. Going back...');
    return;
  }

  final part = score.parts[partIndex - 1];
  print('\nPart Details:');
  print('Name: ${part.name ?? 'Unknown'}');
  print('ID: ${part.id}');
  print('Measures: ${part.measures.length}');

  // Count notes
  int totalNotes = 0;
  for (final measure in part.measures) {
    totalNotes += measure.notes.length;
  }
  print('Total notes: $totalNotes');

  // Wait for a keypress to continue
  print('\nPress any key to continue or ESC to go back...');
  final choice = readSingleKey();
  if (choice == 'ESC') {
    return; // Go back to main menu
  }
}

void inspectMeasures(Score score) {
  print('\nEnter part number (or press ESC to go back, default: 1):');
  final partInput = readNumberInput();
  int partIndex;

  if (partInput.isEmpty) {
    // Default to part 1 if no input provided
    partIndex = 1;
    print('Using default: 1');
  } else if (partInput == 'ESC') {
    return; // Go back to main menu
  } else {
    partIndex = int.tryParse(partInput) ?? 0;
  }

  if (partIndex < 1 || partIndex > score.parts.length) {
    print('Invalid part number. Going back...');
    return;
  }

  final part = score.parts[partIndex - 1];

  // Measure selection loop
  while (true) {
    print('\nMeasures in ${part.name ?? 'Part $partIndex'}:');

    for (int i = 0; i < part.measures.length; i += 10) {
      final end =
          (i + 10 < part.measures.length) ? i + 10 : part.measures.length;
      final range = List.generate(end - i, (index) => i + index + 1).join(', ');
      print('$range');
    }

    print(
        '\nEnter measure number to inspect (or press ESC to go back, default: 1):');
    final measureInput = readNumberInput();
    int measureIndex;

    if (measureInput.isEmpty) {
      // Default to measure 1 if no input provided
      measureIndex = 1;
      print('Using default: 1');
    } else if (measureInput == 'ESC') {
      print('Going back to part selection...');
      return; // Exit back to main menu
    } else {
      measureIndex = int.tryParse(measureInput) ?? 0;
    }

    if (measureIndex < 1 || measureIndex > part.measures.length) {
      print('Invalid measure number. Please try again.');
      continue; // Stay in measure selection
    }

    final measure = part.measures[measureIndex - 1];
    print('\nMeasure ${measure.number} Details:');
    print('Number of notes: ${measure.notes.length}');
    print('Number of beams: ${measure.beams.length}');

    if (measure.timeSignature != null) {
      final ts = measure.timeSignature!;
      print('Time Signature: ${ts.beats}/${ts.beatType}');
    }

    if (measure.keySignature != null) {
      final ks = measure.keySignature!;
      final fifthsText = ks.fifths > 0
          ? '${ks.fifths} sharp(s)'
          : ks.fifths < 0
              ? '${-ks.fifths} flat(s)'
              : 'No accidentals';
      print('Key Signature: $fifthsText (${ks.mode ?? 'major'})');
    }

    // Ask user if they want to inspect beams
    if (measure.beams.isNotEmpty) {
      print('\nDo you want to inspect beams in this measure?');
      print('1. Yes');
      print('2. No');

      final beamChoice = readSingleKey();
      if (beamChoice == '1') {
        inspectBeamsInMeasure(measure);
      }
    }

    // Ask user if they want to continue
    print('\nPress any key to continue or ESC to go back...');

    final choice = readSingleKey();
    if (choice == 'ESC') {
      return; // Exit the measure loop, return to main menu
    }
    // Any other key continues in the loop
  }
}

void inspectNotes(Score score) {
  print('\nEnter part number (or press ESC to go back, default: 1):');
  final partInput = readNumberInput();
  int partIndex;

  if (partInput.isEmpty) {
    // Default to part 1 if no input provided
    partIndex = 1;
    print('Using default: 1');
  } else if (partInput == 'ESC') {
    return; // Go back to main menu
  } else {
    partIndex = int.tryParse(partInput) ?? 0;
  }

  if (partIndex < 1 || partIndex > score.parts.length) {
    print('Invalid part number. Going back...');
    return;
  }

  final part = score.parts[partIndex - 1];

  // Measure selection loop
  while (true) {
    print('\nEnter measure number (or press ESC to go back, default: 1):');
    final measureInput = readNumberInput();
    int measureIndex;

    if (measureInput.isEmpty) {
      // Default to measure 1 if no input provided
      measureIndex = 1;
      print('Using default: 1');
    } else if (measureInput == 'ESC') {
      return; // Go back to main menu
    } else {
      measureIndex = int.tryParse(measureInput) ?? 0;
    }

    if (measureIndex < 1 || measureIndex > part.measures.length) {
      print('Invalid measure number. Please try again.');
      continue; // Stay in measure selection
    }

    final measure = part.measures[measureIndex - 1];

    if (measure.notes.isEmpty) {
      print('No notes in this measure.');
      continue; // Go back to measure selection
    }

    // Note selection loop
    while (true) {
      print('\nNotes in Measure ${measure.number}:');
      for (int i = 0; i < measure.notes.length; i++) {
        final note = measure.notes[i];
        final noteInfo = note.isRest
            ? 'Rest'
            : '${note.pitch?.step}${note.pitch?.alter != null ? (note.pitch!.alter! > 0 ? '#' : '♭') : ''}${note.pitch?.octave}';

        final duration = note.duration?.value.toString();

        print('${i + 1}. $noteInfo ($duration divisions)');
      }

      print(
          '\nEnter note number to inspect (or press ESC to go back, default: 1):');
      final noteInput = readNumberInput();
      int noteIndex;

      if (noteInput.isEmpty) {
        // Default to note 1 if no input provided
        noteIndex = 1;
        print('Using default: 1');
      } else if (noteInput == 'ESC') {
        break; // Exit the note loop, return to measure selection
      } else {
        noteIndex = int.tryParse(noteInput) ?? 0;
      }

      if (noteIndex < 1 || noteIndex > measure.notes.length) {
        print('Invalid note number. Please try again.');
        continue; // Stay in note selection
      }

      final note = measure.notes[noteIndex - 1];
      print('\nNote Details:');
      if (note.isRest) {
        print('Type: Rest');
      } else {
        print(
            'Pitch: ${note.pitch?.step}${note.pitch?.alter != null ? (note.pitch!.alter! > 0 ? '#' : '♭') : ''}${note.pitch?.octave}');
        if (note.pitch?.alter != null) {
          print('Alteration: ${note.pitch!.alter}');
        }

        if (note.pitch != null) {
          // Calculate MIDI note number
          final step = note.pitch!.step;
          final octave = note.pitch!.octave;
          final alter = note.pitch!.alter ?? 0;

          // Map of step to semitone offset within octave
          final stepToSemitone = {
            'C': 0,
            'D': 2,
            'E': 4,
            'F': 5,
            'G': 7,
            'A': 9,
            'B': 11
          };

          final midiNote = ((octave + 1) * 12) + stepToSemitone[step]! + alter;
          print('MIDI Note Number: $midiNote');
        }
      }

      print('Duration: ${note.duration?.value} divisions');
      if (note.type != null) {
        print('Note Type: ${note.type}');
      }

      print('Voice: ${note.voice ?? 'Not specified'}');

      // Ask user if they want to continue
      print('\nPress any key to continue or ESC to go back...');

      final choice = readSingleKey();
      if (choice == 'ESC') {
        break; // Exit the note loop, return to measure selection
      }
      // Any other key continues in the loop
    }
  }
}

void inspectTimeSignatures(Score score) {
  final allTimeSignatures = <TimeSignature>{};

  for (final part in score.parts) {
    for (final measure in part.measures) {
      if (measure.timeSignature != null) {
        allTimeSignatures.add(measure.timeSignature!);
      }
    }
  }

  if (allTimeSignatures.isEmpty) {
    print('No time signatures found in the score.');
    return;
  }

  print('\nTime Signatures in the score:');
  int i = 1;
  for (final ts in allTimeSignatures) {
    print('${i++}. ${ts.beats}/${ts.beatType}');
  }

  // Wait for a keypress to continue
  print('\nPress any key to continue or ESC to go back...');
  final choice = readSingleKey();
  if (choice == 'ESC') {
    return; // Go back to main menu
  }
}

void inspectKeySignatures(Score score) {
  final allKeySignatures = <KeySignature>{};

  for (final part in score.parts) {
    for (final measure in part.measures) {
      if (measure.keySignature != null) {
        allKeySignatures.add(measure.keySignature!);
      }
    }
  }

  if (allKeySignatures.isEmpty) {
    print('No key signatures found in the score.');
    return;
  }

  print('\nKey Signatures in the score:');
  int i = 1;
  for (final ks in allKeySignatures) {
    final fifthsText = ks.fifths > 0
        ? '${ks.fifths} sharp(s)'
        : ks.fifths < 0
            ? '${-ks.fifths} flat(s)'
            : 'No accidentals';
    print('${i++}. $fifthsText (${ks.mode ?? 'major'})');

    // Show the actual key name
    final keyNames = {
      -7: 'C♭ major / A♭ minor',
      -6: 'G♭ major / E♭ minor',
      -5: 'D♭ major / B♭ minor',
      -4: 'A♭ major / F minor',
      -3: 'E♭ major / C minor',
      -2: 'B♭ major / G minor',
      -1: 'F major / D minor',
      0: 'C major / A minor',
      1: 'G major / E minor',
      2: 'D major / B minor',
      3: 'A major / F♯ minor',
      4: 'E major / C♯ minor',
      5: 'B major / G♯ minor',
      6: 'F♯ major / D♯ minor',
      7: 'C♯ major / A♯ minor',
    };

    final keyName = keyNames[ks.fifths] ?? 'Unknown key';
    print('   Key: $keyName');

    // Show the affected notes
    final List<String> affectedNotes = [];
    if (ks.fifths > 0) {
      // Order of sharps: F, C, G, D, A, E, B
      final sharps = ['F', 'C', 'G', 'D', 'A', 'E', 'B'];
      for (int j = 0; j < ks.fifths; j++) {
        if (j < sharps.length) {
          affectedNotes.add('${sharps[j]}♯');
        }
      }
    } else if (ks.fifths < 0) {
      // Order of flats: B, E, A, D, G, C, F
      final flats = ['B', 'E', 'A', 'D', 'G', 'C', 'F'];
      for (int j = 0; j < -ks.fifths; j++) {
        if (j < flats.length) {
          affectedNotes.add('${flats[j]}♭');
        }
      }
    }

    if (affectedNotes.isNotEmpty) {
      print('   Affected notes: ${affectedNotes.join(', ')}');
    }
  }

  // Wait for a keypress to continue
  print('\nPress any key to continue or ESC to go back...');
  final choice = readSingleKey();
  if (choice == 'ESC') {
    return; // Go back to main menu
  }
}

void inspectClefs(Score score) {
  print('\nClef information is not currently available in the model.');

  // Wait for a keypress to continue
  print('\nPress any key to continue or ESC to go back...');
  final choice = readSingleKey();
  if (choice == 'ESC') {
    return; // Go back to main menu
  }
}

void inspectParserWarnings(MusicXmlParser parser) {
  print('\nWarning information is available through the warningSystem.');
  print('Accessing warnings from the CLI is not currently implemented.');
  print('Check for warnings using parser.warningSystem.getWarnings()');

  // Wait for a keypress to continue
  print('\nPress any key to continue or ESC to go back...');
  final choice = readSingleKey();
  if (choice == 'ESC') {
    return; // Go back to main menu
  }
}

void testMidiConversion(Score score) {
  print('\nEnter part number (or press ESC to go back, default: 1):');
  final partInput = readNumberInput();
  int partIndex;

  if (partInput.isEmpty) {
    // Default to part 1 if no input provided
    partIndex = 1;
    print('Using default: 1');
  } else if (partInput == 'ESC') {
    return; // Go back to main menu
  } else {
    partIndex = int.tryParse(partInput) ?? 0;
  }

  if (partIndex < 1 || partIndex > score.parts.length) {
    print('Invalid part number. Going back...');
    return;
  }

  final part = score.parts[partIndex - 1];

  // Measure selection loop
  while (true) {
    print('\nEnter measure number (or press ESC to go back, default: 1):');
    final measureInput = readNumberInput();
    int measureIndex;

    if (measureInput.isEmpty) {
      // Default to measure 1 if no input provided
      measureIndex = 1;
      print('Using default: 1');
    } else if (measureInput == 'ESC') {
      return; // Go back to main menu
    } else {
      measureIndex = int.tryParse(measureInput) ?? 0;
    }

    if (measureIndex < 1 || measureIndex > part.measures.length) {
      print('Invalid measure number. Please try again.');
      continue; // Stay in measure selection
    }

    final measure = part.measures[measureIndex - 1];

    if (measure.notes.isEmpty) {
      print('No notes in this measure.');
      continue;
    }

    print('\nMIDI Conversion for Measure ${measure.number}:');
    for (int i = 0; i < measure.notes.length; i++) {
      final note = measure.notes[i];
      if (note.isRest) {
        print('${i + 1}. Rest');
        continue;
      }

      if (note.pitch == null) {
        print('${i + 1}. No pitch information');
        continue;
      }

      final pitch = note.pitch!;
      final step = pitch.step;
      final octave = pitch.octave;
      final alter = pitch.alter ?? 0;

      final stepToSemitone = {
        'C': 0,
        'D': 2,
        'E': 4,
        'F': 5,
        'G': 7,
        'A': 9,
        'B': 11
      };

      final midiNote = ((octave + 1) * 12) + stepToSemitone[step]! + alter;

      final noteInfo =
          '$step${alter != 0 ? (alter > 0 ? '#' : '♭') : ''}$octave';
      print('${i + 1}. $noteInfo -> MIDI: $midiNote');

      // Check for special cases
      if (midiNote < 0 || midiNote > 127) {
        print('   WARNING: MIDI note out of valid range (0-127)');
      }

      // Check for enharmonic equivalents
      final noteNames = [
        'C',
        'C#/Db',
        'D',
        'D#/Eb',
        'E',
        'F',
        'F#/Gb',
        'G',
        'G#/Ab',
        'A',
        'A#/Bb',
        'B'
      ];

      final noteName = noteNames[midiNote % 12];
      final midiOctave = (midiNote / 12).floor() - 1;

      if (noteName.contains('/')) {
        print('   Enharmonic equivalent: $noteName$midiOctave');
      }
    }

    // Ask user if they want to continue
    print('\nPress any key to continue or ESC to go back...');

    final choice = readSingleKey();
    if (choice == 'ESC') {
      return; // Exit the measure loop, return to main menu
    }
    // Any other key continues in the loop
  }
}

void exportSummary(Score score, String sourceFilePath) {
  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  final outputFile = File('${sourceFilePath}_summary_$timestamp.txt');

  final buffer = StringBuffer();

  buffer.writeln('MusicXML File Summary');
  buffer.writeln('=====================');
  buffer.writeln('File: $sourceFilePath');
  buffer.writeln('Generated: ${DateTime.now()}');
  buffer.writeln();

  buffer.writeln('Score Information:');
  buffer.writeln('Title: ${score.title ?? 'Unknown'}');
  buffer.writeln('Composer: ${score.composer ?? 'Unknown'}');
  buffer.writeln('Parts: ${score.parts.length}');

  int totalMeasures = 0;
  int totalNotes = 0;

  for (final part in score.parts) {
    totalMeasures += part.measures.length;
    for (final measure in part.measures) {
      totalNotes += measure.notes.length;
    }
  }

  buffer.writeln('Total measures: $totalMeasures');
  buffer.writeln('Total notes: $totalNotes');
  buffer.writeln();

  // Parts summary
  buffer.writeln('Parts:');
  for (int i = 0; i < score.parts.length; i++) {
    final part = score.parts[i];
    buffer
        .writeln('${i + 1}. ${part.name ?? 'Part ${i + 1}'} (ID: ${part.id})');

    int partNotes = 0;
    for (final measure in part.measures) {
      partNotes += measure.notes.length;
    }

    buffer.writeln('   Measures: ${part.measures.length}');
    buffer.writeln('   Notes: $partNotes');
    buffer.writeln();
  }

  // Time signatures
  final allTimeSignatures = <TimeSignature>{};
  for (final part in score.parts) {
    for (final measure in part.measures) {
      if (measure.timeSignature != null) {
        allTimeSignatures.add(measure.timeSignature!);
      }
    }
  }

  if (allTimeSignatures.isNotEmpty) {
    buffer.writeln('Time Signatures:');
    for (final ts in allTimeSignatures) {
      buffer.writeln('- ${ts.beats}/${ts.beatType}');
    }
    buffer.writeln();
  }

  // Key signatures
  final allKeySignatures = <KeySignature>{};
  for (final part in score.parts) {
    for (final measure in part.measures) {
      if (measure.keySignature != null) {
        allKeySignatures.add(measure.keySignature!);
      }
    }
  }

  if (allKeySignatures.isNotEmpty) {
    buffer.writeln('Key Signatures:');
    for (final ks in allKeySignatures) {
      final fifthsText = ks.fifths > 0
          ? '${ks.fifths} sharp(s)'
          : ks.fifths < 0
              ? '${-ks.fifths} flat(s)'
              : 'No accidentals';
      buffer.writeln('- $fifthsText (${ks.mode ?? 'major'})');
    }
    buffer.writeln();
  }

  // Save the file
  outputFile.writeAsStringSync(buffer.toString());
  print('\nSummary exported to: ${outputFile.path}');

  // Wait for a keypress to continue
  print('\nPress any key to continue or ESC to go back...');
  final choice = readSingleKey();
  if (choice == 'ESC') {
    return; // Go back to main menu
  }
}

/// Inspects the beams in a measure.
void inspectBeamsInMeasure(Measure measure) {
  print('\nBeams in Measure ${measure.number}:');

  if (measure.beams.isEmpty) {
    print('No beams in this measure.');
    return;
  }

  // Group beams by beam number for better readability
  final beamsByNumber = <int, List<Beam>>{};
  for (final beam in measure.beams) {
    beamsByNumber.putIfAbsent(beam.number, () => []).add(beam);
  }

  // Display beams by number
  beamsByNumber.forEach((number, beams) {
    print('\nBeam #$number:');
    for (int i = 0; i < beams.length; i++) {
      final beam = beams[i];
      print('${i + 1}. Type: ${beam.type}');
      print('   Notes: ${beam.noteIndices.map((idx) => idx + 1).join(', ')}');

      // Show note information for this beam
      print('   Connected notes:');
      for (final noteIdx in beam.noteIndices) {
        if (noteIdx < measure.notes.length) {
          final note = measure.notes[noteIdx];
          final noteInfo = note.isRest
              ? 'Rest'
              : '${note.pitch?.step}${note.pitch?.alter != null ? (note.pitch!.alter! > 0 ? '#' : '♭') : ''}${note.pitch?.octave}';
          print('     - Note ${noteIdx + 1}: $noteInfo (${note.type})');
        }
      }
    }
  });

  // Wait for user input to continue
  print('\nPress any key to continue...');
  readSingleKey();
}

/// Inspects all beams in the score.
void inspectBeams(Score score) {
  print('\nEnter part number (or press ESC to go back, default: 1):');
  final partInput = readNumberInput();
  int partIndex;

  if (partInput.isEmpty) {
    // Default to part 1 if no input provided
    partIndex = 1;
    print('Using default: 1');
  } else if (partInput == 'ESC') {
    return; // Go back to main menu
  } else {
    partIndex = int.tryParse(partInput) ?? 0;
  }

  if (partIndex < 1 || partIndex > score.parts.length) {
    print('Invalid part number. Going back...');
    return;
  }

  final part = score.parts[partIndex - 1];

  // Find measures with beams
  final measuresWithBeams = <Measure>[];
  for (final measure in part.measures) {
    if (measure.beams.isNotEmpty) {
      measuresWithBeams.add(measure);
    }
  }

  if (measuresWithBeams.isEmpty) {
    print('\nNo beams found in this part.');
    return;
  }

  print('\nMeasures with beams in ${part.name ?? 'Part $partIndex'}:');
  for (int i = 0; i < measuresWithBeams.length; i++) {
    print(
        '${i + 1}. Measure ${measuresWithBeams[i].number} (${measuresWithBeams[i].beams.length} beams)');
  }

  print('\nEnter measure number to inspect (or press ESC to go back):');
  final measureInput = readNumberInput();

  if (measureInput == 'ESC') {
    return; // Go back to main menu
  }

  final measureIndex = int.tryParse(measureInput) ?? 0;
  if (measureIndex < 1 || measureIndex > measuresWithBeams.length) {
    print('Invalid measure number. Going back...');
    return;
  }

  // Inspect the selected measure's beams
  inspectBeamsInMeasure(measuresWithBeams[measureIndex - 1]);
}
