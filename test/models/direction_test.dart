import 'package:musicxml_parser/src/models/direction.dart';
import 'package:musicxml_parser/src/models/direction_type_elements.dart';
import 'package:musicxml_parser/src/models/direction_words.dart';
import 'package:test/test.dart';

void main() {
  group('Direction Models', () {
    group('Offset', () {
      test('constructor sets properties correctly', () {
        const offset = Offset(value: 10.5, sound: true);
        expect(offset.value, 10.5);
        expect(offset.sound, isTrue);
      });
      test('equality', () {
        const offset1 = Offset(value: 10.0, sound: false);
        const offset2 = Offset(value: 10.0, sound: false);
        const offset3 = Offset(value: 12.0, sound: false);
        const offset4 = Offset(value: 10.0, sound: true);
        expect(offset1, equals(offset2));
        expect(offset1, isNot(equals(offset3)));
        expect(offset1, isNot(equals(offset4)));
      });
    });

    group('Staff', () {
      test('constructor sets properties correctly', () {
        const staff = Staff(value: 2);
        expect(staff.value, 2);
      });
      test('equality', () {
        const staff1 = Staff(value: 1);
        const staff2 = Staff(value: 1);
        const staff3 = Staff(value: 2);
        expect(staff1, equals(staff2));
        expect(staff1, isNot(equals(staff3)));
      });
    });

    group('Sound', () {
      test('constructor sets properties correctly', () {
        const sound = Sound(
          tempo: 120.0,
          dynamics: 0.75,
          dacapo: true,
          segno: 'segno1',
          coda: 'coda1',
          fine: 'fine1',
          timeOnly: 'beats',
          pizzicato: true,
          pan: -50,
          elevation: 20,
          offset: Offset(value: 5.0),
        );
        expect(sound.tempo, 120.0);
        expect(sound.dynamics, 0.75);
        expect(sound.dacapo, isTrue);
        // ... add expects for all properties
        expect(sound.offset, const Offset(value: 5.0));
      });
      // Add equality tests
    });

    group('Direction', () {
      test('constructor sets properties correctly', () {
        const words = WordsDirection(text: 'Allegro');
        const offset = Offset(value: 0.0);
        const staff = Staff(value: 1);
        const sound = Sound(tempo: 100);
        const direction = Direction(
          directionTypes: [words],
          offset: offset,
          staff: staff,
          sound: sound,
          placement: 'above',
          directive: 'yes',
          system: 'other',
          id: 'dir1',
        );

        expect(direction.directionTypes, hasLength(1));
        expect(direction.directionTypes[0], isA<WordsDirection>());
        expect((direction.directionTypes[0] as WordsDirection).text, 'Allegro');
        expect(direction.offset, offset);
        expect(direction.staff, staff);
        expect(direction.sound, sound);
        expect(direction.placement, 'above');
        expect(direction.directive, 'yes');
        expect(direction.system, 'other');
        expect(direction.id, 'dir1');
      });
      // Add equality tests
      test('equality with lists and nested objects', () {
        const dir1 = Direction(
          directionTypes: [WordsDirection(text: 'Hi')],
          offset: Offset(value: 1.0),
          id: 'd1'
        );
        const dir2 = Direction(
          directionTypes: [WordsDirection(text: 'Hi')],
          offset: Offset(value: 1.0),
          id: 'd1'
        );
         const dir3 = Direction(
          directionTypes: [WordsDirection(text: 'Ho')],
          offset: Offset(value: 1.0),
          id: 'd1'
        );
        expect(dir1, equals(dir2));
        expect(dir1, isNot(equals(dir3)));

      });
    });
  });
}
