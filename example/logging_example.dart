import 'package:logging/logging.dart';
import 'package:musicxml_parser/musicxml_parser.dart';

void main() {
  // Example 1: Basic logging with default configuration
  print('=== Example 1: Default Logging ===');
  basicLoggingExample();

  print('\n=== Example 2: Debug Logging ===');
  debugLoggingExample();

  print('\n=== Example 3: Production Logging ===');
  productionLoggingExample();

  print('\n=== Example 4: Silent Logging ===');
  silentLoggingExample();

  print('\n=== Example 5: Custom Logging ===');
  customLoggingExample();
}

void basicLoggingExample() {
  // Default logging configuration (INFO level and above)
  final parser = MusicXmlParser();

  const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>480</duration>
        <type>quarter</type>
      </note>
    </measure>
  </part>
</score-partwise>''';

  try {
    final score = parser.parse(xml);
    print('Successfully parsed score with ${score.parts.length} parts');
  } catch (e) {
    print('Error: $e');
  }
}

void debugLoggingExample() {
  // Debug logging with detailed information
  final parser = MusicXmlParser(
    loggingConfig: const LoggingConfig.debug(),
  );

  const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
    </measure>
  </part>
</score-partwise>''';

  try {
    final score = parser.parse(xml);
    print('Successfully parsed score with ${score.parts.length} parts');
  } catch (e) {
    print('Error: $e');
  }
}

void productionLoggingExample() {
  // Production logging (WARNING level and above only)
  final parser = MusicXmlParser(
    loggingConfig: const LoggingConfig.production(),
  );

  const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
    </measure>
  </part>
</score-partwise>''';

  try {
    final score = parser.parse(xml);
    print('Successfully parsed score with ${score.parts.length} parts');
  } catch (e) {
    print('Error: $e');
  }
}

void silentLoggingExample() {
  // Silent logging (no output)
  final parser = MusicXmlParser(
    loggingConfig: const LoggingConfig.silent(),
  );

  const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
    </measure>
  </part>
</score-partwise>''';

  try {
    final score = parser.parse(xml);
    print('Successfully parsed score with ${score.parts.length} parts (no logs)');
  } catch (e) {
    print('Error: $e');
  }
}

void customLoggingExample() {
  // Custom logging configuration
  final parser = MusicXmlParser(
    loggingConfig: LoggingConfig(
      logLevel: Level.FINE,
      includeStackTraces: false,
      enableDebugLogs: true,
      enablePerformanceLogs: true,
      formatter: (record) => '${record.level.name}: ${record.message}',
    ),
  );

  const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise>
  <part id="P1">
    <measure number="1">
    </measure>
  </part>
</score-partwise>''';

  try {
    final score = parser.parse(xml);
    print('Successfully parsed score with ${score.parts.length} parts');
  } catch (e) {
    print('Error: $e');
  }
}