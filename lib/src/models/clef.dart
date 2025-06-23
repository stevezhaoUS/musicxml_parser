import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Represents a clef in MusicXML.
///
/// A clef indicates the pitch assigned to each line on a staff.
/// It consists of a sign (e.g., G, F, C), a line number on the staff,
/// and an optional octave change.
@immutable
class Clef extends Equatable {
  /// The clef sign (e.g., "G", "F", "C", "percussion", "TAB", "jianpu", "none").
  final String sign;

  /// The staff line number where the sign is centered (e.g., 2 for G clef).
  /// For clefs like "percussion", "TAB", "jianpu", "none", the line may be absent.
  final int? line;

  /// Indicates an octave shift for the clef.
  /// A value of 1 means one octave up, -1 means one octave down.
  /// 0 or null means no octave change.
  final int? octaveChange;

  /// Staff number to which this clef applies.
  /// If null, applies to the current staff or staff 1 by default.
  final int? number;

  /// Creates a [Clef] instance.
  const Clef({
    required this.sign,
    this.line,
    this.octaveChange,
    this.number,
  });

  @override
  List<Object?> get props => [sign, line, octaveChange, number];

  @override
  String toString() {
    final parts = <String>[
      'sign: $sign',
      if (line != null) 'line: $line',
      if (octaveChange != null && octaveChange != 0)
        'octaveChange: $octaveChange',
      if (number != null) 'staff: $number',
    ];
    return 'Clef{${parts.join(', ')}}';
  }
}
