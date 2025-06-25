using System;
using System.Collections.Generic;

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a clef in MusicXML.
    /// A clef indicates the pitch assigned to each line on a staff.
    /// It consists of a sign (e.g., G, F, C), a line number on the staff,
    /// and an optional octave change.
    /// </summary>
    public class Clef : IEquatable<Clef>
    {
        /// <summary>
        /// The clef sign (e.g., "G", "F", "C", "percussion", "TAB", "jianpu", "none").
        /// </summary>
        public string? Sign { get; }

        /// <summary>
        /// The staff line number where the sign is centered (e.g., 2 for G clef).
        /// For clefs like "percussion", "TAB", "jianpu", "none", the line may be absent.
        /// </summary>
        public int? Line { get; }

        /// <summary>
        /// Indicates an octave shift for the clef.
        /// A value of 1 means one octave up, -1 means one octave down.
        /// 0 or null means no octave change.
        /// </summary>
        public int? OctaveChange { get; }

        /// <summary>
        /// Staff number to which this clef applies.
        /// If null, applies to the current staff or staff 1 by default.
        /// </summary>
        public int? Number { get; }

        /// <summary>
        /// Creates a <see cref="Clef"/> instance.
        /// </summary>
        public Clef(string? sign, int? line = null, int? octaveChange = null, int? number = null)
        {
            Sign = sign;
            Line = line;
            OctaveChange = octaveChange;
            Number = number;
        }

        public override bool Equals(object? obj)
        {
            return Equals(obj as Clef);
        }

        public bool Equals(Clef? other)
        {
            return other != null &&
                   Sign == other.Sign &&
                   Line == other.Line &&
                   OctaveChange == other.OctaveChange &&
                   Number == other.Number;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Sign, Line, OctaveChange, Number);
        }

        public override string ToString()
        {
            var parts = new List<string> { $"sign: {Sign}" };
            if (Line.HasValue) parts.Add($"line: {Line}");
            if (OctaveChange.HasValue && OctaveChange != 0) parts.Add($"octaveChange: {OctaveChange}");
            if (Number.HasValue) parts.Add($"staff: {Number}");
            return $"Clef{{{string.Join(", ", parts)}}}";
        }
    }
}
