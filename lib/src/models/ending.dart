import 'package:meta/meta.dart';

/// Represents a repeat ending in MusicXML (e.g., 1st or 2nd ending).
@immutable
class Ending {
  /// The ending number(s), as a string (e.g., "1", "2", "1,3").
  /// This corresponds to the text content of the <ending> element in MusicXML 2.0,
  /// or the 'number' attribute in MusicXML 3.0+. For simplicity, we'll assume
  /// it's parsed from the 'number' attribute.
  final String number;

  /// The type of ending mark (e.g., "start", "stop", "discontinue").
  /// Corresponds to the 'type' attribute of the <ending> element.
  final String type;

  /// Indicates whether the ending text should be printed (e.g., "yes", "no").
  /// Corresponds to the 'print-object' attribute. Defaults to "yes".
  final String printObject;

  /// Creates a new [Ending] instance.
  const Ending({
    required this.number,
    required this.type,
    this.printObject = "yes", // MusicXML default for print-object is "yes"
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ending &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          type == other.type &&
          printObject == other.printObject;

  @override
  int get hashCode => number.hashCode ^ type.hashCode ^ printObject.hashCode;

  @override
  String toString() {
    final parts = [
      'number: $number',
      'type: $type',
      if (printObject != "yes")
        'printObject: $printObject', // Only show if not default
    ];
    return 'Ending{${parts.join(', ')}}';
  }
}
