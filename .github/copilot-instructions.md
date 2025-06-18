# Copilot Instructions for `musicxml_parser` Dart Package

## Overview

This document provides instructions for GitHub Copilot to assist in maintaining and extending the `musicxml_parser` package - a pure Dart package for parsing MusicXML files into Dart objects.

## Project Context

- **Purpose**: Parse MusicXML (versions 3.0/3.1/4.0) files into Dart objects for use in Dart/Flutter applications.
- **Package Type**: Pure Dart package (not Flutter-specific)
- **Current Dependencies**:
  - `xml: ^6.5.0` for XML parsing
  - `meta: ^1.9.0` for immutability annotations
  - `test: ^1.24.0` and `mockito: ^5.4.4` for testing
  - `lint: ^2.3.0` for static analysis

## Core Development Guidelines

### Project-Specific Requirements
- **Documentation**: Every public API must have comprehensive dartdoc comments with examples
- **Testing**: Every file must have corresponding test file with >90% coverage
- **Focus**: Implement one feature at a time, ensuring it is fully tested before moving to the next
- **Immutability**: Use `@immutable` annotation and prefer immutable data structures

### Code Structure
- **Model classes** go in `lib/src/models/`
- **Parser logic** goes in `lib/src/parser/`
- **Utilities** go in `lib/src/utils/`
- **Exceptions** go in `lib/src/exceptions/`
- **Tests** mirror the `lib/` structure in `test/`

### MusicXML-Specific Guidelines
- Use custom exceptions (extend `InvalidMusicXmlException`)
- Include element names and line numbers in error messages
- Use streaming XML parsing for large files
- Use named constants for divisions, MIDI values, etc.

### Music Theory Accuracy
- Validate pitch ranges (C0-B9 for standard notation)
- Ensure duration calculations are mathematically correct
- Verify key signature logic follows circle of fifths
- Check time signature validity (positive denominators as powers of 2)
- Maintain MIDI note number accuracy (0-127 range)

For detailed technical references:
- **[Music Theory Guide](../docs/music-theory-guide.md)**: Essential music theory concepts
- **[MusicXML Format Guide](../docs/musicxml-format-guide.md)**: Complete MusicXML format reference
- **[Feature Support List](../docs/feature-support.md)**: Current implementation status of all MusicXML features
