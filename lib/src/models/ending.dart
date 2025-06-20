import 'package:meta/meta.dart';

/// Represents the type of an ending.
enum EndingType {
  /// Start of an ending (e.g., beginning of "1." or "2.").
  start,
  
  /// Stop/end of an ending (e.g., end of "1." or "2.").
  stop,
  
  /// Discontinue ending (partial ending that doesn't close).
  discontinue,
}

/// Represents an ending in a musical score.
/// 
/// Endings are used with repeats to indicate different paths through
/// the music (e.g., "play this the first time, play that the second time").
/// 
/// Example usage:
/// ```dart
/// // First ending start
/// const firstEnding = Ending(
///   number: '1',
///   type: EndingType.start,
/// );
/// 
/// // Second ending with multiple numbers
/// const secondEnding = Ending(
///   number: '2,3',
///   type: EndingType.start,
/// );
/// 
/// // Ending stop
/// const endingStop = Ending(
///   number: '1',
///   type: EndingType.stop,
/// );
/// ```
@immutable
class Ending {
  /// The number(s) of the ending (e.g., "1", "2", "1,2").
  /// 
  /// This can be a single number or a comma-separated list
  /// indicating which repetitions this ending applies to.
  final String number;
  
  /// The type of the ending (start, stop, or discontinue).
  final EndingType type;
  
  /// Optional text to display for the ending.
  /// 
  /// If not provided, the number is typically used for display.
  final String? text;
  
  /// Creates a new [Ending] instance.
  /// 
  /// [number] specifies which repetitions this ending applies to.
  /// [type] specifies whether this starts, stops, or discontinues the ending.
  /// [text] optionally provides custom display text.
  const Ending({
    required this.number,
    required this.type,
    this.text,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ending &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          type == other.type &&
          text == other.text;

  @override
  int get hashCode =>
      number.hashCode ^ type.hashCode ^ (text?.hashCode ?? 0);

  @override
  String toString() => 'Ending{number: $number, type: $type, text: $text}';
}