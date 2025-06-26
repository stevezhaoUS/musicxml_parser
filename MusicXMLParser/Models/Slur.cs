using System;
using System.Text;

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a slur mark attached to a note.
    /// </summary>
    public class Slur
    {
        /// <summary>
        /// The type of slur (e.g., "start", "stop", "continue").
        /// </summary>
        public string Type { get; } // Consider an enum SlurType in the future

        /// <summary>
        /// The slur number, used for matching slurs that span multiple notes.
        /// Defaults to 1 if not specified in the MusicXML.
        /// </summary>
        public int Number { get; }

        /// <summary>
        /// The placement of the slur relative to the note (e.g., "above", "below").
        /// Optional.
        /// </summary>
        public string? Placement { get; } // Consider an enum Placement in the future

        // Other common attributes like orientation, bezier points can be added later.

        /// <summary>
        /// Creates a new <see cref="Slur"/> instance.
        /// </summary>
        public Slur(string type, int number = 1, string? placement = null)
        {
            if (string.IsNullOrEmpty(type))
                throw new ArgumentException("Slur type cannot be null or empty.", nameof(type));

            Type = type;
            Number = number;
            Placement = placement;
        }

        public override bool Equals(object? obj)
        {
            if (obj is Slur other)
            {
                return Type == other.Type &&
                       Number == other.Number &&
                       Placement == other.Placement;
            }
            return false;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Type, Number, Placement);
        }

        public override string ToString()
        {
            var parts = new List<string>
            {
                $"Type: {Type}",
                $"Number: {Number}"
            };
            if (!string.IsNullOrEmpty(Placement))
            {
                parts.Add($"Placement: {Placement}");
            }
            return $"Slur{{{string.Join(", ", parts)}}}";
        }
    }

    // Future considerations:
    // public enum SlurType { Start, Stop, Continue }
    // public enum Placement { Above, Below }
}
