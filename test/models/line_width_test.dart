import 'package:musicxml_parser/src/models/line_width.dart';
import 'package:test/test.dart';

void main() {
  group('LineWidth', () {
    test('constructor sets properties correctly', () {
      const lineWidth = LineWidth(type: 'staff', value: 1.1);
      expect(lineWidth.type, equals('staff'));
      expect(lineWidth.value, equals(1.1));
    });

    test('equals works correctly', () {
      const lineWidth1 = LineWidth(type: 'staff', value: 1.1);
      const lineWidth2 = LineWidth(type: 'staff', value: 1.1);
      const lineWidth3 = LineWidth(type: 'beam', value: 5.0);

      expect(lineWidth1, equals(lineWidth2));
      expect(lineWidth1, isNot(equals(lineWidth3)));
    });

    test('toString returns correct string representation', () {
      const lineWidth = LineWidth(type: 'heavy barline', value: 5.5);
      expect(lineWidth.toString(), equals('LineWidth{type: heavy barline, value: 5.5}'));
    });

    test('hashCode is consistent', () {
      const lineWidth1 = LineWidth(type: 'stem', value: 1.0);
      const lineWidth2 = LineWidth(type: 'stem', value: 1.0);
      expect(lineWidth1.hashCode, equals(lineWidth2.hashCode));
    });

    test('supports common line width types', () {
      const lightBarline = LineWidth(type: 'light barline', value: 1.8);
      const heavyBarline = LineWidth(type: 'heavy barline', value: 5.5);
      const beam = LineWidth(type: 'beam', value: 5.0);
      const bracket = LineWidth(type: 'bracket', value: 4.5);
      const staff = LineWidth(type: 'staff', value: 1.1);
      const stem = LineWidth(type: 'stem', value: 1.0);

      expect(lightBarline.type, equals('light barline'));
      expect(heavyBarline.type, equals('heavy barline'));
      expect(beam.type, equals('beam'));
      expect(bracket.type, equals('bracket'));
      expect(staff.type, equals('staff'));
      expect(stem.type, equals('stem'));
    });
  });
}