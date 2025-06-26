using System;
using System.Collections.Generic;

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a tie mark connecting notes of the same pitch.
    /// </summary>
    public class Tie
    {
        /// <summary>
        /// The type of tie (e.g., "start", "stop").
        /// MusicXML also allows "continue" but it's less common for basic ties.
        /// </summary>
        public string Type { get; }

        /// <summary>
        /// The placement of the tie relative to the note (e.g., "above", "below").
        /// Optional.
        /// </summary>
        public string? Placement { get; } // Consider an enum Placement in the future

        /// <summary>
        /// Creates a new <see cref="Tie"/> instance.
        /// </summary>
        public Tie(string type, string? placement = null)
        {
            if (string.IsNullOrEmpty(type))
                throw new ArgumentException("Tie type cannot be null or empty.", nameof(type));

            Type = type;
            Placement = placement;
        }

        public override bool Equals(object? obj)
        {
            if (obj is Tie other)
            {
                return Type == other.Type &&
                       Placement == other.Placement;
            }
            return false;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Type, Placement);
        }

        public override string ToString()
        {
            var parts = new List<string> { $"Type: {Type}" };
            if (!string.IsNullOrEmpty(Placement))
            {
                parts.Add($"Placement: {Placement}");
            }
            return $"Tie{{{string.Join(", ", parts)}}}";
        }
    }

    // Future considerations:
    // public enum TieType { Start, Stop, Continue }
    // public enum Placement { Above, Below } // (already considered for Slur)
}
