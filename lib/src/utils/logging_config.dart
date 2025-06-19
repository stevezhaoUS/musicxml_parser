import 'dart:developer' as dev;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

/// Configuration for logging in the MusicXML parser.
///
/// This class provides a centralized way to configure logging behavior
/// throughout the parser, including log levels, output formatting, and
/// enabling/disabling specific log categories.
@immutable
class LoggingConfig {
  /// The minimum log level to output.
  final Level logLevel;

  /// Whether to include stack traces in error logs.
  final bool includeStackTraces;

  /// Whether to enable debug logging for parsing steps.
  final bool enableDebugLogs;

  /// Whether to enable performance logging.
  final bool enablePerformanceLogs;

  /// Custom log formatter function.
  final String Function(LogRecord)? formatter;

  /// Creates a new [LoggingConfig].
  const LoggingConfig({
    this.logLevel = Level.INFO,
    this.includeStackTraces = true,
    this.enableDebugLogs = false,
    this.enablePerformanceLogs = false,
    this.formatter,
  });

  /// Creates a configuration for debug mode with verbose logging.
  const LoggingConfig.debug()
      : logLevel = Level.ALL,
        includeStackTraces = true,
        enableDebugLogs = true,
        enablePerformanceLogs = true,
        formatter = null;

  /// Creates a configuration for production mode with minimal logging.
  const LoggingConfig.production()
      : logLevel = Level.WARNING,
        includeStackTraces = false,
        enableDebugLogs = false,
        enablePerformanceLogs = false,
        formatter = null;

  /// Creates a configuration with no logging output.
  const LoggingConfig.silent()
      : logLevel = Level.OFF,
        includeStackTraces = false,
        enableDebugLogs = false,
        enablePerformanceLogs = false,
        formatter = null;

  /// Default formatter for log records.
  static String defaultFormatter(LogRecord record) {
    final buffer = StringBuffer();
    
    // Add timestamp
    buffer.write('${record.time.toIso8601String()} ');
    
    // Add level with padding
    buffer.write('[${record.level.name.padRight(7)}] ');
    
    // Add logger name
    buffer.write('${record.loggerName}: ');
    
    // Add message
    buffer.write(record.message);
    
    // Add error and stack trace if available
    if (record.error != null) {
      buffer.write('\n  Error: ${record.error}');
    }
    
    if (record.stackTrace != null) {
      buffer.write('\n  Stack trace:\n${record.stackTrace}');
    }
    
    return buffer.toString();
  }

  /// Formats a log record for parsing context.
  static String formatParsingLog(
    Level level,
    String message, {
    String? element,
    int? line,
    Map<String, dynamic>? context,
    Object? error,
  }) {
    final buffer = StringBuffer();
    buffer.write(message);
    
    if (element != null) {
      buffer.write(' (element: $element');
      if (line != null) {
        buffer.write(', line: $line');
      }
      buffer.write(')');
    } else if (line != null) {
      buffer.write(' (line: $line)');
    }
    
    if (context != null && context.isNotEmpty) {
      buffer.write(' [context: $context]');
    }
    
    if (error != null) {
      buffer.write('\n  Error: $error');
    }
    
    return buffer.toString();
  }
}

/// Utility class for setting up and managing logging in the MusicXML parser.
class LoggingUtils {
  /// Sets up logging with the given configuration.
  ///
  /// This should be called once at the start of the application to configure
  /// the logging system according to the provided [config].
  /// 
  /// [clearExistingListeners] - Whether to clear existing listeners. 
  /// Set to false in tests to preserve test listeners.
  static void setupLogging(LoggingConfig config, {bool clearExistingListeners = true}) {
    // Set the root logger level
    Logger.root.level = config.logLevel;
    
    // Clear any existing listeners only if requested
    if (clearExistingListeners) {
      Logger.root.clearListeners();
    }
    
    // Add a listener only if logging is not disabled
    if (config.logLevel != Level.OFF) {
      Logger.root.onRecord.listen((record) {
        final formatter = config.formatter ?? LoggingConfig.defaultFormatter;
        final formattedMessage = formatter(record);
        
        // Use dart:developer log for better integration with debugging tools
        dev.log(
          formattedMessage,
          time: record.time,
          level: record.level.value,
          name: record.loggerName,
          error: record.error,
          stackTrace: record.stackTrace,
        );
      });
    }
  }

  /// Creates a logger for the given name with proper configuration.
  static Logger createLogger(String name) {
    return Logger(name);
  }

  /// Logs a parsing step with structured context.
  static void logParsingStep(
    Logger logger,
    Level level,
    String message, {
    String? element,
    int? line,
    Map<String, dynamic>? context,
    Object? error,
  }) {
    if (logger.isLoggable(level)) {
      final formattedMessage = LoggingConfig.formatParsingLog(
        level,
        message,
        element: element,
        line: line,
        context: context,
        error: error,
      );
      logger.log(level, formattedMessage, error);
    }
  }

  /// Logs an exception with full context and optional stack trace.
  static void logException(
    Logger logger,
    Object exception, {
    StackTrace? stackTrace,
    String? element,
    int? line,
    Map<String, dynamic>? context,
    String? additionalMessage,
  }) {
    final message = additionalMessage ?? 'Exception during parsing';
    
    final formattedMessage = LoggingConfig.formatParsingLog(
      Level.SEVERE,
      message,
      element: element,
      line: line,
      context: context,
      error: exception,
    );
    
    logger.severe(formattedMessage, exception, stackTrace);
  }
}