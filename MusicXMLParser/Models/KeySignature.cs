using System;
using System.Collections.Generic;
using System.Xml.Linq;
using MusicXMLParser.Exceptions; // Assuming these will be created later
using MusicXMLParser.Utils; // Assuming these will be created later
using MusicXMLParser.Parser; // Assuming XmlHelper will be here

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a key signature in a musical score.
    /// A key signature is defined by the number of sharps or flats (fifths)
    /// and an optional mode (e.g., major, minor).
    /// Objects of this class are immutable.
    /// </summary>
    public class KeySignature : IEquatable<KeySignature>
    {
        /// <summary>
        /// The number of sharps (positive value) or flats (negative value)
        /// in the key signature. Typically ranges from -7 to 7.
        /// </summary>
        public int Fifths { get; }

        /// <summary>
        /// The mode of the key signature (e.g., "major", "minor", "dorian").
        /// This is optional as per MusicXML specification.
        /// </summary>
        public string? Mode { get; }

        /// <summary>
        /// Creates a new <see cref="KeySignature"/> instance.
        /// It's recommended to use <see cref="Validated"/> or <see cref="FromXElement"/>
        /// for creating instances, as they include validation.
        /// </summary>
        public KeySignature(int fifths, string? mode = null)
        {
            Fifths = fifths;
            Mode = mode;
        }

        // Removed Validated and FromXElement static methods as per user request to defer validation.
        // Parsing logic formerly in FromXElement will be moved to AttributesParser.

        public override bool Equals(object? obj) => Equals(obj as KeySignature);

        public bool Equals(KeySignature? other) =>
            other != null &&
            Fifths == other.Fifths &&
            Mode == other.Mode;

        public override int GetHashCode() => HashCode.Combine(Fifths, Mode);

        public override string ToString() => $"KeySignature{{fifths: {Fifths}, mode: {Mode}}}";
    }
}
