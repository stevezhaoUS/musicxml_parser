using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MusicXMLParser.Exceptions; // Assuming these will be created later
using MusicXMLParser.Utils; // Assuming these will be created later

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Stem direction enum.
    /// </summary>
    public enum StemDirection { Up, Down, Double, None } // Corrected DoubleStem to Double

    /// <summary>
    /// Accidental enum, representing the accidental mark of a note.
    /// </summary>
    public enum Accidental
    {
        Sharp, Flat, Natural, DoubleSharp, DoubleFlat,
        SharpSharp, FlatFlat, QuarterSharp, QuarterFlat, Other
    }

    /// <summary>
    /// Represents a musical note or rest in a score.
    /// </summary>
    public class Note : IEquatable<Note>
    {
        public Pitch? Pitch { get; }
        public Duration? Duration { get; }
        public bool IsRest { get; }
        public int? Voice { get; }
        public int? Staff { get; }
        public string? Type { get; }
        public int? Dots { get; }
        public TimeModification? TimeModification { get; }
        public List<Slur> Slurs { get; }
        public List<Articulation> Articulations { get; }
        public List<Tie> Ties { get; }
        public bool IsChordElementPresent { get; }
        public StemDirection? StemDirection { get; }
        public Accidental? Accidental { get; }
        public double? DefaultX { get; }
        public double? DefaultY { get; }
        public double? Dynamics { get; }
        public bool IsUnpitched { get; } // Added property

        public Note(Pitch? pitch = null, Duration? duration = null, bool isRest = false, int? voice = null, int? staff = null,
                    string? type = null, int? dots = null, TimeModification? timeModification = null, List<Slur>? slurs = null,
                    List<Articulation>? articulations = null, List<Tie>? ties = null, bool isChordElementPresent = false,
                    StemDirection? stemDirection = null, Accidental? accidental = null, double? defaultX = null, double? defaultY = null, double? dynamics = null,
                    bool isUnpitched = false) // Added parameter
        {
            if (isRest && pitch != null)
                throw new ArgumentException("A rest must not have a pitch.");
            if (!isRest && !isUnpitched && pitch == null) // Adjusted condition
                throw new ArgumentException("A non-rest, pitched note must have a pitch.");
            if (isUnpitched && pitch != null) // Added condition
                throw new ArgumentException("An unpitched note must not have a pitch.");

            Pitch = pitch;
            Duration = duration;
            IsRest = isRest;
            Voice = voice;
            Staff = staff;
            Type = type;
            Dots = dots;
            TimeModification = timeModification;
            Slurs = slurs ?? new List<Slur>();
            Articulations = articulations ?? new List<Articulation>();
            Ties = ties ?? new List<Tie>();
            IsChordElementPresent = isChordElementPresent;
            StemDirection = stemDirection;
            Accidental = accidental;
            DefaultX = defaultX;
            DefaultY = defaultY;
            Dynamics = dynamics;
            IsUnpitched = isUnpitched; // Assign new property
        }

        // Removed Validated method as per user request to defer validation

        public override bool Equals(object? obj) => Equals(obj as Note);

        public bool Equals(Note? other) =>
            other != null &&
            EqualityComparer<Pitch?>.Default.Equals(Pitch, other.Pitch) &&
            EqualityComparer<Duration?>.Default.Equals(Duration, other.Duration) &&
            IsRest == other.IsRest &&
            Voice == other.Voice &&
            Staff == other.Staff &&
            Type == other.Type &&
            Dots == other.Dots &&
            EqualityComparer<TimeModification?>.Default.Equals(TimeModification, other.TimeModification) &&
            (Slurs == null ? other.Slurs == null : Slurs.SequenceEqual(other.Slurs ?? new List<Slur>())) &&
            (Articulations == null ? other.Articulations == null : Articulations.SequenceEqual(other.Articulations ?? new List<Articulation>())) &&
            (Ties == null ? other.Ties == null : Ties.SequenceEqual(other.Ties ?? new List<Tie>())) &&
            IsChordElementPresent == other.IsChordElementPresent &&
            StemDirection == other.StemDirection &&
            Accidental == other.Accidental &&
            DefaultX == other.DefaultX &&
            DefaultY == other.DefaultY &&
            Dynamics == other.Dynamics &&
            IsUnpitched == other.IsUnpitched; // Added to Equals

        public override int GetHashCode()
        {
            var hashCode = new HashCode();
            hashCode.Add(Pitch);
            hashCode.Add(Duration);
            hashCode.Add(IsRest);
            hashCode.Add(Voice);
            hashCode.Add(Staff);
            hashCode.Add(Type);
            hashCode.Add(Dots);
            hashCode.Add(TimeModification);
            Slurs?.ForEach(s => hashCode.Add(s));
            Articulations?.ForEach(a => hashCode.Add(a));
            Ties?.ForEach(t => hashCode.Add(t));
            hashCode.Add(IsChordElementPresent);
            hashCode.Add(StemDirection);
            hashCode.Add(Accidental);
            hashCode.Add(DefaultX);
            hashCode.Add(DefaultY);
            hashCode.Add(Dynamics);
            hashCode.Add(IsUnpitched); // Added to GetHashCode
            return hashCode.ToHashCode();
        }

        public override string ToString()
        {
            var sb = new StringBuilder();
            if (IsRest)
            {
                sb.Append($"Rest{{duration: {Duration}");
            }
            else
            {
                sb.Append($"Note{{pitch: {Pitch}, duration: {Duration}");
            }
            if (Staff.HasValue) sb.Append($", staff: {Staff}");
            if (Dots.HasValue && Dots > 0) sb.Append($", dots: {Dots}");
            if (TimeModification != null) sb.Append($", timeModification: {TimeModification}");
            if (Slurs != null && Slurs.Any()) sb.Append($", slurs: [{string.Join(", ", Slurs)}]");
            if (Articulations != null && Articulations.Any()) sb.Append($", articulations: [{string.Join(", ", Articulations)}]");
            if (Ties != null && Ties.Any()) sb.Append($", ties: [{string.Join(", ", Ties)}]");
            if (IsChordElementPresent) sb.Append(", isChordNote: true");
            if (StemDirection.HasValue) sb.Append($", stem: {StemDirection}");
            if (Accidental.HasValue) sb.Append($", accidental: {Accidental}");
            if (DefaultX.HasValue) sb.Append($", defaultX: {DefaultX}");
            if (DefaultY.HasValue) sb.Append($", defaultY: {DefaultY}");
            if (Dynamics.HasValue) sb.Append($", dynamics: {Dynamics}");
            if (IsUnpitched) sb.Append(", isUnpitched: true"); // Added to ToString
            sb.Append("}");
            return sb.ToString();
        }
    }

    public class NoteBuilder
    {
        private Pitch? _pitch;
        private Duration? _duration;
        private bool _isRest = false;
        private int? _voice;
        private string? _type;
        private int? _dots;
        private TimeModification? _timeModification;
        private List<Slur>? _slurs;
        private List<Articulation>? _articulations;
        private List<Tie>? _ties;
        private bool _isChordElementPresent = false;
        private int? _staff;
        private StemDirection? _stemDirection;
        private Accidental? _accidental; // Keep this name for the property being set
        private double? _defaultX;
        private double? _defaultY;
        private double? _dynamics;
        private bool _isUnpitched = false; // Added field

        private readonly int? _line;
        private readonly Dictionary<string, object> _context;

        public NoteBuilder(int? line = null, Dictionary<string, object>? context = null) // context can be null
        {
            _line = line;
            _context = context ?? new Dictionary<string, object>();
        }

        public NoteBuilder SetStaff(int? staff) { _staff = staff; return this; }
        public NoteBuilder SetPitch(Pitch? pitch) { _pitch = pitch; return this; } // Parameter to nullable
        public NoteBuilder SetDuration(Duration? duration) { _duration = duration; return this; } // Parameter to nullable
        public NoteBuilder SetIsRest(bool isRest) { _isRest = isRest; return this; }
        public NoteBuilder SetVoice(int? voice) { _voice = voice; return this; }
        public NoteBuilder SetType(string? type) { _type = type; return this; } // Parameter to nullable
        public NoteBuilder SetDots(int? dots) { _dots = dots; return this; }
        public NoteBuilder SetTimeModification(TimeModification? timeModification) { _timeModification = timeModification; return this; } // Parameter to nullable
        public NoteBuilder SetSlurs(List<Slur>? slurs) { _slurs = slurs; return this; } // Parameter to nullable
        public NoteBuilder SetArticulations(List<Articulation>? articulations) { _articulations = articulations; return this; } // Parameter to nullable
        public NoteBuilder SetTies(List<Tie>? ties) { _ties = ties; return this; } // Parameter to nullable
        public NoteBuilder SetIsChordElementPresent(bool isChordElementPresent) { _isChordElementPresent = isChordElementPresent; return this; }
        public NoteBuilder SetStemDirection(StemDirection? stemDirection) { _stemDirection = stemDirection; return this; }
        public NoteBuilder SetAccidental(Accidental? accidental) { _accidental = accidental; return this; } // Setter for Accidental
        public NoteBuilder SetDefaultX(double? x) { _defaultX = x; return this; }
        public NoteBuilder SetDefaultY(double? y) { _defaultY = y; return this; }
        public NoteBuilder SetDynamics(double? dynamics) { _dynamics = dynamics; return this; }
        public NoteBuilder SetIsUnpitched(bool isUnpitched) { _isUnpitched = isUnpitched; return this; } // Added setter

        public Note Build()
        {
            // Calls new Note directly, bypassing the removed Note.Validated method
            // The Note constructor itself contains basic argument checks (e.g., rest with pitch)
            // More complex validation is deferred as per user request.
            return new Note(
                pitch: _pitch,
                duration: _duration,
                isRest: _isRest,
                voice: _voice,
                staff: _staff,
                type: _type,
                dots: _dots,
                timeModification: _timeModification,
                slurs: _slurs,
                articulations: _articulations,
                ties: _ties,
                isChordElementPresent: _isChordElementPresent,
                stemDirection: _stemDirection,
                accidental: _accidental,
                defaultX: _defaultX,
                defaultY: _defaultY,
                dynamics: _dynamics,
                // line: _line, // Not part of Note constructor
                // context: _context, // Not part of Note constructor
                isUnpitched: _isUnpitched
            );
        }
    }
}
