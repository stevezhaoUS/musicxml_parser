import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/models/measure.dart';

/// Represents a part in a musical score.
@immutable
class Part {
  /// The part ID.
  final String id;

  /// The part name.
  final String? name;

  /// The measures contained in the part.
  final List<Measure> measures;

  /// Creates a new [Part] instance.
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
          measures == other.measures;

  @override
  int get hashCode => id.hashCode ^ (name?.hashCode ?? 0) ^ measures.hashCode;

  @override
  String toString() =>
      'Part{id: $id, name: $name, measures: ${measures.length}}';
}
