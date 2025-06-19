import 'dart:io';
import 'package:logging/logging.dart';
import 'package:musicxml_parser/musicxml_parser.dart';
import 'package:test/test.dart';

void main() {
  group('LoggingConfig', () {
    test('creates default configuration', () {
      const config = LoggingConfig();
      
      expect(config.logLevel, equals(Level.INFO));
      expect(config.includeStackTraces, isTrue);
      expect(config.enableDebugLogs, isFalse);
      expect(config.enablePerformanceLogs, isFalse);
      expect(config.formatter, isNull);
    });

    test('creates debug configuration', () {
      const config = LoggingConfig.debug();
      
      expect(config.logLevel, equals(Level.ALL));
      expect(config.includeStackTraces, isTrue);
      expect(config.enableDebugLogs, isTrue);
      expect(config.enablePerformanceLogs, isTrue);
      expect(config.formatter, isNull);
    });

    test('creates production configuration', () {
      const config = LoggingConfig.production();
      
      expect(config.logLevel, equals(Level.WARNING));
      expect(config.includeStackTraces, isFalse);
      expect(config.enableDebugLogs, isFalse);
      expect(config.enablePerformanceLogs, isFalse);
      expect(config.formatter, isNull);
    });

    test('creates silent configuration', () {
      const config = LoggingConfig.silent();
      
      expect(config.logLevel, equals(Level.OFF));
      expect(config.includeStackTraces, isFalse);
      expect(config.enableDebugLogs, isFalse);
      expect(config.enablePerformanceLogs, isFalse);
      expect(config.formatter, isNull);
    });

    test('default formatter includes timestamp and level', () {
      final record = LogRecord(
        Level.INFO,
        'Test message',
        'TestLogger',
        null,
        null,
      );
      
      final formatted = LoggingConfig.defaultFormatter(record);
      
      expect(formatted, contains('[INFO   ]'));
      expect(formatted, contains('TestLogger:'));
      expect(formatted, contains('Test message'));
    });

    test('default formatter includes error and stack trace', () {
      final stackTrace = StackTrace.fromString('test stack trace');
      final record = LogRecord(
        Level.SEVERE,
        'Error message',
        'TestLogger',
        Exception('Test error'),
        stackTrace,
      );
      
      final formatted = LoggingConfig.defaultFormatter(record);
      
      expect(formatted, contains('Error message'));
      expect(formatted, contains('Error: Exception: Test error'));
      expect(formatted, contains('Stack trace'));
    });

    test('formatParsingLog includes all context', () {
      final formatted = LoggingConfig.formatParsingLog(
        Level.WARNING,
        'Test parsing message',
        element: 'note',
        line: 42,
        context: {'partId': 'P1', 'measureNumber': '1'},
        error: Exception('Parse error'),
      );
      
      expect(formatted, contains('Test parsing message'));
      expect(formatted, contains('(element: note, line: 42)'));
      expect(formatted, contains('[context: {partId: P1, measureNumber: 1}]'));
      expect(formatted, contains('Error: Exception: Parse error'));
    });
  });

  group('LoggingUtils', () {
    test('creates logger with correct name', () {
      final logger = LoggingUtils.createLogger('TestLogger');
      
      expect(logger.name, equals('TestLogger'));
    });

    test('setupLogging configures root logger level', () {
      const config = LoggingConfig(logLevel: Level.WARNING);
      LoggingUtils.setupLogging(config);
      
      expect(Logger.root.level, equals(Level.WARNING));
    });

    test('setupLogging clears existing listeners', () {
      // Track number of listeners before and after
      var listenerCalled = false;
      Logger.root.onRecord.listen((_) { listenerCalled = true; });
      
      const config = LoggingConfig();
      LoggingUtils.setupLogging(config, clearExistingListeners: true);
      
      // Test that logging still works after setup
      final testLogger = Logger('TestLogger');
      testLogger.info('Test message');
      
      // The old listener should not have been called due to clearing
      expect(listenerCalled, isFalse);
    });

    test('logParsingStep formats message correctly', () {
      final logger = LoggingUtils.createLogger('TestParser');
      final logRecords = <LogRecord>[];
      
      // Capture log records
      logger.onRecord.listen(logRecords.add);
      
      LoggingUtils.logParsingStep(
        logger,
        Level.INFO,
        'Parsing element',
        element: 'measure',
        line: 10,
        context: {'id': '1'},
      );
      
      expect(logRecords, hasLength(1));
      final record = logRecords.first;
      expect(record.level, equals(Level.INFO));
      expect(record.message, contains('Parsing element'));
      expect(record.message, contains('(element: measure, line: 10)'));
      expect(record.message, contains('[context: {id: 1}]'));
    });

    test('logException includes exception details', () {
      final logger = LoggingUtils.createLogger('TestParser');
      final logRecords = <LogRecord>[];
      
      // Capture log records
      logger.onRecord.listen(logRecords.add);
      
      final exception = Exception('Test exception');
      final stackTrace = StackTrace.fromString('test stack');
      
      LoggingUtils.logException(
        logger,
        exception,
        stackTrace: stackTrace,
        element: 'note',
        line: 5,
        context: {'partId': 'P1'},
        additionalMessage: 'Failed to parse note',
      );
      
      expect(logRecords, hasLength(1));
      final record = logRecords.first;
      expect(record.level, equals(Level.SEVERE));
      expect(record.message, contains('Failed to parse note'));
      expect(record.message, contains('(element: note, line: 5)'));
      expect(record.message, contains('[context: {partId: P1}]'));
      expect(record.error, equals(exception));
      expect(record.stackTrace, equals(stackTrace));
    });
  });

  group('MusicXmlParser with Logging', () {
    late List<LogRecord> logRecords;
    
    setUp(() {
      logRecords = <LogRecord>[];
      
      // Setup logging to capture records
      Logger.root.level = Level.ALL;
      Logger.root.clearListeners();
      Logger.root.onRecord.listen(logRecords.add);
    });

    test('logs successful parsing', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
    </measure>
  </part>
</score-partwise>''';

      final parser = MusicXmlParser(
        loggingConfig: const LoggingConfig.debug(),
      );
      
      parser.parse(xml);
      
      // Should have info logs for starting and completing parsing
      final infoLogs = logRecords.where((r) => r.level == Level.INFO).toList();
      expect(infoLogs.any((r) => r.message.contains('Starting MusicXML parsing')), isTrue);
      expect(infoLogs.any((r) => r.message.contains('Found score-partwise format')), isTrue);
      expect(infoLogs.any((r) => r.message.contains('Parsing 1 parts')), isTrue);
      expect(infoLogs.any((r) => r.message.contains('parsing completed')), isTrue);
    });

    test('logs debug information when enabled', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
    </measure>
  </part>
</score-partwise>''';

      final parser = MusicXmlParser(
        loggingConfig: const LoggingConfig.debug(),
      );
      
      parser.parse(xml);
      
      // Should have fine/debug logs when debug is enabled
      final debugLogs = logRecords.where((r) => 
        r.level == Level.FINE || r.level == Level.FINER).toList();
      expect(debugLogs.any((r) => r.message.contains('Parsing XML document')), isTrue);
      expect(debugLogs.any((r) => r.message.contains('XML document parsed successfully')), isTrue);
      expect(debugLogs.any((r) => r.message.contains('Parsing score-partwise element')), isTrue);
    });

    test('does not log debug information when disabled', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
    </measure>
  </part>
</score-partwise>''';

      // Clear logs from setup
      logRecords.clear();
      
      final parser = MusicXmlParser(
        loggingConfig: const LoggingConfig.production(),
      );
      
      parser.parse(xml);
      
      // Should not have debug logs when debug is disabled
      final debugLogs = logRecords.where((r) => 
        r.level == Level.FINE || r.level == Level.FINER).toList();
      expect(debugLogs, isEmpty);
    });

    test('logs exceptions with context', () {
      const invalidXml = '''<?xml version="1.0" encoding="UTF-8"?>
<invalid-root>
</invalid-root>''';

      final parser = MusicXmlParser(
        loggingConfig: const LoggingConfig.debug(),
      );
      
      expect(
        () => parser.parse(invalidXml),
        throwsA(isA<MusicXmlStructureException>()),
      );
      
      // Should have error logs for the exception
      final errorLogs = logRecords.where((r) => r.level == Level.SEVERE).toList();
      expect(errorLogs, isNotEmpty);
      expect(errorLogs.any((r) => r.message.contains('Invalid MusicXML root element')), isTrue);
    });

    test('logs performance information when enabled', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
    </measure>
  </part>
</score-partwise>''';

      final parser = MusicXmlParser(
        loggingConfig: const LoggingConfig.debug(),
      );
      
      parser.parse(xml);
      
      // Should have performance logs when enabled
      final perfLogs = logRecords.where((r) => 
        r.message.contains('parsing completed in') && r.message.contains('ms')).toList();
      expect(perfLogs, isNotEmpty);
    });

    test('silent logging produces no output', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
    </measure>
  </part>
</score-partwise>''';

      // Clear previous logs
      logRecords.clear();
      
      // Setup silent logging and separate capture
      final silentLogRecords = <LogRecord>[];
      Logger.root.level = Level.OFF;
      Logger.root.clearListeners();
      Logger.root.onRecord.listen(silentLogRecords.add);

      final parser = MusicXmlParser(
        loggingConfig: const LoggingConfig.silent(),
      );
      
      parser.parse(xml);
      
      // Should have no logs when silent
      expect(silentLogRecords, isEmpty);
      
      // Restore logging for other tests
      Logger.root.level = Level.ALL;
      Logger.root.clearListeners();
      Logger.root.onRecord.listen(logRecords.add);
    });

    test('logs file parsing', () async {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
    </measure>
  </part>
</score-partwise>''';

      // Create a temporary file
      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/test.xml');
      await tempFile.writeAsString(xml);

      try {
        final parser = MusicXmlParser(
          loggingConfig: const LoggingConfig.debug(),
        );
        
        await parser.parseFromFile(tempFile.path);
        
        // Should have logs for file parsing
        final fileLogs = logRecords.where((r) => 
          r.message.contains('Starting to parse MusicXML file')).toList();
        expect(fileLogs, isNotEmpty);
        expect(fileLogs.first.message, contains(tempFile.path));
        
      } finally {
        // Clean up
        await tempFile.delete();
        await tempDir.delete();
      }
    });

    test('logs file errors with context', () async {
      final parser = MusicXmlParser(
        loggingConfig: const LoggingConfig.debug(),
      );
      
      await expectLater(
        () => parser.parseFromFile('/nonexistent/file.xml'),
        throwsA(isA<MusicXmlParseException>()),
      );
      
      // Should have error logs for file error
      final errorLogs = logRecords.where((r) => r.level == Level.SEVERE).toList();
      expect(errorLogs.any((r) => r.message.contains('Failed to read MusicXML file')), isTrue);
    });
  });
}