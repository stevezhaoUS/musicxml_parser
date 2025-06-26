using System;
using System.Collections.Generic;

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a barline in a measure, potentially including repeat information.
    /// </summary>
    public class Barline : IEquatable<Barline>
    {
        /// <summary>
        /// The location of the barline within the measure (e.g., "left", "right", "middle").
        /// Typically corresponds to the 'location' attribute of the <barline> element.
        /// </summary>
        public string? Location { get; }

        /// <summary>
        /// The style of the barline (e.g., "light-light", "light-heavy", "none").
        /// Corresponds to the text content of the <bar-style> child element.
        /// </summary>
        public string? BarStyle { get; }

        /// <summary>
        /// The direction of a repeat mark (e.g., "forward", "backward").
        /// Corresponds to the 'direction' attribute of a <repeat> child element of <barline>.
        /// </summary>
        public string? RepeatDirection { get; }

        /// <summary>
        /// The number of times a repeat is to be played.
        /// Corresponds to the 'times' attribute of a <repeat> child element (MusicXML 3.0+).
        /// </summary>
        public int? Times { get; }

        /// <summary>
        /// Creates a new <see cref="Barline"/> instance.
        /// </summary>
        public Barline(string? location, string? barStyle, string? repeatDirection, int? repeatTimes)
        {
            Location = location ?? "";
            BarStyle = barStyle ?? "";
            RepeatDirection = repeatDirection ?? "";
            Times = repeatTimes;
        }

        public override bool Equals(object? obj)
        {
            return Equals(obj as Barline);
        }

        public bool Equals(Barline? other)
        {
            return other != null &&
                   Location == other.Location &&
                   BarStyle == other.BarStyle &&
                   RepeatDirection == other.RepeatDirection &&
                   Times == other.Times;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Location, BarStyle, RepeatDirection, Times);
        }

        public override string ToString()
        {
            var parts = new List<string>();
            if (!string.IsNullOrEmpty(Location)) parts.Add($"location: {Location}");
            if (!string.IsNullOrEmpty(BarStyle)) parts.Add($"barStyle: {BarStyle}");
            if (!string.IsNullOrEmpty(RepeatDirection)) parts.Add($"repeatDirection: {RepeatDirection}");
            if (Times.HasValue) parts.Add($"times: {Times}");
            return $"Barline{{{string.Join(", ", parts)}}}";
        }
    }
}
