/// Represents a warning that occurred during MusicXML parsing.
///
/// Warnings are non-critical issues that don't prevent parsing but
/// may indicate potential problems or unusual patterns in the MusicXML.
class MusicXmlWarning {
  /// The warning message.
  final String message;

  /// The category of warning.
  final String category;

  /// The line number where the warning occurred, if available.
  final int? line;

  /// The XML element where the warning occurred, if available.
  final String? element;

  /// Additional context information.
  final Map<String, dynamic>? context;

  /// The severity level of the warning.
  final WarningSeverity severity;

  /// An optional rule identifier associated with this warning.
  final String? rule;

  /// Creates a new [MusicXmlWarning].
  const MusicXmlWarning({
    required this.message,
    required this.category,
    this.line,
    this.element,
    this.context,
    this.severity = WarningSeverity.info,
    this.rule,
  });

  @override
  String toString() {
    final buffer = StringBuffer(
        'WARNING [${severity.name.toUpperCase()}] $category: $message');

    if (element != null) {
      buffer.write(' (element: $element');
      if (line != null) {
        buffer.write(', line: $line');
      }
      buffer.write(')');
    } else if (line != null) {
      buffer.write(' (line: $line)');
    }

    if (context != null && context!.isNotEmpty) {
      buffer.write(' [context: $context]');
    }

    if (rule != null) {
      buffer.write(' [rule: $rule]');
    }

    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicXmlWarning &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          category == other.category &&
          line == other.line &&
          element == other.element &&
          severity == other.severity &&
          rule == other.rule;

  @override
  int get hashCode =>
      message.hashCode ^
      category.hashCode ^
      (line?.hashCode ?? 0) ^
      (element?.hashCode ?? 0) ^
      severity.hashCode ^
      (rule?.hashCode ?? 0);
}

/// Severity levels for warnings.
enum WarningSeverity {
  /// Informational warnings.
  info,

  /// Minor issues that might affect interpretation.
  minor,

  /// Moderate issues that could cause problems.
  moderate,

  /// Serious issues that are likely to cause problems.
  serious,
}

/// System for collecting and managing warnings during MusicXML parsing.
///
/// The warning system allows the parser to report non-critical issues
/// without stopping the parsing process. This is useful for identifying
/// potential problems or unusual patterns in MusicXML files.
///
/// Example usage:
/// ```dart
/// final warningSystem = WarningSystem();
///
/// // Add a warning
/// warningSystem.addWarning(
///   'Unusual time signature found',
///   category: 'time_signature',
///   line: 42,
///   element: 'time',
///   severity: WarningSeverity.minor,
/// );
///
/// // Get all warnings
/// final warnings = warningSystem.getWarnings();
///
/// // Get warnings by category
/// final timeWarnings = warningSystem.getWarningsByCategory('time_signature');
/// ```
class WarningSystem {
  final List<MusicXmlWarning> _warnings = [];

  /// The maximum number of warnings to collect.
  /// If exceeded, older warnings will be discarded.
  final int maxWarnings;

  /// Whether to collect warnings or ignore them.
  bool enabled;

  /// Creates a new [WarningSystem].
  ///
  /// [maxWarnings] - Maximum number of warnings to store (default: 1000)
  /// [enabled] - Whether warnings are collected (default: true)
  WarningSystem({
    this.maxWarnings = 1000,
    this.enabled = true,
  });

  /// Adds a warning to the system.
  ///
  /// If warnings are disabled or the maximum number of warnings has been
  /// reached, the warning may be ignored or older warnings may be discarded.
  void addWarning(
    String message, {
    required String category,
    int? line,
    String? element,
    Map<String, dynamic>? context,
    WarningSeverity severity = WarningSeverity.info,
    String? rule, // New parameter for rule
  }) {
    if (!enabled) return;

    final warning = MusicXmlWarning(
      message: message,
      category: category,
      line: line,
      element: element,
      context: context,
      severity: severity,
      rule: rule, // Pass rule to MusicXmlWarning
    );

    _warnings.add(warning);

    // Remove oldest warnings if we've exceeded the limit
    while (_warnings.length > maxWarnings) {
      _warnings.removeAt(0);
    }
  }

  /// Gets all warnings collected so far.
  List<MusicXmlWarning> getWarnings() => List.unmodifiable(_warnings);

  /// Gets warnings filtered by category.
  List<MusicXmlWarning> getWarningsByCategory(String category) =>
      _warnings.where((w) => w.category == category).toList();

  /// Gets warnings filtered by severity level.
  List<MusicXmlWarning> getWarningsBySeverity(WarningSeverity severity) =>
      _warnings.where((w) => w.severity == severity).toList();

  /// Gets warnings filtered by minimum severity level.
  ///
  /// For example, calling with [WarningSeverity.moderate] will return
  /// warnings with moderate or serious severity.
  List<MusicXmlWarning> getWarningsByMinSeverity(WarningSeverity minSeverity) {
    final minIndex = WarningSeverity.values.indexOf(minSeverity);
    return _warnings.where((w) {
      final warningIndex = WarningSeverity.values.indexOf(w.severity);
      return warningIndex >= minIndex;
    }).toList();
  }

  /// Gets the number of warnings collected.
  int get warningCount => _warnings.length;

  /// Gets the number of warnings by category.
  Map<String, int> getWarningCountsByCategory() {
    final counts = <String, int>{};
    for (final warning in _warnings) {
      counts[warning.category] = (counts[warning.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Gets the number of warnings by severity.
  Map<WarningSeverity, int> getWarningCountsBySeverity() {
    final counts = <WarningSeverity, int>{};
    for (final warning in _warnings) {
      counts[warning.severity] = (counts[warning.severity] ?? 0) + 1;
    }
    return counts;
  }

  /// Clears all warnings.
  void clearWarnings() => _warnings.clear();

  /// Checks if there are any warnings.
  bool get hasWarnings => _warnings.isNotEmpty;

  /// Checks if there are any warnings of the specified severity or higher.
  bool hasWarningsWithMinSeverity(WarningSeverity minSeverity) {
    final minIndex = WarningSeverity.values.indexOf(minSeverity);
    return _warnings.any((w) {
      final warningIndex = WarningSeverity.values.indexOf(w.severity);
      return warningIndex >= minIndex;
    });
  }

  /// Creates a summary string of all warnings.
  String createSummary() {
    if (_warnings.isEmpty) {
      return 'No warnings';
    }

    final buffer = StringBuffer();
    buffer.writeln('Warning Summary:');
    buffer.writeln('Total warnings: ${_warnings.length}');

    final categoryCount = getWarningCountsByCategory();
    if (categoryCount.isNotEmpty) {
      buffer.writeln('\nBy category:');
      for (final entry in categoryCount.entries) {
        buffer.writeln('  ${entry.key}: ${entry.value}');
      }
    }

    final severityCount = getWarningCountsBySeverity();
    if (severityCount.isNotEmpty) {
      buffer.writeln('\nBy severity:');
      for (final entry in severityCount.entries) {
        buffer.writeln('  ${entry.key.name}: ${entry.value}');
      }
    }

    return buffer.toString().trim();
  }

  /// Prints all warnings to the console.
  void printWarnings() {
    if (_warnings.isEmpty) {
      print('No warnings');
      return;
    }

    print('Warnings (${_warnings.length}):');
    for (int i = 0; i < _warnings.length; i++) {
      print('${i + 1}. ${_warnings[i]}');
    }
  }

  /// Common warning categories used throughout the parser.
  static const String parsing = 'parsing';
  static const String structure = 'structure';
  static const String validation = 'validation';
  static const String pitch = 'pitch';
  static const String duration = 'duration';
  static const String timeSignature = 'time_signature';
  static const String keySignature = 'key_signature';
  static const String measure = 'measure';
  static const String voice = 'voice';
  static const String tie = 'tie';
  static const String notation = 'notation';
  static const String performance = 'performance';
  static const String compatibility = 'compatibility';
}

/// Common warning categories used throughout the parser.
class WarningCategories {
  static const String parsing = 'parsing';
  static const String structure = 'structure';
  static const String validation = 'validation';
  static const String pitch = 'pitch';
  static const String duration = 'duration';
  static const String timeSignature = 'time_signature';
  static const String keySignature = 'key_signature';
  static const String measure = 'measure';
  static const String voice = 'voice';
  static const String tie = 'tie';
  static const String notation = 'notation';
  static const String performance = 'performance';
  static const String compatibility = 'compatibility';
  static const String noteDivisions = 'note_divisions';
}
