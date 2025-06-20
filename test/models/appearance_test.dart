import 'package:musicxml_parser/src/models/appearance.dart';
import 'package:musicxml_parser/src/models/line_width.dart';
import 'package:musicxml_parser/src/models/note_size.dart';
import 'package:test/test.dart';

void main() {
  group('Appearance', () {
    test('default constructor creates empty lists', () {
      const appearance = Appearance();
      expect(appearance.lineWidths, isEmpty);
      expect(appearance.noteSizes, isEmpty);
    });

    test('constructor sets properties correctly', () {
      const lineWidths = [
        LineWidth(type: 'staff', value: 1.1),
        LineWidth(type: 'stem', value: 1.0),
      ];
      const noteSizes = [
        NoteSize(type: 'cue', value: 70.0),
        NoteSize(type: 'grace', value: 70.0),
      ];
      
      const appearance = Appearance(
        lineWidths: lineWidths,
        noteSizes: noteSizes,
      );
      
      expect(appearance.lineWidths, equals(lineWidths));
      expect(appearance.noteSizes, equals(noteSizes));
    });

    test('equals works correctly', () {
      const lineWidths = [LineWidth(type: 'staff', value: 1.1)];
      const noteSizes = [NoteSize(type: 'cue', value: 70.0)];
      
      const appearance1 = Appearance(
        lineWidths: lineWidths,
        noteSizes: noteSizes,
      );
      const appearance2 = Appearance(
        lineWidths: lineWidths,
        noteSizes: noteSizes,
      );
      const appearance3 = Appearance(
        lineWidths: [LineWidth(type: 'beam', value: 5.0)],
        noteSizes: noteSizes,
      );

      expect(appearance1, equals(appearance2));
      expect(appearance1, isNot(equals(appearance3)));
    });

    test('equals handles empty lists correctly', () {
      const appearance1 = Appearance();
      const appearance2 = Appearance();
      const appearance3 = Appearance(
        lineWidths: [LineWidth(type: 'staff', value: 1.1)],
      );

      expect(appearance1, equals(appearance2));
      expect(appearance1, isNot(equals(appearance3)));
    });

    test('toString returns correct string representation', () {
      const appearance = Appearance(
        lineWidths: [
          LineWidth(type: 'staff', value: 1.1),
          LineWidth(type: 'stem', value: 1.0),
        ],
        noteSizes: [
          NoteSize(type: 'cue', value: 70.0),
        ],
      );
      expect(appearance.toString(), equals('Appearance{lineWidths: 2, noteSizes: 1}'));
    });

    test('hashCode is consistent', () {
      const lineWidths = [LineWidth(type: 'staff', value: 1.1)];
      const noteSizes = [NoteSize(type: 'cue', value: 70.0)];
      
      const appearance1 = Appearance(
        lineWidths: lineWidths,
        noteSizes: noteSizes,
      );
      const appearance2 = Appearance(
        lineWidths: lineWidths,
        noteSizes: noteSizes,
      );
      expect(appearance1.hashCode, equals(appearance2.hashCode));
    });

    test('handles lists with different orders correctly', () {
      const appearance1 = Appearance(
        lineWidths: [
          LineWidth(type: 'staff', value: 1.1),
          LineWidth(type: 'stem', value: 1.0),
        ],
      );
      const appearance2 = Appearance(
        lineWidths: [
          LineWidth(type: 'stem', value: 1.0),
          LineWidth(type: 'staff', value: 1.1),
        ],
      );

      // Different order should not be equal
      expect(appearance1, isNot(equals(appearance2)));
    });
  });
}