// ignore_for_file: avoid_print
import 'package:musicxml_parser/musicxml_parser.dart';

void main() {
  // Sample MusicXML string for testing
  const String sampleMusicXml = '''
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 3.1 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
<score-partwise version="3.1">
  <work>
    <work-title>Simple Example</work-title>
  </work>
  <identification>
    <creator type="composer">Composer</creator>
  </identification>
  <part-list>
    <score-part id="P1">
      <part-name>Music</part-name>
    </score-part>
  </part-list>
  <part id="P1">
    <measure number="1">
      <attributes>
        <divisions>1</divisions>
        <key>
          <fifths>0</fifths>
        </key>
        <time>
          <beats>4</beats>
          <beat-type>4</beat-type>
        </time>
        <clef>
          <sign>G</sign>
          <line>2</line>
        </clef>
      </attributes>
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>1</duration>
        <type>quarter</type>
      </note>
      <note>
        <pitch>
          <step>D</step>
          <octave>4</octave>
        </pitch>
        <duration>1</duration>
        <type>quarter</type>
      </note>
      <note>
        <pitch>
          <step>E</step>
          <octave>4</octave>
        </pitch>
        <duration>1</duration>
        <type>quarter</type>
      </note>
      <note>
        <pitch>
          <step>F</step>
          <octave>4</octave>
        </pitch>
        <duration>1</duration>
        <type>quarter</type>
      </note>
    </measure>
  </part>
</score-partwise>
''';

  try {
    final parser = MusicXmlParser();
    final score = parser.parse(sampleMusicXml);

    // Print score information
    print('Title: ${score.title ?? "Unknown"}');
    print('Composer: ${score.composer ?? "Unknown"}');
    print('Parts: ${score.parts.length}');

    // Process each part
    for (final part in score.parts) {
      print('\nPart: ${part.name ?? part.id}');
      print('Measures: ${part.measures.length}');

      // Process each measure
      for (final measure in part.measures) {
        print('\nMeasure ${measure.number}:');
        if (measure.timeSignature != null) {
          print(
              'Time: ${measure.timeSignature!.beats}/${measure.timeSignature!.beatType}');
        }
        if (measure.keySignature != null) {
          print(
              'Key: ${measure.keySignature!.fifths} ${measure.keySignature!.mode ?? ""}');
        }
        print('Notes: ${measure.notes.length}');

        // Process each note
        for (final note in measure.notes) {
          if (note.isRest) {
            print('Rest (${note.duration?.value})');
          } else {
            final pitch = note.pitch!;
            final alterText =
                pitch.alter != null ? (pitch.alter! > 0 ? '#' : 'b') : '';
            print(
                'Note: ${pitch.step}$alterText${pitch.octave} (${note.duration?.value})');
          }
        }
      }
    }

    // Convert a note to MIDI
    if (score.parts.isNotEmpty &&
        score.parts[0].measures.isNotEmpty &&
        score.parts[0].measures[0].notes.isNotEmpty) {
      final note = score.parts[0].measures[0].notes[0];
      if (!note.isRest) {
        final pitch = note.pitch!;
        final midiNote = toMidiNote(pitch.step, pitch.octave, pitch.alter);
        print('\nFirst note MIDI value: $midiNote');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
