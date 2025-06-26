using System;
using System.Collections.Generic;
using System.Linq;
// Assuming other models are in this namespace or referenced appropriately
// using MusicXMLParser.Models.Barline;
// using MusicXMLParser.Models.Beam;
// using MusicXMLParser.Models.Clef;
// using MusicXMLParser.Models.Ending;
// using MusicXMLParser.Models.KeySignature;
// using MusicXMLParser.Models.Note;
// using MusicXMLParser.Models.TimeSignature;
// using MusicXMLParser.Models.Direction;
// using MusicXMLParser.Models.PrintObject;

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a single measure in a musical score.
    /// A measure contains a sequence of <see cref="Note"/> objects, and can also define attributes
    /// like <see cref="KeySignature"/>, <see cref="TimeSignature"/>, <see cref="Clef"/>s, <see cref="Barline"/>s, and width.
    /// It is identified by a number (measure number).
    /// Instances are typically created via <see cref="MeasureBuilder"/>.
    /// Objects of this class are immutable.
    /// </summary>
    public class Measure : IEquatable<Measure>
    {
        /// <summary>
        /// The measure number as a string (e.g., "1", "2a").
        /// </summary>
        public string Number { get; }

        /// <summary>
        /// The list of <see cref="Note"/> objects contained within this measure.
        /// </summary>
        public List<Note> Notes { get; }

        /// <summary>
        /// The key signature active at the beginning of this measure, if specified.
        /// </summary>
        public KeySignature? KeySignature { get; }

        /// <summary>
        /// The time signature active at the beginning of this measure, if specified.
        /// </summary>
        public TimeSignature? TimeSignature { get; }

        /// <summary>
        /// A list of <see cref="Clef"/> objects active at the beginning of this measure.
        /// MusicXML allows for multiple clefs per measure.
        /// </summary>
        public List<Clef> Clefs { get; }

        /// <summary>
        /// The visual width of the measure in tenths.
        /// </summary>
        public double? Width { get; }

        /// <summary>
        /// A list of <see cref="Beam"/> objects defined within this measure.
        /// </summary>
        public List<Beam> Beams { get; }

        /// <summary>
        /// Indicates if this measure is a pickup (anacrusis) measure.
        /// </summary>
        public bool IsPickup { get; }

        /// <summary>
        /// A list of <see cref="Barline"/> objects associated with this measure (e.g., start, end, repeat).
        /// </summary>
        public List<Barline> Barlines { get; }

        /// <summary>
        /// Repeat <see cref="Ending"/> information for this measure, if applicable.
        /// </summary>
        public Ending? Ending { get; }

        /// <summary>
        /// List of <see cref="Direction"/> objects associated with this measure.
        /// </summary>
        public List<Direction> Directions { get; }

        /// <summary>
        /// Print-related hints and overrides for this measure.
        /// </summary>
        public PrintObject? PrintObject { get; }

        public Measure(string number, List<Note>? notes = null, KeySignature? keySignature = null, TimeSignature? timeSignature = null,
                       List<Clef>? clefs = null, bool isPickup = false, double? width = null, List<Beam>? beams = null,
                       List<Barline>? barlines = null, Ending? ending = null, List<Direction>? directions = null, PrintObject? printObject = null)
        {
            Number = number;
            Notes = notes ?? new List<Note>();
            KeySignature = keySignature;
            TimeSignature = timeSignature;
            Clefs = clefs ?? new List<Clef>();
            IsPickup = isPickup;
            Width = width;
            Beams = beams ?? new List<Beam>();
            Barlines = barlines ?? new List<Barline>();
            Ending = ending;
            Directions = directions ?? new List<Direction>();
            PrintObject = printObject;
        }

        public override bool Equals(object obj) => Equals(obj as Measure);

        public bool Equals(Measure other) =>
            other != null &&
            Number == other.Number &&
            (Notes == null ? other.Notes == null : Notes.SequenceEqual(other.Notes ?? new List<Note>())) &&
            EqualityComparer<KeySignature?>.Default.Equals(KeySignature, other.KeySignature) &&
            EqualityComparer<TimeSignature?>.Default.Equals(TimeSignature, other.TimeSignature) &&
            (Clefs == null ? other.Clefs == null : Clefs.SequenceEqual(other.Clefs ?? new List<Clef>())) &&
            Width == other.Width &&
            (Beams == null ? other.Beams == null : Beams.SequenceEqual(other.Beams ?? new List<Beam>())) &&
            (Barlines == null ? other.Barlines == null : Barlines.SequenceEqual(other.Barlines ?? new List<Barline>())) &&
            EqualityComparer<Ending?>.Default.Equals(Ending, other.Ending) &&
            (Directions == null ? other.Directions == null : Directions.SequenceEqual(other.Directions ?? new List<Direction>())) &&
            EqualityComparer<PrintObject?>.Default.Equals(PrintObject, other.PrintObject);


        public override int GetHashCode()
        {
            var hashCode = new HashCode();
            hashCode.Add(Number);
            Notes.ForEach(n => hashCode.Add(n));
            hashCode.Add(KeySignature);
            hashCode.Add(TimeSignature);
            Clefs?.ForEach(c => hashCode.Add(c));
            hashCode.Add(Width);
            Beams?.ForEach(b => hashCode.Add(b));
            Barlines?.ForEach(b => hashCode.Add(b));
            hashCode.Add(Ending);
            Directions?.ForEach(d => hashCode.Add(d));
            hashCode.Add(PrintObject);
            return hashCode.ToHashCode();
        }

        public override string ToString()
        {
            var parts = new List<string>
            {
                $"number: {Number}",
                $"notes: {Notes.Count}"
            };
            if (Beams.Any()) parts.Add($"beams: {Beams.Count}");
            if (KeySignature != null) parts.Add($"key: {KeySignature}");
            if (TimeSignature != null) parts.Add($"time: {TimeSignature}");
            if (Clefs != null && Clefs.Any()) parts.Add($"clefs: [{string.Join(", ", Clefs)}]");
            if (Width.HasValue) parts.Add($"width: {Width}");
            if (IsPickup) parts.Add("pickup");
            if (Barlines != null && Barlines.Any()) parts.Add($"barlines: [{string.Join(", ", Barlines)}]");
            if (Ending != null) parts.Add($"ending: {Ending}");
            if (Directions.Any()) parts.Add($"directions: [{string.Join(", ", Directions)}]");
            if (PrintObject != null) parts.Add($"printObject: {PrintObject}");

            return $"Measure{{{string.Join(", ", parts)}}}";
        }
    }

    public class MeasureBuilder
    {
        private readonly string _number;
        private List<Note> _notes = new List<Note>();
        private KeySignature? _keySignature;
        private TimeSignature? _timeSignature;
        private List<Clef> _clefs = new List<Clef>();
        private double? _width;
        private List<Beam> _beams = new List<Beam>();
        private bool _isPickup = false;
        private List<Barline> _barlines = new List<Barline>();
        private Ending? _ending;
        private List<Direction> _directions = new List<Direction>();
        private PrintObject? _printObject;

        public MeasureBuilder(string number, int? line = null, Dictionary<string, object> context = null)
        {
            _number = number;
            // line and context are currently unused in C# version, similar to Dart
        }

        public MeasureBuilder SetNotes(List<Note>? notes) { _notes = notes ?? new List<Note>(); return this; }
        public MeasureBuilder AddNote(Note note) { _notes.Add(note); return this; }
        public MeasureBuilder SetKeySignature(KeySignature? keySignature) { _keySignature = keySignature; return this; }
        public MeasureBuilder SetTimeSignature(TimeSignature? timeSignature) { _timeSignature = timeSignature; return this; }
        public MeasureBuilder SetClefs(List<Clef>? clefs) { _clefs = clefs ?? new List<Clef>(); return this; }
        public MeasureBuilder SetWidth(double? width) { _width = width; return this; }
        public MeasureBuilder SetBeams(List<Beam>? beams) { _beams = beams ?? new List<Beam>(); return this; }
        public MeasureBuilder AddBeam(Beam beam) { _beams.Add(beam); return this; }
        public MeasureBuilder SetIsPickup(bool isPickup) { _isPickup = isPickup; return this; }
        public MeasureBuilder SetBarlines(List<Barline>? barlines) { _barlines = barlines ?? new List<Barline>(); return this; }
        public MeasureBuilder AddBarline(Barline barline) { _barlines.Add(barline); return this; }
        public MeasureBuilder SetEnding(Ending? ending) { _ending = ending; return this; }
        public MeasureBuilder SetDirections(List<Direction>? directions) { _directions = directions ?? new List<Direction>(); return this; }
        public MeasureBuilder AddDirection(Direction direction) { _directions.Add(direction); return this; }
        public MeasureBuilder SetPrintObject(PrintObject? printObject) { _printObject = printObject; return this; }

        // For internal use, similar to Dart's @internal
        public int DebugGetNotesCount() => _notes.Count;

        public Measure Build()
        {
            // 调试输出集合内容
            Console.WriteLine($"[MeasureBuilder.Build] number={_number}, notes={_notes.Count}, barlines={_barlines.Count}, clefs={_clefs.Count}, directions={_directions.Count}");
            if (string.IsNullOrEmpty(_number))
            {
                // Handle error or rely on parser, similar to Dart
            }

            return new Measure(
                _number,
                _notes,
                _keySignature,
                _timeSignature,
                _clefs,
                _isPickup,
                _width,
                _beams,
                _barlines,
                _ending,
                _directions,
                _printObject
            );
        }
    }
}
