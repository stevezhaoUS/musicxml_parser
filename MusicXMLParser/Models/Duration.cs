using System;
using System.Collections.Generic;
using MusicXMLParser.Utils; // Assuming this will be created later
using MusicXMLParser.Exceptions; // Assuming this will be created later

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents the duration of a note or rest in a musical score.
    /// </summary>
    public class Duration : IEquatable<Duration>
    {
        /// <summary>
        /// The duration value, in divisions per quarter note.
        /// </summary>
        public int Value { get; }

        /// <summary>
        /// The number of divisions per quarter note in the score.
        /// </summary>
        public int Divisions { get; }

        /// <summary>
        /// Creates a new <see cref="Duration"/> instance.
        /// Both <paramref name="value"/> and <paramref name="divisions"/> must be positive.
        /// </summary>
        public Duration(int value, int divisions)
        {
            Value = value;
            Divisions = divisions;
        }

        /// <summary>
        /// Creates a new <see cref="Duration"/> instance with validation.
        /// This factory method performs validation and throws
        /// <see cref="MusicXmlValidationException"/> if the duration values are invalid.
        /// </summary>
        public static Duration Validated(int value, int divisions, int? line = null, Dictionary<string, object> context = null)
        {
            var duration = new Duration(value, divisions);
            // Assuming ValidationUtils.ValidateDuration will be ported
            ValidationUtils.ValidateDuration(duration, line, context);
            return duration;
        }

        /// <summary>
        /// Gets the duration in quarter notes.
        /// </summary>
        public double InQuarterNotes => (double)Value / Divisions;

        public override bool Equals(object obj) => Equals(obj as Duration);

        public bool Equals(Duration other) =>
            other != null &&
            Value == other.Value &&
            Divisions == other.Divisions;

        public override int GetHashCode() => HashCode.Combine(Value, Divisions);

        public override string ToString() => $"Duration{{value: {Value}, divisions: {Divisions}}}";
    }
}
