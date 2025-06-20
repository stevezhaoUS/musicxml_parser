import 'dart:io';
import 'package:test/test.dart';
import 'package:musicxml_parser/musicxml_parser.dart';

void main() {
  group('MusicXmlParser MXL Support', () {
    // Setup a consistent test file path
    const testFilePath = 'test_app/test_files/mxl_test.mxl';

    setUp(() {
      // Check if the test file exists before running any tests
      final file = File(testFilePath);
      if (!file.existsSync()) {
        fail('Test MXL file not found. Please ensure $testFilePath exists.');
      }
    });

    test('parseData can detect and parse compressed MXL data', () {
      final file = File(testFilePath);
      final data = file.readAsBytesSync();
      final parser = MusicXmlParser();

      // Parse the MXL data
      final score = parser.parseData(data);

      // Verify the score was parsed correctly
      expect(score, isNotNull);
      expect(score.parts, isNotEmpty);
    });

    test('parseMxlBytes can parse ByteData MXL', () {
      final file = File(testFilePath);
      final data = file.readAsBytesSync();
      final byteData = data.buffer.asByteData();
      final parser = MusicXmlParser();

      final score = parser.parseMxlBytes(byteData);

      expect(score, isNotNull);
      expect(score.parts, isNotEmpty);
    });

    test('parseFile can parse MXL files', () async {
      final parser = MusicXmlParser();

      // Parse the MXL file
      final score = await parser.parseFile(testFilePath);

      // Verify the score was parsed correctly
      expect(score, isNotNull);
      expect(score.parts, isNotEmpty);
    });

    test('parseFileSync can parse MXL files', () {
      final parser = MusicXmlParser();

      // Parse the MXL file
      final score = parser.parseFileSync(testFilePath);

      // Verify the score was parsed correctly
      expect(score, isNotNull);
      expect(score.parts, isNotEmpty);
    });
  });
}
