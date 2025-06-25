using System;

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a musical articulation mark.
    /// </summary>
    public class Articulation : IEquatable<Articulation>
    {
        /// <summary>
        /// The type of articulation, corresponding to the MusicXML element name
        /// (e.g., "accent", "staccato", "tenuto").
        /// </summary>
        public string? Type { get; }

        /// <summary>
        /// The placement of the articulation relative to the note (e.g., "above", "below").
        /// Optional.
        /// </summary>
        public string? Placement { get; } // Consider an enum Placement in the future

        /// <summary>
        /// Creates a new <see cref="Articulation"/> instance.
        /// </summary>
        public Articulation(string? type, string? placement = null)
        {
            Type = type;
            Placement = placement;
        }

        public override bool Equals(object? obj) // Made obj nullable
        {
            return Equals(obj as Articulation);
        }

        public bool Equals(Articulation? other) // Made other nullable
        {
            return other != null &&
                   Type == other.Type &&
                   Placement == other.Placement;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Type, Placement);
        }

        public override string ToString()
        {
            var parts = new List<string> { $"type: {Type}" };
            if (!string.IsNullOrEmpty(Placement))
            {
                parts.Add($"placement: {Placement}");
            }
            return $"Articulation{{{string.Join(", ", parts)}}}";
        }
    }
}
