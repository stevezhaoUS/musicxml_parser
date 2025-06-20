# Barline and Repeat Structure Examples

This document provides examples of how to use the barline, repeat, and ending functionality in the MusicXML parser.

## Basic Usage

### Simple Barline

```dart
import 'package:musicxml_parser/musicxml_parser.dart';

// Parse a simple MusicXML with a barline
const musicXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part-list>
    <score-part id="P1">
      <part-name>Piano</part-name>
    </score-part>
  </part-list>
  <part id="P1">
    <measure number="1">
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>480</duration>
      </note>
      <barline location="right">
        <bar-style>regular</bar-style>
      </barline>
    </measure>
  </part>
</score-partwise>
''';

final parser = MusicXmlParser();
final score = parser.parse(musicXml);

// Access the barline
final measure = score.parts.first.measures.first;
final barline = measure.barlines.first;

print('Barline location: ${barline.location}'); // BarlineLocation.right
print('Barline style: ${barline.style}');       // BarlineStyle.regular
```

### Repeat Signs

```dart
// Parse MusicXML with repeat signs
const musicXmlWithRepeats = '''
<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part-list>
    <score-part id="P1">
      <part-name>Piano</part-name>
    </score-part>
  </part-list>
  <part id="P1">
    <measure number="1">
      <barline location="left">
        <bar-style>heavy-light</bar-style>
        <repeat direction="forward"/>
      </barline>
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>480</duration>
      </note>
    </measure>
    <measure number="2">
      <note>
        <pitch>
          <step>D</step>
          <octave>4</octave>
        </pitch>
        <duration>480</duration>
      </note>
      <barline location="right">
        <bar-style>light-heavy</bar-style>
        <repeat direction="backward" times="2"/>
      </barline>
    </measure>
  </part>
</score-partwise>
''';

final score = parser.parse(musicXmlWithRepeats);

// Access start repeat
final startMeasure = score.parts.first.measures.first;
final startBarline = startMeasure.barlines.first;
print('Start repeat: ${startBarline.repeat?.direction}'); // RepeatDirection.forward

// Access end repeat
final endMeasure = score.parts.first.measures[1];
final endBarline = endMeasure.barlines.first;
print('End repeat: ${endBarline.repeat?.direction}');    // RepeatDirection.backward
print('Repeat times: ${endBarline.repeat?.times}');      // 2
```

### First and Second Endings

```dart
// Parse MusicXML with endings
const musicXmlWithEndings = '''
<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part-list>
    <score-part id="P1">
      <part-name>Piano</part-name>
    </score-part>
  </part-list>
  <part id="P1">
    <measure number="1">
      <barline location="right">
        <ending number="1" type="start">1.</ending>
      </barline>
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>480</duration>
      </note>
    </measure>
    <measure number="2">
      <note>
        <pitch>
          <step>D</step>
          <octave>4</octave>
        </pitch>
        <duration>480</duration>
      </note>
      <barline location="right">
        <ending number="1" type="stop"/>
        <repeat direction="backward"/>
      </barline>
    </measure>
    <measure number="3">
      <barline location="left">
        <ending number="2" type="start">2.</ending>
      </barline>
      <note>
        <pitch>
          <step>E</step>
          <octave>4</octave>
        </pitch>
        <duration>480</duration>
      </note>
      <barline location="right">
        <ending number="2" type="stop"/>
      </barline>
    </measure>
  </part>
</score-partwise>
''';

final score = parser.parse(musicXmlWithEndings);

// Access first ending
final firstEndingMeasure = score.parts.first.measures.first;
final firstEndingBarline = firstEndingMeasure.barlines.first;
final firstEnding = firstEndingBarline.ending!;

print('First ending number: ${firstEnding.number}'); // "1"
print('First ending type: ${firstEnding.type}');     // EndingType.start
print('First ending text: ${firstEnding.text}');     // "1."

// Access second ending
final secondEndingMeasure = score.parts.first.measures[2];
final secondEndingStartBarline = secondEndingMeasure.barlines.first;
final secondEnding = secondEndingStartBarline.ending!;

print('Second ending number: ${secondEnding.number}'); // "2"
print('Second ending type: ${secondEnding.type}');     // EndingType.start
print('Second ending text: ${secondEnding.text}');     // "2."
```

## Model Classes

### Barline

The `Barline` class represents a barline in a musical score:

```dart
// Create a simple barline
const barline = Barline(
  location: BarlineLocation.right,
  style: BarlineStyle.regular,
);

// Create a barline with repeat and ending
final complexBarline = Barline(
  location: BarlineLocation.right,
  style: BarlineStyle.lightHeavy,
  repeat: Repeat(direction: RepeatDirection.backward, times: 2),
  ending: Ending(number: '1', type: EndingType.start, text: '1st time'),
);
```

### Repeat

The `Repeat` class represents repeat signs:

```dart
// Start repeat (forward)
const startRepeat = Repeat(direction: RepeatDirection.forward);

// End repeat (backward) with specific number of times
const endRepeat = Repeat(direction: RepeatDirection.backward, times: 3);
```

### Ending

The `Ending` class represents first/second endings:

```dart
// First ending
const firstEnding = Ending(
  number: '1',
  type: EndingType.start,
  text: '1st time',
);

// Second ending
const secondEnding = Ending(
  number: '2',
  type: EndingType.stop,
);

// Multiple endings (1st and 2nd time)
const multipleEnding = Ending(
  number: '1,2',
  type: EndingType.start,
  text: '1st, 2nd time',
);
```

## Supported Features

### Barline Locations
- `BarlineLocation.left` - Left side of measure
- `BarlineLocation.right` - Right side of measure  
- `BarlineLocation.middle` - Middle of measure

### Barline Styles
- `BarlineStyle.regular` - Normal single line
- `BarlineStyle.lightHeavy` - Final barline (thin-thick)
- `BarlineStyle.heavyLight` - Start repeat (thick-thin)
- `BarlineStyle.lightLight` - Double barline (thin-thin)
- `BarlineStyle.heavyHeavy` - Heavy double barline (thick-thick)
- `BarlineStyle.dashed` - Dashed barline
- `BarlineStyle.dotted` - Dotted barline
- `BarlineStyle.none` - Invisible barline

### Repeat Directions
- `RepeatDirection.forward` - Start repeat (|:)
- `RepeatDirection.backward` - End repeat (:|)

### Ending Types
- `EndingType.start` - Begin an ending
- `EndingType.stop` - End an ending
- `EndingType.discontinue` - Partial ending (doesn't close)

## Integration with Measures

Barlines are automatically parsed and included in `Measure` objects:

```dart
final measure = Measure(
  number: '1',
  notes: [/* notes */],
  barlines: [
    Barline(
      location: BarlineLocation.right,
      style: BarlineStyle.regular,
    ),
  ],
);

// Access barlines
print('Number of barlines: ${measure.barlines.length}');
for (final barline in measure.barlines) {
  print('Barline: ${barline.location} ${barline.style}');
  if (barline.repeat != null) {
    print('  Repeat: ${barline.repeat!.direction}');
  }
  if (barline.ending != null) {
    print('  Ending: ${barline.ending!.number} ${barline.ending!.type}');
  }
}
```