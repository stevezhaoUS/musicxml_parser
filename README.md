# musicxml_parser

[![CI](https://github.com/stevezhaoUS/musicxml_parser/workflows/CI/badge.svg?branch=main)](https://github.com/stevezhaoUS/musicxml_parser/actions/workflows/ci.yml)
[![Code Quality](https://github.com/stevezhaoUS/musicxml_parser/workflows/Code%20Quality/badge.svg?branch=main)](https://github.com/stevezhaoUS/musicxml_parser/actions/workflows/code-quality.yml)
[![pub package](https://img.shields.io/pub/v/musicxml_parser.svg)](https://pub.dev/packages/musicxml_parser)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Dart package for parsing MusicXML files (versions 3.0/3.1/4.0) into Dart objects.

## Features

- ✅ Parse core MusicXML elements (notes, pitches, durations, lyrics)
- ✅ Handle multi-part scores with proper part/measure structure
- ✅ Support key signatures, time signatures, and clefs
- ✅ Basic tie and chord support
- ✅ Metadata parsing (title, composer, identification)
- ✅ **Enhanced error handling with detailed error messages and context**
- ✅ **Musical validation (pitch ranges, time signatures, key signatures)**
- ✅ **Warning system for non-critical issues**
- 🚧 Dotted notes and basic tuplets
- ⏳ Repeats, articulations, and dynamics (planned)

📋 **[Complete Feature Support List](docs/feature-support.md)** - See detailed status of all MusicXML features  
🚨 **[Enhanced Error Handling Examples](docs/error-handling-examples.md)** - Learn about the comprehensive error handling system

## Project Status

![Dart Version](https://img.shields.io/badge/dart-%3E%3D3.0.0-blue)
![Flutter Compatibility](https://img.shields.io/badge/flutter-compatible-blue)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

**Current Version:** 0.1.0 (Development)  
**Test Coverage:** ![Coverage](https://img.shields.io/badge/coverage-95%25-brightgreen)  
**Build Status:** ![Build](https://img.shields.io/badge/build-passing-brightgreen)

### Quick Stats
- 📁 **8 Model Classes** (Pitch, Note, Measure, Part, Score, etc.)
- 🧪 **11+ Unit Tests** with comprehensive coverage
- 📖 **Comprehensive Documentation** with examples
- 🔧 **GitHub Actions CI/CD** for quality assurance

### 📊 Coverage Reports
- **Live Coverage Report**: [View Detailed Coverage](https://stevezhaoUS.github.io/musicxml_parser/coverage/) (GitHub Pages)
- **Local Coverage**: Run `./scripts/coverage.sh` to generate local HTML report

## Quick Start

```dart
import 'package:musicxml_parser/musicxml_parser.dart';

// Basic parsing
final parser = MusicXmlParser();
final score = parser.parse(musicXmlString);
print('Title: ${score.title}');
print('Notes: ${score.parts.first.measures.first.notes.length}');

// With enhanced error handling
try {
  final score = parser.parse(xmlString);
  print('Parsed successfully!');
} on MusicXmlValidationException catch (e) {
  print('Validation error: ${e.message}');
} on MusicXmlParseException catch (e) {
  print('Parse error: ${e.message}');
}

// With logging for debugging
final debugParser = MusicXmlParser(
  loggingConfig: const LoggingConfig.debug(),
);
final score = debugParser.parse(xmlString);
```

## Installation

```yaml
dependencies:
  musicxml_parser: ^0.1.0
```

## Usage

```dart
import 'package:musicxml_parser/musicxml_parser.dart';

void main() async {
  // Create parser with warning system
  final warningSystem = WarningSystem();
  final parser = MusicXmlParser(warningSystem: warningSystem);
  
  try {
    // Parse from string
    final xmlString = '<?xml version="1.0"?><score-partwise>...</score-partwise>';
    final score = parser.parse(xmlString);
    
    // Parse from file
    final score2 = await parser.parseFromFile('path/to/score.musicxml');
    
    // Access score data
    print('Title: ${score.title}');
    print('Composer: ${score.composer}');
    print('Parts: ${score.parts.length}');
    
    // Check for warnings
    if (warningSystem.hasWarnings) {
      print('Found ${warningSystem.warningCount} warnings');
      warningSystem.printWarnings();
    }
    
  } on MusicXmlStructureException catch (e) {
    print('Structure error: ${e.message}');
  } on MusicXmlValidationException catch (e) {
    print('Validation error: ${e.message}');
  } on MusicXmlParseException catch (e) {
    print('Parse error: ${e.message}');
  }
}
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

## Contributing

We welcome contributions! Please see our [Contributing Guide](.github/CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/stevezhaoUS/musicxml_parser.git
cd musicxml_parser

# Get dependencies
dart pub get

# Run tests
dart test

# Run static analysis
dart analyze
```

### Reporting Issues

Found a bug or have a feature request? Please [open an issue](https://github.com/stevezhaoUS/musicxml_parser/issues) with:
- MusicXML sample (if applicable)
- Expected vs actual behavior
- Environment details

## Acknowledgments

- [MusicXML Specification](https://www.w3.org/2021/06/musicxml40/) by W3C
- [xml package](https://pub.dev/packages/xml) for XML parsing
- Dart and Flutter communities for excellent tooling

## License

This project is licensed under the MIT License - see the LICENSE file for details.
