import 'package:musicxml_parser/src/models/note_size.dart';
import 'package:test/test.dart';

void main() {
  group('NoteSize', () {
    test('constructor sets properties correctly', () {
      const noteSize = NoteSize(type: 'cue', value: 70.0);
      expect(noteSize.type, equals('cue'));
      expect(noteSize.value, equals(70.0));
    });

    test('equals works correctly', () {
      const noteSize1 = NoteSize(type: 'cue', value: 70.0);
      const noteSize2 = NoteSize(type: 'cue', value: 70.0);
      const noteSize3 = NoteSize(type: 'grace', value: 70.0);

      expect(noteSize1, equals(noteSize2));
      expect(noteSize1, isNot(equals(noteSize3)));
    });

    test('toString returns correct string representation', () {
      const noteSize = NoteSize(type: 'grace-cue', value: 49.0);
      expect(noteSize.toString(), equals('NoteSize{type: grace-cue, value: 49.0}'));
    });

    test('hashCode is consistent', () {
      const noteSize1 = NoteSize(type: 'grace', value: 70.0);
      const noteSize2 = NoteSize(type: 'grace', value: 70.0);
      expect(noteSize1.hashCode, equals(noteSize2.hashCode));
    });

    test('supports common note size types', () {
      const cue = NoteSize(type: 'cue', value: 70.0);
      const grace = NoteSize(type: 'grace', value: 70.0);
      const graceCue = NoteSize(type: 'grace-cue', value: 49.0);

      expect(cue.type, equals('cue'));
      expect(grace.type, equals('grace'));
      expect(graceCue.type, equals('grace-cue'));
      expect(cue.value, equals(70.0));
      expect(grace.value, equals(70.0));
      expect(graceCue.value, equals(49.0));
    });
  });
}