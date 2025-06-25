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
        public string Mode { get; }

        /// <summary>
        /// Creates a new <see cref="KeySignature"/> instance.
        /// It's recommended to use <see cref="Validated"/> or <see cref="FromXElement"/>
        /// for creating instances, as they include validation.
        /// </summary>
        public KeySignature(int fifths, string mode = null)
        {
            Fifths = fifths;
            Mode = mode;
        }

        /// <summary>
        /// Creates a new <see cref="KeySignature"/> instance with validation.
        /// This factory method performs validation against MusicXML rules
        /// (e.g., fifths within range, valid mode if specified).
        /// Throws <see cref="MusicXmlValidationException"/> if the key signature is invalid.
        /// </summary>
        public static KeySignature Validated(int fifths, string mode = null, int? line = null, Dictionary<string, object> context = null)
        {
            var keySignature = new KeySignature(fifths, mode);
            // ValidationUtils.ValidateKeySignature will throw if invalid.
            ValidationUtils.ValidateKeySignature(keySignature, line, context);
            return keySignature;
        }

        /// <summary>
        /// Creates a new <see cref="KeySignature"/> instance from a MusicXML <key> <paramref name="element"/>.
        /// This factory parses the required <fifths> element and the optional
        /// <mode> element. It then validates the parsed values.
        /// Throws <see cref="MusicXmlStructureException"/> if required XML elements are missing.
        /// Throws <see cref="MusicXmlValidationException"/> if the parsed values are invalid.
        /// </summary>
        public static KeySignature FromXElement(XElement element, string partId, string measureNumber)
        {
            var line = XmlHelper.GetLineNumber(element);

            var fifthsElement = element.Element("fifths");
            if (fifthsElement == null)
            {
                throw new MusicXmlStructureException(
                    "Required <fifths> element not found in <key>",
                    parentElement: "key",
                    line: line,
                    context: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber } }
                );
            }
            var fifthsText = fifthsElement.Value.Trim();
            if (!int.TryParse(fifthsText, out var fifths))
            {
                throw new MusicXmlValidationException(
                    $"Invalid key signature fifths value: \"{fifthsText}\". Must be an integer.",
                    rule: "key_fifths_invalid",
                    line: XmlHelper.GetLineNumber(fifthsElement),
                    context: new Dictionary<string, object>
                    {
                        { "part", partId },
                        { "measure", measureNumber },
                        { "parsedFifths", fifthsText }
                    }
                );
            }

            var modeElement = element.Element("mode");
            var mode = modeElement?.Value.Trim();

            // Use the .Validated factory to ensure consistent validation logic
            return Validated(
                fifths: fifths,
                mode: mode,
                line: line,
                context: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber } }
            );
        }

        public override bool Equals(object obj) => Equals(obj as KeySignature);

        public bool Equals(KeySignature other) =>
            other != null &&
            Fifths == other.Fifths &&
            Mode == other.Mode;

        public override int GetHashCode() => HashCode.Combine(Fifths, Mode);

        public override string ToString() => $"KeySignature{{fifths: {Fifths}, mode: {Mode}}}";
    }
}
