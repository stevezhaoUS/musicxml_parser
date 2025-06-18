# musicxml_parser

A Dart package for parsing MusicXML files (versions 3.0/3.1/4.0) into Dart objects.

## Features

- ✅ Parse core MusicXML elements (notes, pitches, durations, lyrics)
- ✅ Handle multi-part scores with proper part/measure structure
- ✅ Support key signatures, time signatures, and clefs
- ✅ Basic tie and chord support
- ✅ Metadata parsing (title, composer, identification)
- 🚧 Dotted notes and basic tuplets
- ⏳ Repeats, articulations, and dynamics (planned)

📋 **[Complete Feature Support List](docs/feature-support.md)** - See detailed status of all MusicXML features

## Installation

```yaml
dependencies:
  musicxml_parser: ^0.1.0
```

## Usage

```dart
import 'package:musicxml_parser/musicxml_parser.dart';

void main() async {
  final parser = MusicXmlParser();
  
  // Parse from string
  final xmlString = '<?xml version="1.0"?><score-partwise>...</score-partwise>';
  final score = parser.parse(xmlString);
  
  // Parse from file
  final score2 = await parser.parseFromFile('path/to/score.musicxml');
  
  // Access score data
  print('Title: ${score.title}');
  print('Composer: ${score.composer}');
  
  for (final part in score.parts) {
    print('Part: ${part.name}');
    
    for (final measure in part.measures) {
      print('Measure ${measure.number}');
      
      for (final note in measure.notes) {
        if (note.isRest) {
          print('Rest (${note.duration.value})');
        } else {
          print('Note: ${note.pitch!.step}${note.pitch!.octave} (${note.duration.value})');
        }
      }
    }
  }
}
```

## Features and Roadmap

📋 **[Complete Feature Support List](docs/feature-support.md)** - Detailed status of all MusicXML features

### Current Version (v0.1.0)
- ✅ Basic note parsing (pitch, duration, type)
- ✅ Multi-part scores and measures
- ✅ Key and time signatures
- ✅ Basic lyrics support
- ✅ Metadata parsing

### Next Release (v0.2.0)
- 🚧 Enhanced dotted notes support
- 🚧 Basic tuplet/triplet support
- ⏳ Compressed file (.mxl) support
- ⏳ Improved error handling

### Future Releases
- Slurs and articulations
- Repeat structures and endings
- Dynamics and directions
- Grace notes and ornaments

## License

This project is licensed under the MIT License - see the LICENSE file for details.
