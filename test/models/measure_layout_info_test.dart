import 'package:musicxml_parser/src/models/measure_layout_info.dart';
import 'package:test/test.dart';

void main() {
  group('MeasureLayoutInfo Models', () {
    group('MeasureLayout', () {
      test('constructor sets properties correctly', () {
        const layout1 = MeasureLayout(measureDistance: 10.0);
        expect(layout1.measureDistance, 10.0);

        const layout2 = MeasureLayout();
        expect(layout2.measureDistance, isNull);
      });
      test('equality', () {
        const layout1 = MeasureLayout(measureDistance: 20.0);
        const layout2 = MeasureLayout(measureDistance: 20.0);
        const layout3 = MeasureLayout(measureDistance: 30.0);
        const layout4 = MeasureLayout();

        expect(layout1, equals(layout2));
        expect(layout1, isNot(equals(layout3)));
        expect(layout1, isNot(equals(layout4)));
        expect(MeasureLayout(), equals(MeasureLayout()));
      });
    });

    group('MeasureNumbering', () {
      test('constructor sets properties correctly and parses value', () {
        const numbering = MeasureNumbering(
          value: MeasureNumberingValue.system,
          color: '#123456',
          defaultX: 5.0,
          defaultY: -5.0,
          fontFamily: 'Arial',
          fontSize: '10pt',
          fontStyle: 'italic',
          fontWeight: 'bold',
          halign: 'center',
          multipleRestAlways: true,
          multipleRestRange: false,
          relativeX: 1.0,
          relativeY: 2.0,
          staff: 2,
          system: 'other',
          valign: 'top',
        );
        expect(numbering.value, MeasureNumberingValue.system);
        expect(numbering.color, '#123456');
        // ... add expects for all properties
        expect(numbering.valign, 'top');
      });

      test('parseValue works correctly', () {
        expect(MeasureNumbering.parseValue('none'), MeasureNumberingValue.none);
        expect(MeasureNumbering.parseValue('measure'),
            MeasureNumberingValue.measure);
        expect(MeasureNumbering.parseValue('system'),
            MeasureNumberingValue.system);
        expect(MeasureNumbering.parseValue('invalid'),
            MeasureNumberingValue.measure); // Default
        expect(MeasureNumbering.parseValue(null),
            MeasureNumberingValue.measure); // Default
      });

      test('equality', () {
        const n1 =
            MeasureNumbering(value: MeasureNumberingValue.measure, staff: 1);
        const n2 =
            MeasureNumbering(value: MeasureNumberingValue.measure, staff: 1);
        const n3 =
            MeasureNumbering(value: MeasureNumberingValue.none, staff: 1);
        const n4 =
            MeasureNumbering(value: MeasureNumberingValue.measure, staff: 2);
        expect(n1, equals(n2));
        expect(n1, isNot(equals(n3)));
        expect(n1, isNot(equals(n4)));
      });
    });
  });
}
