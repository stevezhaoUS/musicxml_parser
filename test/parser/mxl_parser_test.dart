import 'dart:io';
import 'package:test/test.dart';
import 'package:musicxml_parser/musicxml_parser.dart';

void main() {
  group('MusicXmlParser MXL Support', () {
    test('parseData can detect and parse compressed MXL data', () async {
      // Load a test MXL file
      final file = File('test_app/test_files/mxl_test.mxl');
      if (!file.existsSync()) {
        fail(
            'Test MXL file not found. Please ensure test_app/test_files/mxl_test.mxl exists.');
      }

      final data = file.readAsBytesSync();
      final parser = MusicXmlParser();

      // Parse the MXL data
      final score = parser.parseData(data);

      // Verify the score was parsed correctly
      expect(score, isNotNull);
      expect(score.parts, isNotEmpty);
    });

    test('parseFile can parse MXL files', () async {
      // Load a test MXL file
      final filePath = 'test_app/test_files/mxl_test.mxl';
      final file = File(filePath);
      if (!file.existsSync()) {
        fail(
            'Test MXL file not found. Please ensure test_app/test_files/mxl_test.mxl exists.');
      }

      final parser = MusicXmlParser();

      // Parse the MXL file
      final score = await parser.parseFile(filePath);

      // Verify the score was parsed correctly
      expect(score, isNotNull);
      expect(score.parts, isNotEmpty);
    });

    test('parseFileSync can parse MXL files', () {
      // Load a test MXL file
      final filePath = 'test_app/test_files/mxl_test.mxl';
      final file = File(filePath);
      if (!file.existsSync()) {
        fail(
            'Test MXL file not found. Please ensure test_app/test_files/mxl_test.mxl exists.');
      }

      final parser = MusicXmlParser();

      // Parse the MXL file
      final score = parser.parseFileSync(filePath);

      // Verify the score was parsed correctly
      expect(score, isNotNull);
      expect(score.parts, isNotEmpty);
    });
  });
}
