using System;
using System.Xml.Linq;
using System.Linq;
using MusicXMLParser.Exceptions; // Assuming you will create this namespace for exceptions
using MusicXMLParser.Utils; // Assuming you will create this namespace for utils

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a musical pitch, including its step, octave, and alteration.
    /// </summary>
    /// <remarks>
    /// A pitch is defined by a step (A-G), an octave (0-9), and an optional
    /// alteration (e.g., sharp, flat). This class ensures that pitch values
    /// conform to standard musical notation.
    /// Objects of this class are immutable.
    /// </remarks>
    public class Pitch
    {
        /// <summary>
        /// The musical step of the pitch, represented as a capital letter (C, D, E, F, G, A, B).
        /// </summary>
        public string Step { get; }

        /// <summary>
        /// The octave number (0-9) in which the pitch resides.
        /// </summary>
        public int Octave { get; }

        /// <summary>
        /// The chromatic alteration of the pitch.
        /// </summary>
        /// <remarks>
        /// Positive values represent sharps (e.g., 1 for a single sharp),
        /// negative values represent flats (e.g., -1 for a single flat),
        /// and 0 or null represents no alteration. Typically ranges from -2 to 2.
        /// </remarks>
        public int? Alter { get; }

        /// <summary>
        /// Creates a new <see cref="Pitch"/> instance.
        /// </summary>
        public Pitch(string step, int octave, int? alter = null)
        {
            // Basic validation can be done here if desired, though more complex validation
            // is often handled by factory methods or dedicated validation utilities.
            if (string.IsNullOrWhiteSpace(step))
                throw new ArgumentException("Step cannot be null or empty.", nameof(step));
            if (octave < ValidationUtils.MinOctave || octave > ValidationUtils.MaxOctave) // Assuming ValidationUtils will be ported
                throw new ArgumentOutOfRangeException(nameof(octave), $"Octave must be between {ValidationUtils.MinOctave} and {ValidationUtils.MaxOctave}.");
            if (alter.HasValue && (alter.Value < -2 || alter.Value > 2)) // Example range
                throw new ArgumentOutOfRangeException(nameof(alter), "Alter, if specified, must be between -2 and 2.");


            Step = step;
            Octave = octave;
            Alter = alter;
        }

        /// <summary>
        /// Creates a new <see cref="Pitch"/> instance from an MusicXML &lt;pitch&gt; <paramref name="element"/>.
        /// </summary>
        /// <remarks>
        /// This factory parses the required &lt;step&gt; and &lt;octave&gt; elements,
        /// and the optional &lt;alter&gt; element. It performs validation against
        /// MusicXML rules (e.g., valid pitch steps, octave range, alter range).
        /// Throws <see cref="MusicXmlStructureException"/> if required XML elements are missing.
        /// Throws <see cref="MusicXmlValidationException"/> if the parsed values are invalid
        /// according to MusicXML specifications.
        /// </remarks>
        /// <param name="element">The XML element representing the &lt;pitch&gt;.</param>
        /// <param name="partId">The ID of the part, used for context in error messages.</param>
        /// <param name="measureNumber">The number of the measure, used for context in error messages.</param>
        public static Pitch FromXElement(XElement element, string partId, string measureNumber)
        {
            var line = element.Attribute("line")?.Value; // Or however line numbers are accessed

            var stepElement = element.Element("step");
            if (stepElement == null)
            {
                throw new MusicXmlStructureException(
                    "Required <step> element not found in <pitch>",
                    parentElement: "pitch",
                    line: line,
                    context: new Dictionary<string, string> { { "part", partId }, { "measure", measureNumber } }
                );
            }
            var step = stepElement.Value.Trim();

            var octaveElement = element.Element("octave");
            if (octaveElement == null)
            {
                throw new MusicXmlStructureException(
                    "Required <octave> element not found in <pitch>",
                    parentElement: "pitch",
                    line: line,
                    context: new Dictionary<string, string> { { "part", partId }, { "measure", measureNumber } }
                );
            }
            var octaveText = octaveElement.Value.Trim();
            if (!int.TryParse(octaveText, out var octave))
            {
                 throw new MusicXmlValidationException(
                    $"Invalid octave: \"{octaveText}\". Must be an integer.",
                    rule: "pitch_octave_invalid_format",
                    line: line,
                    context: new Dictionary<string, string> { { "part", partId }, { "measure", measureNumber }, {"parsedOctave", octaveText} }
                );
            }


            var alterElement = element.Element("alter");
            var alterText = alterElement?.Value.Trim();
            int? alter = null;
            if (!string.IsNullOrEmpty(alterText))
            {
                if (!int.TryParse(alterText, out var parsedAlter))
                {
                    throw new MusicXmlValidationException(
                        $"Invalid alter value: \"{alterText}\". If present, must be an integer.",
                        rule: "pitch_alter_invalid_format",
                        line: line,
                        context: new Dictionary<string, string> { { "part", partId }, { "measure", measureNumber }, {"parsedAlter", alterText} }
                    );
                }
                alter = parsedAlter;
            }

            // Perform validation after extracting values
            if (!ValidationUtils.ValidPitchSteps.Contains(step))
            {
                throw new MusicXmlValidationException(
                    $"Invalid pitch step: \"{step}\". Must be one of {string.Join(", ", ValidationUtils.ValidPitchSteps)}.",
                    rule: "pitch_step_invalid",
                    line: line,
                    context: new Dictionary<string, string> { { "part", partId }, { "measure", measureNumber }, { "parsedStep", step } }
                );
            }

            if (octave < ValidationUtils.MinOctave || octave > ValidationUtils.MaxOctave)
            {
                throw new MusicXmlValidationException(
                    $"Invalid octave: \"{octaveText}\". Must be an integer between {ValidationUtils.MinOctave} and {ValidationUtils.MaxOctave}.",
                    rule: "pitch_octave_invalid_range",
                    line: line,
                    context: new Dictionary<string, string> { { "part", partId }, { "measure", measureNumber }, { "parsedOctave", octaveText } }
                );
            }

            if (alter.HasValue && (alter.Value < -2 || alter.Value > 2)) // Example range, align with ValidationUtils if it has specific constants
            {
                throw new MusicXmlValidationException(
                    $"Invalid alter value: \"{alterText}\". If present, must be an integer between -2 and 2.",
                    rule: "pitch_alter_invalid_range",
                    line: line,
                    context: new Dictionary<string, string> { { "part", partId }, { "measure", measureNumber }, { "parsedAlter", alterText } }
                );
            }

            return new Pitch(step, octave, alter);
        }


        public override bool Equals(object obj)
        {
            if (obj is Pitch other)
            {
                return Step == other.Step &&
                       Octave == other.Octave &&
                       Alter == other.Alter;
            }
            return false;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Step, Octave, Alter);
        }

        public override string ToString() => $"Pitch{{Step: {Step}, Octave: {Octave}, Alter: {Alter?.ToString() ?? "null"}}}";
    }
}
