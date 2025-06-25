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

        /// <summary>
        /// Creates a new <see cref="TimeSignature"/> instance with validation.
        /// This factory method performs validation against MusicXML rules
        /// (e.g., positive beats, BeatType is a power of 2).
        /// Throws <see cref="MusicXmlValidationException"/> if the time signature is invalid.
        /// </summary>
        /// <param name="beats">The numerator of the time signature.</param>
        /// <param name="beatType">The denominator of the time signature.</param>
        /// <param name="lineNumber">The line number in the XML document (for context in error messages).</param>
        /// <param name="context">Additional context for error messages. Keys and values will be converted to strings.</param>
        /// <returns>A validated <see cref="TimeSignature"/> instance.</returns>
        public static TimeSignature CreateValidated(int beats, int beatType, int? lineNumber = null, Dictionary<string, object>? rawContext = null)
        {
            var timeSignature = new TimeSignature(beats, beatType);

            Dictionary<string, string>? stringContext = null;
            if (rawContext != null)
            {
                stringContext = new Dictionary<string, string>();
                foreach (var item in rawContext)
                {
                    stringContext[item.Key] = item.Value?.ToString() ?? string.Empty;
                }
            }

            ValidationUtils.ValidateTimeSignature(timeSignature, lineNumber?.ToString(), stringContext);
            return timeSignature;
        }

        /// <summary>
        /// Creates a new <see cref="TimeSignature"/> instance from a MusicXML <time> <see cref="XElement"/>.
        /// This factory parses the required <beats> and <beat-type> elements
        /// and then validates the parsed values.
        /// Throws <see cref="MusicXmlStructureException"/> if required XML elements are missing.
        /// Throws <see cref="MusicXmlValidationException"/> if the parsed values are invalid.
        /// </summary>
        /// <param name="element">The XML element representing the <time>.</param>
        /// <param name="partId">The ID of the part (for context in error messages).</param>
        /// <param name="measureNumber">The number of the measure (for context in error messages).</param>
        /// <returns>A <see cref="TimeSignature"/> instance parsed from the XML element.</returns>
        public static TimeSignature FromXmlElement(XElement element, string partId, string measureNumber)
        {
            var elementLineNumber = XmlHelper.GetLineNumber(element);

            var beatsElement = element.Element("beats");
            var beatsElementLineNumber = XmlHelper.GetLineNumber(beatsElement);
            if (beatsElement == null)
            {
                throw new MusicXmlStructureException(
                    "Required <beats> element not found in <time>",
                    requiredElement: "beats",
                    parentElement: "time",
                    line: elementLineNumber?.ToString(),
                    context: new Dictionary<string, string> { { "part", partId }, { "measure", measureNumber } }
                );
            }
            var beatsText = beatsElement.Value.Trim();

            if (!int.TryParse(beatsText, NumberStyles.Integer, CultureInfo.InvariantCulture, out int beats))
            {
                throw new MusicXmlValidationException(
                    $"Invalid time signature beats (numerator) value: \"{beatsText}\". Must be an integer.",
                    rule: "time_beats_invalid",
                    line: beatsElementLineNumber?.ToString() ?? elementLineNumber?.ToString(),
                    context: new Dictionary<string, string> {
                        { "part", partId },
                        { "measure", measureNumber },
                        { "parsedBeats", beatsText }
                    }
                );
            }

            var beatTypeElement = element.Element("beat-type");
            var beatTypeElementLineNumber = XmlHelper.GetLineNumber(beatTypeElement);
            if (beatTypeElement == null)
            {
                throw new MusicXmlStructureException(
                    "Required <beat-type> element not found in <time>",
                    requiredElement: "beat-type",
                    parentElement: "time",
                    line: elementLineNumber?.ToString(),
                    context: new Dictionary<string, string> { { "part", partId }, { "measure", measureNumber } }
                );
            }
            var beatTypeText = beatTypeElement.Value.Trim();

            if (!int.TryParse(beatTypeText, NumberStyles.Integer, CultureInfo.InvariantCulture, out int beatType))
            {
                 throw new MusicXmlValidationException(
                    $"Invalid time signature beat-type (denominator) value: \"{beatTypeText}\". Must be an integer.",
                    rule: "time_beat_type_invalid",
                    line: beatTypeElementLineNumber?.ToString() ?? elementLineNumber?.ToString(),
                    context: new Dictionary<string, string> {
                        { "part", partId },
                        { "measure", measureNumber },
                        { "parsedBeatType", beatTypeText }
                    }
                );
            }

            // Use the .CreateValidated factory to ensure consistent validation logic
            // The context for CreateValidated should be Dictionary<string, object> as per its signature
            return CreateValidated(
                beats: beats,
                beatType: beatType,
                lineNumber: elementLineNumber, // Pass the int? from XmlHelper
                rawContext: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber } }
            );
        }

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
