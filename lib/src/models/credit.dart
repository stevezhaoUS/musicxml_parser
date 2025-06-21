import 'package:meta/meta.dart';
import 'package:collection/collection.dart'; // For DeepCollectionEquality

/// Represents a credit in a MusicXML score, such as titles, composer names, etc.
@immutable
class Credit {
  /// The page number where the credit appears. Optional.
  final int? page;

  /// The type of credit (e.g., "title", "subtitle", "composer").
  /// Corresponds to the text content of the <credit-type> element. Optional.
  final String? creditType;

  /// The words of the credit. A single <credit> can have multiple <credit-words> elements.
  /// Corresponds to the text content of <credit-words> elements. Defaults to an empty list.
  final List<String> creditWords;

  /// Creates a new [Credit] instance.
  const Credit({
    this.page,
    this.creditType,
    this.creditWords = const [], // Default to an empty list
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Credit &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          creditType == other.creditType &&
          const DeepCollectionEquality().equals(creditWords, other.creditWords);

  @override
  int get hashCode =>
      (page?.hashCode ?? 0) ^
      (creditType?.hashCode ?? 0) ^
      const DeepCollectionEquality().hash(creditWords);

  @override
  String toString() {
    final parts = <String>[];
    if (page != null) parts.add('page: $page');
    if (creditType != null) parts.add('creditType: "$creditType"');
    if (creditWords.isNotEmpty) parts.add('creditWords: ${creditWords.map((w) => '"$w"').join(', ')}');

    return 'Credit{${parts.join(', ')}}';
  }
}
