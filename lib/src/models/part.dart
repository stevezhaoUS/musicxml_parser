import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/models/measure.dart';

/// Represents a single part (e.g., a single instrument or voice) within a musical score.
///
/// A part consists of a unique [id], an optional [name], and a list of [measures]
/// that make up the musical content of the part.
///
/// Instances are typically created via [PartBuilder].
/// Objects of this class are immutable.
@immutable
class Part {
  /// The unique identifier for this part within the score.
  final String id;

  /// The display name of the part (e.g., "Violin I", "Piano Left Hand").
  final String? name;

  /// The list of [Measure] objects that constitute this part.
  final List<Measure> measures;

  /// Creates a new [Part] instance.
  ///
  /// It is generally recommended to use [PartBuilder] for constructing [Part]
  /// objects, especially during parsing.
  const Part({
    required this.id,
    this.name,
    required this.measures,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Part &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          // Note: DeepCollectionEquality might be needed for measures if deep comparison is critical
          // For now, relying on list's default equality (identity or element-wise if elements override ==)
          measures == other.measures;

  @override
  int get hashCode => id.hashCode ^ (name?.hashCode ?? 0) ^ measures.hashCode;

  @override
  String toString() =>
      'Part{id: $id, name: $name, measures: ${measures.length}}';
}

/// Builder for creating [Part] objects incrementally.
///
/// This builder is useful during the parsing process for MusicXML `<part>` elements,
/// allowing measures to be added one by one as they are parsed.
/// The [build] method finalizes the part construction.
///
/// Example:
/// ```dart
/// final partBuilder = PartBuilder("P1", line: 20)..setName("Flute");
/// partBuilder.addMeasure(firstMeasure);
/// partBuilder.addMeasure(secondMeasure);
/// final Part flutePart = partBuilder.build();
/// ```
class PartBuilder {
  /// The ID of the part being built.
  final String _id;
  String? _name;
  List<Measure> _measures = [];

  /// Line number in the XML for error reporting context.
  final int? _line;

  /// Additional context for error reporting.
  final Map<String, dynamic>? _context;

  /// Creates a [PartBuilder] for a part with the given [id].
  ///
  /// [line] and [context] can be provided for more detailed error
  /// messages if validation (not currently implemented in builder) were to fail.
  PartBuilder(this._id, {int? line, Map<String, dynamic>? context})
      : _line = line,
        _context = context;

  /// Sets the name of the part.
  PartBuilder setName(String? name) {
    _name = name;
    return this;
  }

  /// Sets all measures for the part.
  PartBuilder setMeasures(List<Measure> measures) {
    _measures = measures;
    return this;
  }

  /// Adds a single [Measure] to the part.
  PartBuilder addMeasure(Measure measure) {
    _measures.add(measure);
    return this;
  }

  /// Builds the [Part] instance.
  ///
  /// This method constructs the [Part] object from the properties set
  /// on the builder. Currently, it performs minimal validation itself,
  /// relying on the parser to ensure required fields like ID are present.
  Part build() {
    if (_id.isEmpty) {
      // This should ideally be caught by the PartParser before even creating the builder
      // but serves as a safeguard or location for future builder-specific validation.
      throw ArgumentError('Part ID cannot be empty.');
    }
    return Part(
      id: _id,
      name: _name,
      measures: _measures,
    );
  }
}
