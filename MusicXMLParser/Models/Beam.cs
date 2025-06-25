using System;
using System.Collections.Generic;
using System.Linq;
using MusicXMLParser.Exceptions; // Assuming this will be created later

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a beam connecting multiple notes within a measure.
    /// A beam visually groups notes (typically eighth notes or shorter) together.
    /// All notes in a beam must belong to the same measure.
    /// </summary>
    public class Beam : IEquatable<Beam>
    {
        /// <summary>
        /// The beam number/level (1 for primary beam, 2 for secondary beam, etc.)
        /// </summary>
        public int Number { get; }

        /// <summary>
        /// The beam type indicating the beam's role
        /// (begin, continue, end, forward hook, backward hook, etc.)
        /// </summary>
        public string? Type { get; }

        /// <summary>
        /// The measure number this beam belongs to.
        /// </summary>
        public string? MeasureNumber { get; }

        /// <summary>
        /// The indices of notes connected by this beam.
        /// The order of indices is significant.
        /// </summary>
        public List<int> NoteIndices { get; }

        /// <summary>
        /// Creates a new <see cref="Beam"/> instance.
        /// </summary>
        public Beam(int number, string? type, string? measureNumber, List<int> noteIndices)
        {
            Number = number;
            Type = type;
            MeasureNumber = measureNumber;
            NoteIndices = noteIndices ?? new List<int>();
        }

        public override bool Equals(object? obj)
        {
            return Equals(obj as Beam);
        }

        public bool Equals(Beam? other)
        {
            return other != null &&
                   Number == other.Number &&
                   Type == other.Type &&
                   MeasureNumber == other.MeasureNumber &&
                   NoteIndices.SequenceEqual(other.NoteIndices);
        }

        public override int GetHashCode()
        {
            var hashCode = new HashCode();
            hashCode.Add(Number);
            hashCode.Add(Type);
            hashCode.Add(MeasureNumber);
            NoteIndices.ForEach(i => hashCode.Add(i));
            return hashCode.ToHashCode();
        }

        public override string ToString() =>
            $"Beam{{number: {Number}, type: {Type}, measureNumber: {MeasureNumber}, noteIndices: [{string.Join(", ", NoteIndices)}]}}";
    }
}
