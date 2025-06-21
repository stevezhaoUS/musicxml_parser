import 'package:meta/meta.dart';
import 'package:collection/collection.dart'; // For DeepCollectionEquality
import 'package:musicxml_parser/src/models/barline.dart';
import 'package:musicxml_parser/src/models/beam.dart';
import 'package:musicxml_parser/src/models/ending.dart';
import 'package:musicxml_parser/src/models/key_signature.dart';
import 'package:musicxml_parser/src/models/note.dart';
import 'package:musicxml_parser/src/models/time_signature.dart';
import 'package:musicxml_parser/src/models/direction.dart';
import 'print_object.dart';

/// Represents a single measure in a musical score.
///
/// A measure contains a sequence of [notes], and can also define attributes
/// like [keySignature], [timeSignature], [barlines], and [width].
/// It is identified by a [number] (measure number).
///
/// Instances are typically created via [MeasureBuilder].
/// Objects of this class are immutable.
@immutable
class Measure {
  /// The measure number as a string (e.g., "1", "2a").
  final String number;

  /// The list of [Note] objects contained within this measure.
  final List<Note> notes;

  /// The key signature active at the beginning of this measure, if specified.
  final KeySignature? keySignature;

  /// The time signature active at the beginning of this measure, if specified.
  final TimeSignature? timeSignature;

  /// The visual width of the measure in tenths.
  final double? width;

  /// A list of [Beam] objects defined within this measure.
  final List<Beam> beams;

  /// Indicates if this measure is a pickup (anacrusis) measure.
  final bool isPickup;

  /// A list of [Barline] objects associated with this measure (e.g., start, end, repeat).
  final List<Barline>? barlines;

  /// Repeat [Ending] information for this measure, if applicable.
  final Ending? ending;

  /// List of [Direction] objects associated with this measure.
  final List<Direction> directions;

  /// Print-related hints and overrides for this measure, such as new page/system breaks
  /// or local layout changes.
  final PrintObject? printObject;

  /// Creates a new [Measure] instance.
  ///
  /// It is generally recommended to use [MeasureBuilder] for constructing [Measure]
  /// objects, as it simplifies the process of incrementally adding properties
  /// during parsing.
  const Measure({
    required this.number,
    required this.notes,
    this.keySignature,
    this.timeSignature,
    this.isPickup = false,
    this.width,
    this.beams = const [],
    this.barlines,
    this.ending,
    this.directions = const [],
    this.printObject,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Measure &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          const DeepCollectionEquality().equals(notes, other.notes) &&
          keySignature == other.keySignature &&
          timeSignature == other.timeSignature &&
          width == other.width &&
          const DeepCollectionEquality().equals(beams, other.beams) &&
          const DeepCollectionEquality().equals(barlines, other.barlines) &&
          ending == other.ending &&
          const DeepCollectionEquality().equals(directions, other.directions) &&
          printObject == other.printObject;

  @override
  int get hashCode =>
      number.hashCode ^
      const DeepCollectionEquality().hash(notes) ^
      keySignature.hashCode ^
      timeSignature.hashCode ^
      (width?.hashCode ?? 0) ^
      const DeepCollectionEquality().hash(beams) ^
      (barlines != null ? const DeepCollectionEquality().hash(barlines!) : 0) ^
      (ending?.hashCode ?? 0) ^
      const DeepCollectionEquality().hash(directions) ^
      (printObject?.hashCode ?? 0);

  @override
  String toString() {
    final parts = [
      'number: $number',
      'notes: ${notes.length}',
      if (beams.isNotEmpty) 'beams: ${beams.length}',
      if (keySignature != null) 'key: $keySignature',
      if (timeSignature != null) 'time: $timeSignature',
      if (width != null) 'width: $width',
      if (isPickup) 'pickup',
      if (barlines != null && barlines!.isNotEmpty) 'barlines: $barlines',
      if (ending != null) 'ending: $ending',
      if (directions.isNotEmpty) 'directions: $directions',
      if (printObject != null) 'printObject: $printObject',
    ];
    return 'Measure{${parts.join(', ')}}';
  }
}

/// Builder for creating [Measure] objects incrementally.
///
/// This builder is useful during the parsing process where measure properties
/// (like notes, barlines, key/time signatures) are discovered and set step-by-step.
/// The [build] method finalizes the measure construction.
///
/// Example:
/// ```dart
/// final measureBuilder = MeasureBuilder("1", line: 5, context: {'partId': 'P1'});
/// measureBuilder
///   .addNote(aNote)
///   .setKeySignature(aKeySignature)
///   .addBarline(aBarline);
/// final Measure measure = measureBuilder.build();
/// ```
class MeasureBuilder {
  /// The measure number.
  final String _number;
  List<Note> _notes = [];
  KeySignature? _keySignature;
  TimeSignature? _timeSignature;
  double? _width;
  List<Beam> _beams = [];
  bool _isPickup = false;
  List<Barline>? _barlines;
  Ending? _ending;
  List<Direction> _directions = [];
  PrintObject? _printObject;

  /// Line number in the XML for error reporting context.
  final int? _line;

  /// Additional context for error reporting.
  final Map<String, dynamic>? _context;

  /// Creates a [MeasureBuilder] for a measure with the given [number].
  ///
  /// [line] and [context] can be provided for more detailed error
  /// messages if validation fails (though MeasureBuilder currently doesn't
  /// perform extensive validation itself, it would pass this to a
  /// hypothetical `Measure.validated` factory).
  MeasureBuilder(this._number, {int? line, Map<String, dynamic>? context})
      : _line = line,
        _context = context;

  /// Sets all notes for the measure.
  MeasureBuilder setNotes(List<Note> notes) {
    _notes = notes;
    return this;
  }

  /// Adds a single [Note] to the measure.
  MeasureBuilder addNote(Note note) {
    _notes.add(note);
    return this;
  }

  /// Sets the key signature for the measure.
  MeasureBuilder setKeySignature(KeySignature? keySignature) {
    _keySignature = keySignature;
    return this;
  }

  /// Sets the time signature for the measure.
  MeasureBuilder setTimeSignature(TimeSignature? timeSignature) {
    _timeSignature = timeSignature;
    return this;
  }

  /// Sets the visual width of the measure.
  MeasureBuilder setWidth(double? width) {
    _width = width;
    return this;
  }

  /// Sets all beams for the measure.
  MeasureBuilder setBeams(List<Beam> beams) {
    _beams = beams;
    return this;
  }

  /// Adds a single [Beam] to the measure.
  MeasureBuilder addBeam(Beam beam) {
    _beams.add(beam);
    return this;
  }

  /// Sets whether this is a pickup measure.
  MeasureBuilder setIsPickup(bool isPickup) {
    _isPickup = isPickup;
    return this;
  }

  /// Sets all barlines for the measure.
  MeasureBuilder setBarlines(List<Barline>? barlines) {
    _barlines = barlines;
    return this;
  }

  /// Adds a single [Barline] to the measure.
  MeasureBuilder addBarline(Barline barline) {
    _barlines ??= [];
    _barlines!.add(barline);
    return this;
  }

  /// Sets the repeat ending for the measure.
  MeasureBuilder setEnding(Ending? ending) {
    _ending = ending;
    return this;
  }

  /// Sets all directions for the measure.
  MeasureBuilder setDirections(List<Direction> directions) {
    _directions = directions;
    return this;
  }

  /// Adds a single [Direction] to the measure.
  MeasureBuilder addDirection(Direction direction) {
    _directions.add(direction);
    return this;
  }

  /// Sets the print object containing layout hints for the measure.
  MeasureBuilder setPrintObject(PrintObject? printObject) {
    _printObject = printObject;
    return this;
  }

  /// Temporary getter for MeasureParser to access notes count.
  /// TODO: Re-evaluate if a local list in MeasureParser + setNotes on builder is cleaner.
  @internal
  int debugGetNotesCount() => _notes.length;

  /// Builds the [Measure] instance.
  ///
  /// Currently, this method performs basic validation on the measure number.
  /// More complex validation (e.g., sum of note durations matches time signature)
  /// would typically be handled by a `Measure.validated` factory or a separate
  /// validation step post-parsing.
  Measure build() {
    // Example of a basic validation that could be done here or in a static factory.
    // MusicXML allows non-integer measure numbers (e.g., "X1" for pickup, "1a").
    // For simplicity, this example just checks for empty or obviously invalid.
    if (_number.isEmpty) {
      // This might be an appropriate place to throw MusicXmlValidationException
      // or log a warning, depending on desired strictness.
      // For now, relying on parser to ensure number is present.
    }

    return Measure(
      number: _number,
      notes: _notes,
      keySignature: _keySignature,
      timeSignature: _timeSignature,
      width: _width,
      beams: _beams,
      isPickup: _isPickup,
      barlines: _barlines,
      ending: _ending,
      directions: _directions,
      printObject: _printObject,
    );
  }
}
