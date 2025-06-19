# Logging Support in MusicXML Parser

The `musicxml_parser` package includes comprehensive logging support to help with debugging, error tracking, and monitoring the parsing process. This document explains how to configure and use the logging features.

## Overview

The logging system provides:
- **Structured logging** with different levels (debug, info, warning, error)
- **Context-rich messages** including element names, line numbers, and parsing context
- **Performance monitoring** with optional timing information
- **Configurable output** with custom formatters and log levels
- **Exception logging** with full stack traces and error context

## Quick Start

### Basic Logging

```dart
import 'package:musicxml_parser/musicxml_parser.dart';

// Default logging (INFO level and above)
final parser = MusicXmlParser();
final score = parser.parse(xmlString);
```

### Debug Logging

```dart
// Enable detailed debug logging
final parser = MusicXmlParser(
  loggingConfig: const LoggingConfig.debug(),
);
final score = parser.parse(xmlString);
```

### Production Logging

```dart
// Minimal logging for production
final parser = MusicXmlParser(
  loggingConfig: const LoggingConfig.production(),
);
final score = parser.parse(xmlString);
```

### Silent Logging

```dart
// No logging output
final parser = MusicXmlParser(
  loggingConfig: const LoggingConfig.silent(),
);
final score = parser.parse(xmlString);
```

## Configuration Options

### LoggingConfig Class

The `LoggingConfig` class provides various options to customize logging behavior:

```dart
const LoggingConfig({
  Level logLevel = Level.INFO,           // Minimum log level
  bool includeStackTraces = true,        // Include stack traces in error logs
  bool enableDebugLogs = false,          // Enable detailed debug information
  bool enablePerformanceLogs = false,    // Enable performance timing logs
  String Function(LogRecord)? formatter, // Custom log formatter
});
```

### Pre-defined Configurations

#### Debug Configuration
```dart
const LoggingConfig.debug()
```
- Log level: `Level.ALL` (all messages)
- Stack traces: Enabled
- Debug logs: Enabled
- Performance logs: Enabled

#### Production Configuration
```dart
const LoggingConfig.production()
```
- Log level: `Level.WARNING` (warnings and errors only)
- Stack traces: Disabled
- Debug logs: Disabled
- Performance logs: Disabled

#### Silent Configuration
```dart
const LoggingConfig.silent()
```
- Log level: `Level.OFF` (no logging)
- All features: Disabled

### Custom Configuration

```dart
final parser = MusicXmlParser(
  loggingConfig: LoggingConfig(
    logLevel: Level.FINE,
    includeStackTraces: false,
    enableDebugLogs: true,
    enablePerformanceLogs: true,
    formatter: (record) => '${record.level.name}: ${record.message}',
  ),
);
```

## Log Levels and Messages

### Information Logs (Level.INFO)
- Parser initialization
- File operations start/completion
- High-level parsing progress
- Part and measure counts

Example:
```
[INFO   ] MusicXmlParser: Starting MusicXML parsing
[INFO   ] MusicXmlParser: Found score-partwise format, parsing...
[INFO   ] MusicXmlParser: Parsing 3 parts
[INFO   ] MusicXmlParser: MusicXML parsing completed in 45ms
```

### Debug Logs (Level.FINE)
- Detailed parsing steps
- Element processing
- Score metadata extraction
- File reading progress

Example:
```
[FINE   ] MusicXmlParser: Parsing XML document (2048 characters)
[FINE   ] MusicXmlParser: XML document parsed successfully
[FINE   ] MusicXmlParser: Parsing score-partwise element
[FINE   ] MusicXmlParser: Score metadata - Title: Symphony No. 1, Composer: Mozart
```

### Warning Logs (Level.WARNING)
- Non-critical parsing issues
- Missing optional elements
- Data quality concerns

### Error Logs (Level.SEVERE)
- Parsing failures
- File system errors
- Validation errors
- Exception details with context

Example:
```
[SEVERE ] MusicXmlParser: Failed to read MusicXML file (element: score-partwise, line: 10) [context: {filePath: /path/to/file.xml}]
  Error: FileSystemException: Cannot open file
  Stack trace: ...
```

## Context Information

All log messages include relevant context information:

- **Element names**: The XML element being processed
- **Line numbers**: Location in the XML file (when available)
- **Parsing context**: Additional information like part IDs, measure numbers
- **File paths**: For file operations
- **Performance metrics**: Timing information when enabled

## Exception Logging

All exceptions are automatically logged with full context:

```dart
try {
  final score = parser.parse(invalidXml);
} on MusicXmlParseException catch (e) {
  // Exception details are already logged with:
  // - Error message and type
  // - Stack trace (if enabled)
  // - Element and line information
  // - Parsing context
  print('Parsing failed: ${e.message}');
}
```

## Integration with dart:developer

The logging system integrates with Dart's `dart:developer` package for better debugging support:

- Log messages appear in IDE debugging consoles
- Integration with Flutter's logging tools
- Support for log filtering and searching
- Structured log data for analysis tools

## Performance Considerations

### Default Configuration
- Minimal performance impact
- Only INFO level and above logged
- No debug message processing overhead

### Debug Configuration
- Higher performance impact due to detailed logging
- Use only during development and debugging
- Consider disabling for production builds

### Silent Configuration
- Zero logging overhead
- Recommended for performance-critical applications
- No log processing or output

## Best Practices

### Development
```dart
final parser = MusicXmlParser(
  loggingConfig: const LoggingConfig.debug(),
);
```

### Testing
```dart
final parser = MusicXmlParser(
  loggingConfig: const LoggingConfig(
    logLevel: Level.WARNING, // Only warnings and errors
    includeStackTraces: true,
  ),
);
```

### Production
```dart
final parser = MusicXmlParser(
  loggingConfig: const LoggingConfig.production(),
);
```

### Performance-Critical
```dart
final parser = MusicXmlParser(
  loggingConfig: const LoggingConfig.silent(),
);
```

## Advanced Usage

### Custom Formatters

```dart
String customFormatter(LogRecord record) {
  return '${record.time.millisecondsSinceEpoch}: ${record.message}';
}

final parser = MusicXmlParser(
  loggingConfig: LoggingConfig(
    formatter: customFormatter,
  ),
);
```

### Filtering Logs

Since the package uses the standard `logging` package, you can set up custom filters:

```dart
import 'package:logging/logging.dart';

Logger.root.onRecord.listen((record) {
  if (record.loggerName == 'MusicXmlParser' && record.level >= Level.WARNING) {
    print('Parser warning/error: ${record.message}');
  }
});
```

### Log Analysis

You can capture and analyze logs programmatically:

```dart
final logRecords = <LogRecord>[];

Logger.root.onRecord.listen(logRecords.add);

// Parse files...

// Analyze logs
final errors = logRecords.where((r) => r.level >= Level.SEVERE);
final parseTime = logRecords
    .where((r) => r.message.contains('parsing completed'))
    .map((r) => /* extract timing */)
    .first;
```

## See Also

- [Error Handling Examples](error-handling-examples.md)
- [Warning System Documentation](warning-system.md)
- [Dart Logging Package](https://pub.dev/packages/logging)
- [Performance Optimization Guide](performance-guide.md)