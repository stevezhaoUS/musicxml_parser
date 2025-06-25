using System;
using System.Xml.Linq;
using System.Globalization; // Required for int.Parse in a robust way
using System.Collections.Generic; // Required for Dictionary
using MusicXMLParser.Exceptions;
using MusicXMLParser.Utils;

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a time signature in a musical score.
    /// A time signature is defined by a numerator (Beats) indicating the number
    /// of beats per measure, and a denominator (BeatType) indicating the
    /// note value that represents one beat.
    /// </summary>
    public class TimeSignature : IEquatable<TimeSignature>
    {
        /// <summary>
        /// The numerator of the time signature, indicating the number of beats per measure.
        /// Must be a positive integer.
        /// </summary>
        public int Beats { get; }

        /// <summary>
        /// The denominator of the time signature, indicating the note value that
        /// represents one beat (e.g., 4 for a quarter note, 2 for a half note).
        /// Must be a positive power of 2.
        /// </summary>
        public int BeatType { get; }

        /// <summary>
        /// Creates a new <see cref="TimeSignature"/> instance.
        /// It's recommended to use <see cref="CreateValidated"/> or
        /// <see cref="FromXmlElement"/> for creating instances, as they include
        /// validation against MusicXML rules.
        /// </summary>
        public TimeSignature(int beats, int beatType)
        {
            Beats = beats;
            BeatType = beatType;
        }

        // Removed CreateValidated and FromXmlElement static methods as per user request to defer validation.
        // Parsing logic formerly in FromXmlElement will be moved to AttributesParser.

        public override bool Equals(object? obj)
        {
            return Equals(obj as TimeSignature);
        }

        public bool Equals(TimeSignature? other)
        {
            if (other is null)
            {
                return false;
            }
            if (ReferenceEquals(this, other))
            {
                return true;
            }
            return Beats == other.Beats && BeatType == other.BeatType;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Beats, BeatType);
        }

        public override string ToString()
        {
            return $"TimeSignature{{{Beats}/{BeatType}}}";
        }

        public static bool operator ==(TimeSignature? left, TimeSignature? right)
        {
            if (left is null)
            {
                return right is null;
            }
            return left.Equals(right);
        }

        public static bool operator !=(TimeSignature? left, TimeSignature? right)
        {
            return !(left == right);
        }
    }
}
