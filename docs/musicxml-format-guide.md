# MusicXML Format Reference Guide

This document provides essential MusicXML format knowledge for accurate parsing and implementation.

## MusicXML Overview

### Supported Versions
- **MusicXML 3.0**: Basic format with core musical elements
- **MusicXML 3.1**: Added support for percussion, improved formatting
- **MusicXML 4.0**: Enhanced metadata, new elements, improved structure

### Document Structure
- **Compressed (.mxl)**: ZIP archive containing MusicXML and media files
- **Uncompressed (.musicxml/.xml)**: Plain XML format

## Root Elements

### Score-Partwise vs Score-Timewise
```xml
<!-- Score-Partwise (most common) -->
<score-partwise version="4.0">
  <part-list>...</part-list>
  <part id="P1">
    <measure number="1">...</measure>
    <measure number="2">...</measure>
  </part>
</score-partwise>

<!-- Score-Timewise (less common) -->
<score-timewise version="4.0">
  <part-list>...</part-list>
  <measure number="1">
    <part id="P1">...</part>
    <part id="P2">...</part>
  </measure>
</score-timewise>
```

## Core Elements

### Part List
```xml
<part-list>
  <score-part id="P1">
    <part-name>Piano</part-name>
    <part-abbreviation>Pno.</part-abbreviation>
    <score-instrument id="P1-I1">
      <instrument-name>Acoustic Grand Piano</instrument-name>
    </score-instrument>
    <midi-device id="P1-I1" port="1" />
    <midi-instrument id="P1-I1">
      <midi-channel>1</midi-channel>
      <midi-program>1</midi-program>
      <volume>78.7402</volume>
      <pan>0</pan>
    </midi-instrument>
  </score-part>
</part-list>
```

### Measures
```xml
<measure number="1">
  <!-- Attributes (key signature, time signature, divisions) -->
  <attributes>
    <divisions>480</divisions>
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
  
  <!-- Notes and rests -->
  <note>...</note>
  <note>...</note>
</measure>
```

### Notes
```xml
<!-- Pitched note -->
<note default-x="100.0" default-y="-80.0">
  <pitch>
    <step>C</step>
    <octave>4</octave>
  </pitch>
  <duration>480</duration>
  <voice>1</voice>
  <type>quarter</type>
  <stem>up</stem>
  <notations>
    <dynamics>
      <p /> <!-- Example: piano -->
    </dynamics>
  </notations>
</note>

<!-- Rest -->
<note>
  <rest />
  <duration>480</duration>
  <voice>1</voice>
  <type>quarter</type>
</note>

<!-- Chord note -->
<!-- The <chord/> element indicates this note is part of a chord with the preceding note -->
<note>
  <chord/>
  <pitch>
    <step>E</step>
    <octave>4</octave>
  </pitch>
  <duration>480</duration> <!-- Duration is often the same as the first note in the chord -->
  <voice>1</voice>
  <type>quarter</type>
  <stem>up</stem> <!-- Stem direction usually matches the first note of the chord -->
</note>

<!-- Chord note -->
<note>
  <chord />
  <pitch>
    <step>E</step>
    <octave>4</octave>
  </pitch>
  <duration>480</duration>
  <voice>1</voice>
  <type>quarter</type>
</note>
```

### Pitch Elements
```xml
<pitch>
  <step>F</step>           <!-- C, D, E, F, G, A, B -->
  <alter>1</alter>         <!-- -2, -1, 0, 1, 2 (double-flat to double-sharp) -->
  <octave>4</octave>       <!-- 0-9 -->
</pitch>
```

### Duration and Time
```xml
<!-- Duration in divisions -->
<duration>480</duration>    <!-- Quarter note = 480 divisions (typical) -->

<!-- Note type -->
<type>quarter</type>        <!-- whole, half, quarter, eighth, 16th, 32nd, etc. -->

<!-- Dotted notes -->
<dot />                     <!-- First dot -->
<dot />                     <!-- Second dot -->

<!-- Time modification (tuplets) -->
<time-modification>
  <actual-notes>3</actual-notes>
  <normal-notes>2</normal-notes>
</time-modification>
```

## Key Signatures
```xml
<key>
  <fifths>2</fifths>        <!-- -7 to +7: negative=flats, positive=sharps -->
  <mode>major</mode>        <!-- major, minor, etc. -->
</key>

<!-- Traditional key signatures -->
<!-- -7: Cb major/Ab minor -->
<!-- -1: F major/D minor -->
<!--  0: C major/A minor -->
<!--  1: G major/E minor -->
<!--  7: C# major/A# minor -->
```

## Time Signatures
```xml
<!-- Simple time signatures -->
<time>
  <beats>4</beats>
  <beat-type>4</beat-type>
</time>

<!-- Compound time signatures -->
<time>
  <beats>6</beats>
  <beat-type>8</beat-type>
</time>

<!-- Complex time signatures -->
<time>
  <beats>3</beats>
  <beat-type>4</beat-type>
  <beats>2</beats>
  <beat-type>4</beat-type>
</time>
```

## Clefs
```xml
<!-- Treble clef -->
<clef>
  <sign>G</sign>
  <line>2</line>
</clef>

<!-- Bass clef -->
<clef>
  <sign>F</sign>
  <line>4</line>
</clef>

<!-- Alto clef -->
<clef>
  <sign>C</sign>
  <line>3</line>
</clef>

<!-- Treble clef, one octave down (e.g., for Tenor voice) -->
<clef>
  <sign>G</sign>
  <line>2</line>
  <clef-octave-change>-1</clef-octave-change>
</clef>

<!-- Percussion clef (line is optional) -->
<clef>
  <sign>percussion</sign>
</clef>

<!-- Clef for a specific staff (e.g., staff 2 in a piano part) -->
<clef number="2">
  <sign>F</sign>
  <line>4</line>
</clef>
```
The `<clef>` element can also include a `number` attribute to specify which staff it applies to (useful for multi-staff instruments) and a `<clef-octave-change>` element (e.g., -1 for an octave lower, 1 for an octave higher).

## Lyrics
```xml
<note>
  <pitch>...</pitch>
  <duration>480</duration>
  <lyric number="1">
    <syllabic>begin</syllabic>  <!-- single, begin, middle, end -->
    <text>Hel</text>
  </lyric>
  <lyric number="1">
    <syllabic>end</syllabic>
    <text>lo</text>
  </lyric>
</note>
```

## Ties and Slurs
```xml
<!-- Ties (same pitch) -->
<note>
  <pitch>...</pitch>
  <duration>480</duration>
  <tie type="start" />
</note>
<note>
  <pitch>...</pitch>
  <duration>240</duration>
  <tie type="stop" />
</note>

<!-- Slurs (different pitches) -->
<note>
  <pitch>...</pitch>
  <duration>480</duration>
  <notations>
    <slur type="start" number="1" />
  </notations>
</note>
```

## Repeats
```xml
<!-- Repeat barlines -->
<barline location="left">
  <bar-style>heavy-light</bar-style>
  <repeat direction="forward" />
</barline>

<barline location="right">
  <bar-style>light-heavy</bar-style>
  <repeat direction="backward" />
</barline>

<!-- Endings -->
<barline location="right">
  <ending number="1" type="start">1.</ending>
</barline>
```

## Metadata
```xml
<work>
  <work-title>Symphony No. 5</work-title>
  <work-number>Op. 67</work-number>
</work>

<identification>
  <creator type="composer">Ludwig van Beethoven</creator>
  <creator type="lyricist">Text Author</creator>
  <rights>Copyright Notice</rights>
  <encoding>
    <software>MuseScore 4.0</software>
    <encoding-date>2025-06-18</encoding-date>
  </encoding>
</identification>
```

## Common Parsing Patterns

### Version Detection
```dart
String detectMusicXmlVersion(XmlElement root) {
  final version = root.getAttribute('version');
  if (version != null) return version;
  
  // Fallback detection based on elements
  if (root.findElements('credit').isNotEmpty) return '3.0+';
  return '2.0';
}
```

### Element Navigation
```dart
// Safe element access
XmlElement? findElement(XmlElement parent, String name) {
  final elements = parent.findElements(name);
  return elements.isNotEmpty ? elements.first : null;
}

// Required element access
XmlElement getRequiredElement(XmlElement parent, String name) {
  final element = findElement(parent, name);
  if (element == null) {
    throw InvalidMusicXmlException('Required element $name not found');
  }
  return element;
}
```

### Text Content Parsing
```dart
String? getElementText(XmlElement? element) {
  return element?.innerText.trim();
}

int? getElementInt(XmlElement? element) {
  final text = getElementText(element);
  return text != null ? int.tryParse(text) : null;
}

double? getElementDouble(XmlElement? element) {
  final text = getElementText(element);
  return text != null ? double.tryParse(text) : null;
}
```

### Validation Rules
```dart
void validateMeasureNumber(String? number) {
  if (number == null || number.isEmpty) {
    throw InvalidMusicXmlException('Measure number is required');
  }
  
  final measureNum = int.tryParse(number);
  if (measureNum == null || measureNum < 1) {
    throw InvalidMusicXmlException('Invalid measure number: $number');
  }
}

void validateDivisions(int? divisions) {
  if (divisions == null || divisions <= 0) {
    throw InvalidMusicXmlException('Divisions must be positive');
  }
}
```

## Error Handling Strategies

### Common Issues
- **Missing required elements**: Always check for null before accessing
- **Invalid numeric values**: Use `tryParse` methods
- **Inconsistent divisions**: Track divisions per part/measure
- **Malformed XML**: Wrap parsing in try-catch blocks

### Best Practices
1. **Validate early**: Check structure before deep parsing
2. **Provide context**: Include element names and positions in errors
3. **Handle variations**: Different software may generate slightly different XML
4. **Support partial parsing**: Continue parsing when non-critical elements are malformed

## Performance Considerations

### Large Files
- Use streaming XML parser for files > 10MB
- Parse metadata first to estimate complexity
- Implement lazy loading for measures
- Cache frequently accessed elements

### Memory Management
- Process measures sequentially
- Release parsed XML elements when done
- Use weak references for cross-references
- Implement pagination for very large scores

## References

- [MusicXML 4.0 Specification](https://www.w3.org/2021/06/musicxml40/)
- [MusicXML Tutorial](https://www.musicxml.com/tutorial/)
- [Common MusicXML Examples](https://www.musicxml.com/music-in-musicxml/)

## Last Updated
June 18, 2025
