import 'package:meta/meta.dart';

/// Represents the direction of a repeat.
enum RepeatDirection {
  /// Forward repeat (start repeat) - |:
  forward,
  
  /// Backward repeat (end repeat) - :|
  backward,
}

/// Represents a repeat sign in a musical score.
/// 
/// Repeats indicate sections of music that should be played multiple times.
/// They appear as part of barlines and control musical navigation.
/// 
/// Example usage:
/// ```dart
/// // Start repeat
/// const startRepeat = Repeat(direction: RepeatDirection.forward);
/// 
/// // End repeat with specific number of times
/// const endRepeat = Repeat(
///   direction: RepeatDirection.backward,
///   times: 2,
/// );
/// ```
@immutable
class Repeat {
  /// The direction of the repeat (forward for start, backward for end).
  final RepeatDirection direction;
  
  /// The number of times to repeat.
  /// 
  /// This is typically used with backward repeats to specify
  /// how many times the repeated section should be played.
  /// If null, defaults to the standard behavior (play twice total).
  final int? times;
  
  /// Creates a new [Repeat] instance.
  /// 
  /// [direction] specifies whether this is a start or end repeat.
  /// [times] optionally specifies how many times to repeat the section.
  const Repeat({
    required this.direction,
    this.times,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Repeat &&
          runtimeType == other.runtimeType &&
          direction == other.direction &&
          times == other.times;

  @override
  int get hashCode => direction.hashCode ^ (times?.hashCode ?? 0);

  @override
  String toString() => 'Repeat{direction: $direction, times: $times}';
}