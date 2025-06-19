import 'package:test/test.dart';
import 'package:musicxml_parser/src/utils/warning_system.dart';

void main() {
  group('MusicXmlWarning', () {
    test('creates warning with required fields', () {
      final warning = MusicXmlWarning(
        message: 'Test warning',
        category: 'test',
      );

      expect(warning.message, equals('Test warning'));
      expect(warning.category, equals('test'));
      expect(warning.severity, equals(WarningSeverity.info));
      expect(warning.line, isNull);
      expect(warning.element, isNull);
      expect(warning.context, isNull);
    });

    test('creates warning with all fields', () {
      final context = {'key': 'value'};
      final warning = MusicXmlWarning(
        message: 'Test warning',
        category: 'test',
        line: 42,
        element: 'note',
        context: context,
        severity: WarningSeverity.serious,
      );

      expect(warning.message, equals('Test warning'));
      expect(warning.category, equals('test'));
      expect(warning.line, equals(42));
      expect(warning.element, equals('note'));
      expect(warning.context, equals(context));
      expect(warning.severity, equals(WarningSeverity.serious));
    });

    test('toString with minimal fields', () {
      final warning = MusicXmlWarning(
        message: 'Test warning',
        category: 'test',
      );

      expect(warning.toString(), equals('WARNING [INFO] test: Test warning'));
    });

    test('toString with element and line', () {
      final warning = MusicXmlWarning(
        message: 'Test warning',
        category: 'test',
        line: 42,
        element: 'note',
      );

      expect(warning.toString(), contains('WARNING [INFO] test: Test warning'));
      expect(warning.toString(), contains('(element: note, line: 42)'));
    });

    test('toString with context', () {
      final warning = MusicXmlWarning(
        message: 'Test warning',
        category: 'test',
        context: {'key': 'value'},
      );

      expect(warning.toString(), contains('WARNING [INFO] test: Test warning'));
      expect(warning.toString(), contains('[context: {key: value}]'));
    });

    test('toString with serious severity', () {
      final warning = MusicXmlWarning(
        message: 'Test warning',
        category: 'test',
        severity: WarningSeverity.serious,
      );

      expect(
          warning.toString(), contains('WARNING [SERIOUS] test: Test warning'));
    });

    test('equality based on content', () {
      final warning1 = MusicXmlWarning(
        message: 'Test warning',
        category: 'test',
        line: 42,
      );

      final warning2 = MusicXmlWarning(
        message: 'Test warning',
        category: 'test',
        line: 42,
      );

      final warning3 = MusicXmlWarning(
        message: 'Different warning',
        category: 'test',
        line: 42,
      );

      expect(warning1, equals(warning2));
      expect(warning1, isNot(equals(warning3)));
    });
  });

  group('WarningSeverity', () {
    test('has expected values', () {
      expect(WarningSeverity.values, hasLength(4));
      expect(WarningSeverity.values, contains(WarningSeverity.info));
      expect(WarningSeverity.values, contains(WarningSeverity.minor));
      expect(WarningSeverity.values, contains(WarningSeverity.moderate));
      expect(WarningSeverity.values, contains(WarningSeverity.serious));
    });
  });

  group('WarningSystem', () {
    late WarningSystem warningSystem;

    setUp(() {
      warningSystem = WarningSystem();
    });

    test('starts empty', () {
      expect(warningSystem.hasWarnings, isFalse);
      expect(warningSystem.warningCount, equals(0));
      expect(warningSystem.getWarnings(), isEmpty);
    });

    test('adds warning successfully', () {
      warningSystem.addWarning(
        'Test warning',
        category: 'test',
      );

      expect(warningSystem.hasWarnings, isTrue);
      expect(warningSystem.warningCount, equals(1));

      final warnings = warningSystem.getWarnings();
      expect(warnings, hasLength(1));
      expect(warnings.first.message, equals('Test warning'));
      expect(warnings.first.category, equals('test'));
    });

    test('adds warning with all fields', () {
      final context = {'key': 'value'};
      warningSystem.addWarning(
        'Test warning',
        category: 'test',
        line: 42,
        element: 'note',
        context: context,
        severity: WarningSeverity.serious,
      );

      final warnings = warningSystem.getWarnings();
      expect(warnings, hasLength(1));

      final warning = warnings.first;
      expect(warning.message, equals('Test warning'));
      expect(warning.category, equals('test'));
      expect(warning.line, equals(42));
      expect(warning.element, equals('note'));
      expect(warning.context, equals(context));
      expect(warning.severity, equals(WarningSeverity.serious));
    });

    test('does not add warnings when disabled', () {
      warningSystem.enabled = false;

      warningSystem.addWarning('Test warning', category: 'test');

      expect(warningSystem.hasWarnings, isFalse);
      expect(warningSystem.warningCount, equals(0));
    });

    test('filters warnings by category', () {
      warningSystem.addWarning('Warning 1', category: 'parsing');
      warningSystem.addWarning('Warning 2', category: 'validation');
      warningSystem.addWarning('Warning 3', category: 'parsing');

      final parsingWarnings = warningSystem.getWarningsByCategory('parsing');
      expect(parsingWarnings, hasLength(2));
      expect(parsingWarnings.every((w) => w.category == 'parsing'), isTrue);

      final validationWarnings =
          warningSystem.getWarningsByCategory('validation');
      expect(validationWarnings, hasLength(1));
      expect(validationWarnings.first.category, equals('validation'));
    });

    test('filters warnings by severity', () {
      warningSystem.addWarning('Info warning',
          category: 'test', severity: WarningSeverity.info);
      warningSystem.addWarning('Minor warning',
          category: 'test', severity: WarningSeverity.minor);
      warningSystem.addWarning('Serious warning',
          category: 'test', severity: WarningSeverity.serious);

      final infoWarnings =
          warningSystem.getWarningsBySeverity(WarningSeverity.info);
      expect(infoWarnings, hasLength(1));
      expect(infoWarnings.first.severity, equals(WarningSeverity.info));

      final seriousWarnings =
          warningSystem.getWarningsBySeverity(WarningSeverity.serious);
      expect(seriousWarnings, hasLength(1));
      expect(seriousWarnings.first.severity, equals(WarningSeverity.serious));
    });

    test('filters warnings by minimum severity', () {
      warningSystem.addWarning('Info warning',
          category: 'test', severity: WarningSeverity.info);
      warningSystem.addWarning('Minor warning',
          category: 'test', severity: WarningSeverity.minor);
      warningSystem.addWarning('Moderate warning',
          category: 'test', severity: WarningSeverity.moderate);
      warningSystem.addWarning('Serious warning',
          category: 'test', severity: WarningSeverity.serious);

      final moderateAndUp =
          warningSystem.getWarningsByMinSeverity(WarningSeverity.moderate);
      expect(moderateAndUp, hasLength(2));
      expect(moderateAndUp.any((w) => w.severity == WarningSeverity.moderate),
          isTrue);
      expect(moderateAndUp.any((w) => w.severity == WarningSeverity.serious),
          isTrue);
    });

    test('respects maximum warning limit', () {
      final smallSystem = WarningSystem(maxWarnings: 3);

      smallSystem.addWarning('Warning 1', category: 'test');
      smallSystem.addWarning('Warning 2', category: 'test');
      smallSystem.addWarning('Warning 3', category: 'test');
      smallSystem.addWarning('Warning 4', category: 'test');
      smallSystem.addWarning('Warning 5', category: 'test');

      expect(smallSystem.warningCount, equals(3));

      final warnings = smallSystem.getWarnings();
      expect(warnings.map((w) => w.message),
          containsAll(['Warning 3', 'Warning 4', 'Warning 5']));
      expect(warnings.map((w) => w.message), isNot(contains('Warning 1')));
    });

    test('counts warnings by category', () {
      warningSystem.addWarning('Warning 1', category: 'parsing');
      warningSystem.addWarning('Warning 2', category: 'validation');
      warningSystem.addWarning('Warning 3', category: 'parsing');
      warningSystem.addWarning('Warning 4', category: 'structure');

      final counts = warningSystem.getWarningCountsByCategory();
      expect(counts['parsing'], equals(2));
      expect(counts['validation'], equals(1));
      expect(counts['structure'], equals(1));
    });

    test('counts warnings by severity', () {
      warningSystem.addWarning('Warning 1',
          category: 'test', severity: WarningSeverity.info);
      warningSystem.addWarning('Warning 2',
          category: 'test', severity: WarningSeverity.serious);
      warningSystem.addWarning('Warning 3',
          category: 'test', severity: WarningSeverity.info);

      final counts = warningSystem.getWarningCountsBySeverity();
      expect(counts[WarningSeverity.info], equals(2));
      expect(counts[WarningSeverity.serious], equals(1));
    });

    test('clears all warnings', () {
      warningSystem.addWarning('Warning 1', category: 'test');
      warningSystem.addWarning('Warning 2', category: 'test');

      expect(warningSystem.hasWarnings, isTrue);

      warningSystem.clear();

      expect(warningSystem.hasWarnings, isFalse);
      expect(warningSystem.warningCount, equals(0));
    });

    test('checks for warnings with minimum severity', () {
      warningSystem.addWarning('Info warning',
          category: 'test', severity: WarningSeverity.info);
      warningSystem.addWarning('Minor warning',
          category: 'test', severity: WarningSeverity.minor);

      expect(warningSystem.hasWarningsWithMinSeverity(WarningSeverity.info),
          isTrue);
      expect(warningSystem.hasWarningsWithMinSeverity(WarningSeverity.minor),
          isTrue);
      expect(warningSystem.hasWarningsWithMinSeverity(WarningSeverity.moderate),
          isFalse);
      expect(warningSystem.hasWarningsWithMinSeverity(WarningSeverity.serious),
          isFalse);
    });

    test('creates summary', () {
      warningSystem.addWarning('Warning 1',
          category: 'parsing', severity: WarningSeverity.info);
      warningSystem.addWarning('Warning 2',
          category: 'validation', severity: WarningSeverity.serious);
      warningSystem.addWarning('Warning 3',
          category: 'parsing', severity: WarningSeverity.minor);

      final summary = warningSystem.createSummary();

      expect(summary, contains('Total warnings: 3'));
      expect(summary, contains('parsing: 2'));
      expect(summary, contains('validation: 1'));
      expect(summary, contains('info: 1'));
      expect(summary, contains('serious: 1'));
      expect(summary, contains('minor: 1'));
    });

    test('creates empty summary', () {
      final summary = warningSystem.createSummary();

      expect(summary, equals('No warnings'));
    });
  });

  group('WarningCategories', () {
    test('has expected constants', () {
      expect(WarningCategories.parsing, equals('parsing'));
      expect(WarningCategories.structure, equals('structure'));
      expect(WarningCategories.validation, equals('validation'));
      expect(WarningCategories.pitch, equals('pitch'));
      expect(WarningCategories.duration, equals('duration'));
      expect(WarningCategories.timeSignature, equals('time_signature'));
      expect(WarningCategories.keySignature, equals('key_signature'));
      expect(WarningCategories.measure, equals('measure'));
      expect(WarningCategories.voice, equals('voice'));
      expect(WarningCategories.tie, equals('tie'));
      expect(WarningCategories.notation, equals('notation'));
      expect(WarningCategories.performance, equals('performance'));
      expect(WarningCategories.compatibility, equals('compatibility'));
    });
  });
}
