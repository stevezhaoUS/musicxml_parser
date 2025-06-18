# Enhanced Error Handling Examples

The musicxml_parser package now includes comprehensive error handling with detailed error messages, musical validation, and a warning system for non-critical issues.

## Exception Types

### MusicXmlParseException
Thrown when parsing MusicXML content fails due to XML syntax issues or malformed elements.

```dart
try {
  final score = parser.parse(xmlString);
} on MusicXmlParseException catch (e) {
  print('Parse error: ${e.message}');
  print('Element: ${e.element}');
  print('Line: ${e.line}');
  print('Context: ${e.context}');
}
```

### MusicXmlValidationException
Thrown when MusicXML content violates musical rules or constraints.

```dart
try {
  final pitch = Pitch.validated(step: 'H', octave: 4); // Invalid step
} on MusicXmlValidationException catch (e) {
  print('Validation error: ${e.message}');
  print('Rule: ${e.rule}');
  print('Context: ${e.context}');
}
```

### MusicXmlStructureException
Thrown when MusicXML content has structural problems like missing required elements.

```dart
try {
  final score = parser.parse(xmlWithoutRoot);
} on MusicXmlStructureException catch (e) {
  print('Structure error: ${e.message}');
  print('Required element: ${e.requiredElement}');
  print('Parent element: ${e.parentElement}');
}
```

## Musical Validation

### Pitch Validation
- Step must be one of: C, D, E, F, G, A, B
- Octave must be between 0 and 9
- Alteration must be between -2 and +2

```dart
// Valid pitch
final pitch = Pitch.validated(step: 'C', octave: 4, alter: 1);

// Invalid pitch - throws MusicXmlValidationException
final invalidPitch = Pitch.validated(step: 'H', octave: 4); // Invalid step
```

### Time Signature Validation
- Beats must be positive
- Beat type must be a power of 2

```dart
// Valid time signature
final timeSignature = TimeSignature.validated(beats: 4, beatType: 4);

// Invalid time signature - throws MusicXmlValidationException
final invalidTime = TimeSignature.validated(beats: 4, beatType: 3); // Not power of 2
```

### Key Signature Validation
- Fifths must be between -7 and +7
- Mode must be a valid musical mode

```dart
// Valid key signature
final keySignature = KeySignature.validated(fifths: 2, mode: 'major');

// Invalid key signature - throws MusicXmlValidationException
final invalidKey = KeySignature.validated(fifths: 8); // Out of range
```

## Warning System

The parser includes a warning system for non-critical issues that don't prevent parsing but may indicate problems.

```dart
final warningSystem = WarningSystem();
final parser = MusicXmlParser(warningSystem: warningSystem);

final score = parser.parse(xmlString);

// Check for warnings
if (warningSystem.hasWarnings) {
  print('Parsing completed with ${warningSystem.warningCount} warnings:');
  
  for (final warning in warningSystem.getWarnings()) {
    print('${warning.severity.name.toUpperCase()}: ${warning.message}');
    if (warning.line != null) {
      print('  Line: ${warning.line}');
    }
    if (warning.context != null) {
      print('  Context: ${warning.context}');
    }
  }
}
```

### Warning Categories
Warnings are categorized for easy filtering:
- `parsing` - General parsing issues
- `structure` - Structural problems
- `validation` - Validation concerns
- `pitch` - Pitch-related issues
- `duration` - Duration problems
- `time_signature` - Time signature issues
- `key_signature` - Key signature problems
- `measure` - Measure-level issues
- `voice` - Voice assignment problems

### Warning Severity Levels
- `info` - Informational warnings
- `minor` - Minor issues that might affect interpretation
- `moderate` - Moderate issues that could cause problems
- `serious` - Serious issues that are likely to cause problems

```dart
// Filter warnings by category and severity
final seriousWarnings = warningSystem.getWarningsByMinSeverity(WarningSeverity.serious);
final pitchWarnings = warningSystem.getWarningsByCategory(WarningCategories.pitch);
```

## Error Context

All exceptions include rich context information:

```dart
try {
  final score = parser.parse(xmlString);
} on MusicXmlValidationException catch (e) {
  print('Error in part: ${e.context?['partId']}');
  print('Error in measure: ${e.context?['measureNumber']}');
  print('Error at line: ${e.line}');
}
```

## Comprehensive Example

```dart
import 'package:musicxml_parser/musicxml_parser.dart';

void parseWithEnhancedErrorHandling(String xmlString) {
  final warningSystem = WarningSystem();
  final parser = MusicXmlParser(warningSystem: warningSystem);

  try {
    final score = parser.parse(xmlString);
    
    print('Successfully parsed MusicXML:');
    print('Title: ${score.title ?? 'Unknown'}');
    print('Parts: ${score.parts.length}');
    
    // Check for warnings
    if (warningSystem.hasWarnings) {
      print('\nWarnings (${warningSystem.warningCount}):');
      warningSystem.printWarnings();
    }
    
  } on MusicXmlStructureException catch (e) {
    print('Structure Error: ${e.message}');
    if (e.requiredElement != null) {
      print('Missing: ${e.requiredElement}');
    }
    
  } on MusicXmlValidationException catch (e) {
    print('Validation Error: ${e.message}');
    print('Rule: ${e.rule}');
    
  } on MusicXmlParseException catch (e) {
    print('Parse Error: ${e.message}');
    if (e.element != null) {
      print('Element: ${e.element}');
    }
    
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

This enhanced error handling system provides developers with detailed information about what went wrong and where, making it much easier to debug MusicXML parsing issues and ensure data quality.