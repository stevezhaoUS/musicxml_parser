using System;
using System.Collections.Generic;
using MusicXMLParser.Exceptions; // Assuming exceptions are in this namespace

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a time modification, such as a tuplet.
    /// </summary>
    public class TimeModification
    {
        /// <summary>
        /// The number of actual notes in the tuplet (e.g., 3 for a triplet).
        /// </summary>
        public int ActualNotes { get; }

        /// <summary>
        /// The number of normal notes of the same type that would normally
        /// occupy the same duration (e.g., 2 for a triplet of eighths).
        /// </summary>
        public int NormalNotes { get; }

        /// <summary>
        /// The note type of the normal notes (e.g., "eighth", "quarter").
        /// Optional in MusicXML.
        /// </summary>
        public string NormalType { get; }

        /// <summary>
        /// The number of dots on the normal notes, if specified.
        /// This represents the count of &lt;normal-dot/&gt; elements.
        /// Null if &lt;normal-dot&gt; elements are not present.
        /// </summary>
        public int? NormalDotCount { get; }

        /// <summary>
        /// Creates a new <see cref="TimeModification"/> instance.
        /// </summary>
        public TimeModification(
            int actualNotes,
            int normalNotes,
            string normalType = null,
            int? normalDotCount = null)
        {
            if (actualNotes <= 0)
                throw new ArgumentOutOfRangeException(nameof(actualNotes), "ActualNotes must be positive.");
            if (normalNotes <= 0)
                throw new ArgumentOutOfRangeException(nameof(normalNotes), "NormalNotes must be positive.");
            if (normalDotCount.HasValue && normalDotCount.Value < 0)
                throw new ArgumentOutOfRangeException(nameof(normalDotCount), "NormalDotCount cannot be negative if specified.");

            ActualNotes = actualNotes;
            NormalNotes = normalNotes;
            NormalType = normalType;
            NormalDotCount = normalDotCount;
        }

        // Removed CreateValidated static method as per user request to defer validation.
        // Constructor with basic argument checks remains.

        public override bool Equals(object obj)
        {
            if (obj is TimeModification other)
            {
                return ActualNotes == other.ActualNotes &&
                       NormalNotes == other.NormalNotes &&
                       NormalType == other.NormalType &&
                       NormalDotCount == other.NormalDotCount;
            }
            return false;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(ActualNotes, NormalNotes, NormalType, NormalDotCount);
        }

        public override string ToString()
        {
            var parts = new List<string>
            {
                $"ActualNotes: {ActualNotes}",
                $"NormalNotes: {NormalNotes}"
            };
            if (!string.IsNullOrEmpty(NormalType))
            {
                parts.Add($"NormalType: {NormalType}");
            }
            if (NormalDotCount.HasValue)
            {
                parts.Add($"NormalDotCount: {NormalDotCount.Value}");
            }
            return $"TimeModification{{{string.Join(", ", parts)}}}";
        }
    }
}
