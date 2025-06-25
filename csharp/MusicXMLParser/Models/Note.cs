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
        public Pitch Pitch { get; }
        public Duration Duration { get; }
        public bool IsRest { get; }
        public int? Voice { get; }
        public int? Staff { get; }
        public string Type { get; }
        public int? Dots { get; }
        public TimeModification TimeModification { get; }
        public List<Slur> Slurs { get; }
        public List<Articulation> Articulations { get; }
        public List<Tie> Ties { get; }
        public bool IsChordElementPresent { get; }
        public StemDirection? StemDirection { get; }
        public Accidental? Accidental { get; }
        public double? DefaultX { get; }
        public double? DefaultY { get; }
        public double? Dynamics { get; }

        public Note(Pitch pitch = null, Duration duration = null, bool isRest = false, int? voice = null, int? staff = null,
                    string type = null, int? dots = null, TimeModification timeModification = null, List<Slur> slurs = null,
                    List<Articulation> articulations = null, List<Tie> ties = null, bool isChordElementPresent = false,
                    StemDirection? stemDirection = null, Accidental? accidental = null, double? defaultX = null, double? defaultY = null, double? dynamics = null)
        {
            if (isRest && pitch != null)
                throw new ArgumentException("A rest must not have a pitch.");
            if (!isRest && pitch == null)
                throw new ArgumentException("A non-rest note must have a pitch.");

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
        }

        public static Note Validated(Pitch pitch = null, Duration duration = null, bool isRest = false, int? voice = null, int? staff = null,
                                     string type = null, int? dots = null, TimeModification timeModification = null, List<Slur> slurs = null,
                                     List<Articulation> articulations = null, List<Tie> ties = null, bool isChordElementPresent = false,
                                     StemDirection? stemDirection = null, Accidental? accidental = null, double? defaultX = null, double? defaultY = null,
                                     double? dynamics = null, int? line = null, Dictionary<string, object> context = null)
        {
            var currentContext = context ?? new Dictionary<string, object>();
            if (duration != null)
            {
                ValidationUtils.ValidateDuration(duration, line, currentContext);
            }
            if (!isRest && pitch != null)
            {
                ValidationUtils.ValidatePitch(pitch, line, currentContext);
            }

            if (voice.HasValue && voice <= 0)
            {
                currentContext["voice"] = voice;
                currentContext["isRest"] = isRest;
                throw new MusicXmlValidationException($"Note voice must be positive, got {voice}", "note_voice_validation", line, currentContext);
            }

            if (dots.HasValue && dots < 0)
            {
                currentContext["dots"] = dots;
                throw new MusicXmlValidationException($"Note dots must be non-negative, got {dots}", "note_dots_validation", line, currentContext);
            }

            if (isRest && pitch != null)
            {
                currentContext["isRest"] = isRest;
                currentContext["hasPitch"] = true;
                throw new MusicXmlValidationException("Rest notes should not have pitch information.", "rest_no_pitch_validation", line, currentContext);
            }

            if (!isRest && pitch == null)
            {
                currentContext["isRest"] = isRest;
                currentContext["hasPitch"] = false;
                throw new MusicXmlValidationException("Non-rest notes must have pitch information.", "note_pitch_required_validation", line, currentContext);
            }

            return new Note(pitch, duration, isRest, voice, staff, type, dots, timeModification, slurs, articulations, ties, isChordElementPresent, stemDirection, accidental, defaultX, defaultY, dynamics);
        }

        public override bool Equals(object obj) => Equals(obj as Note);

        public bool Equals(Note other) =>
            other != null &&
            EqualityComparer<Pitch>.Default.Equals(Pitch, other.Pitch) &&
            EqualityComparer<Duration>.Default.Equals(Duration, other.Duration) &&
            IsRest == other.IsRest &&
            Voice == other.Voice &&
            Staff == other.Staff &&
            Type == other.Type &&
            Dots == other.Dots &&
            EqualityComparer<TimeModification>.Default.Equals(TimeModification, other.TimeModification) &&
            (Slurs == null ? other.Slurs == null : Slurs.SequenceEqual(other.Slurs ?? new List<Slur>())) &&
            (Articulations == null ? other.Articulations == null : Articulations.SequenceEqual(other.Articulations ?? new List<Articulation>())) &&
            (Ties == null ? other.Ties == null : Ties.SequenceEqual(other.Ties ?? new List<Tie>())) &&
            IsChordElementPresent == other.IsChordElementPresent &&
            StemDirection == other.StemDirection &&
            Accidental == other.Accidental &&
            DefaultX == other.DefaultX &&
            DefaultY == other.DefaultY &&
            Dynamics == other.Dynamics;

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
            sb.Append("}");
            return sb.ToString();
        }
    }

    public class NoteBuilder
    {
        private Pitch _pitch;
        private Duration _duration;
        private bool _isRest = false;
        private int? _voice;
        private string _type;
        private int? _dots;
        private TimeModification _timeModification;
        private List<Slur> _slurs;
        private List<Articulation> _articulations;
        private List<Tie> _ties;
        private bool _isChordElementPresent = false;
        private int? _staff;
        private StemDirection? _stemDirection;
        private Accidental? _accidental;
        private double? _defaultX;
        private double? _defaultY;
        private double? _dynamics;

        private readonly int? _line;
        private readonly Dictionary<string, object> _context;

        public NoteBuilder(int? line = null, Dictionary<string, object> context = null)
        {
            _line = line;
            _context = context ?? new Dictionary<string, object>();
        }

        public NoteBuilder SetStaff(int? staff) { _staff = staff; return this; }
        public NoteBuilder SetPitch(Pitch pitch) { _pitch = pitch; return this; }
        public NoteBuilder SetDuration(Duration duration) { _duration = duration; return this; }
        public NoteBuilder SetIsRest(bool isRest) { _isRest = isRest; return this; }
        public NoteBuilder SetVoice(int? voice) { _voice = voice; return this; }
        public NoteBuilder SetType(string type) { _type = type; return this; }
        public NoteBuilder SetDots(int? dots) { _dots = dots; return this; }
        public NoteBuilder SetTimeModification(TimeModification timeModification) { _timeModification = timeModification; return this; }
        public NoteBuilder SetSlurs(List<Slur> slurs) { _slurs = slurs; return this; }
        public NoteBuilder SetArticulations(List<Articulation> articulations) { _articulations = articulations; return this; }
        public NoteBuilder SetTies(List<Tie> ties) { _ties = ties; return this; }
        public NoteBuilder SetIsChordElementPresent(bool isChordElementPresent) { _isChordElementPresent = isChordElementPresent; return this; }
        public NoteBuilder SetStemDirection(StemDirection? stemDirection) { _stemDirection = stemDirection; return this; }
        public NoteBuilder SetAccidental(Accidental? accidental) { _accidental = accidental; return this; }
        public NoteBuilder SetDefaultX(double? x) { _defaultX = x; return this; }
        public NoteBuilder SetDefaultY(double? y) { _defaultY = y; return this; }
        public NoteBuilder SetDynamics(double? dynamics) { _dynamics = dynamics; return this; }

        public Note Build()
        {
            return Note.Validated(
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
                line: _line,
                context: _context
            );
        }
    }
}
