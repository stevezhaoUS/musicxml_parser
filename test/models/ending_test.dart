import 'package:musicxml_parser/src/models/ending.dart'; // Adjust import as needed
import 'package:test/test.dart';

void main() {
  group('Ending Model', () {
    group('constructor and properties', () {
      test('creates instance with all properties', () {
        const ending = Ending(number: '1', type: 'start', printObject: 'no');
        expect(ending.number, '1');
        expect(ending.type, 'start');
        expect(ending.printObject, 'no');
      });

      test('printObject defaults to "yes" if not specified', () {
        const ending = Ending(number: '2', type: 'stop');
        expect(ending.number, '2');
        expect(ending.type, 'stop');
        expect(ending.printObject, 'yes'); // Default value
      });
    });

    group('equality and hashCode', () {
      const e1 = Ending(number: '1', type: 'start', printObject: 'yes');
      const e2 = Ending(number: '1', type: 'start', printObject: 'yes');
      const e3 = Ending(number: '2', type: 'start', printObject: 'yes'); // diff number
      const e4 = Ending(number: '1', type: 'stop', printObject: 'yes'); // diff type
      const e5 = Ending(number: '1', type: 'start', printObject: 'no'); // diff printObject

      // Test constructor default for printObject
      const e_default_po1 = Ending(number: '1', type: 'start');
      const e_default_po2 = Ending(number: '1', type: 'start');


      test('instances with same values are equal and have same hashCode', () {
        expect(e1, equals(e2));
        expect(e1.hashCode, equals(e2.hashCode));
      });

      test('instances using default printObject are equal',(){
        expect(e1, equals(e_default_po1));
        expect(e1.hashCode, equals(e_default_po1.hashCode));
        expect(e_default_po1, equals(e_default_po2));
        expect(e_default_po1.hashCode, equals(e_default_po2.hashCode));
      });

      test('instances with different number are not equal', () {
        expect(e1, isNot(equals(e3)));
      });

      test('instances with different type are not equal', () {
        expect(e1, isNot(equals(e4)));
      });

      test('instances with different printObject are not equal', () {
        expect(e1, isNot(equals(e5)));
      });
    });

    group('toString representation', () {
      test('includes all fields, printObject shown if not default', () {
        const ending1 = Ending(number: '1, 3', type: 'discontinue', printObject: 'no');
        expect(ending1.toString(), equals('Ending{number: 1, 3, type: discontinue, printObject: no}'));
      });

      test('omits printObject when it is default "yes"', () {
        const ending2 = Ending(number: '2', type: 'stop'); // printObject defaults to "yes"
        expect(ending2.toString(), equals('Ending{number: 2, type: stop}'));

        const ending3 = Ending(number: '2', type: 'stop', printObject: 'yes');
        expect(ending3.toString(), equals('Ending{number: 2, type: stop}'));
      });
    });
  });
}
