using MusicXMLParser.Models; // Assuming your models are in this namespace
using MusicXMLParser.Exceptions; // Assuming your exceptions are in this namespace
using System;
using System.Collections.Generic;
using System.Linq;

namespace MusicXMLParser.Utils
{
    /// <summary>
    /// Utility class containing validation rules for MusicXML elements.
    /// </summary>
    /// <remarks>
    /// This class provides static methods for validating various musical elements
    /// to ensure they conform to musical theory and MusicXML specifications.
    /// </remarks>
    public static class ValidationUtils
    {
        /// <summary>
        /// Valid pitch steps in musical notation.
        /// </summary>
        public static readonly ISet<string> ValidPitchSteps = new HashSet<string> { "C", "D", "E", "F", "G", "A", "B" };

        /// <summary>
        /// Minimum valid octave number.
        /// </summary>
        public const int MinOctave = 0;

        /// <summary>
        /// Maximum valid octave number.
        /// </summary>
        public const int MaxOctave = 9;

        /// <summary>
        /// Minimum valid key signature fifths value.
        /// </summary>
        public const int MinFifths = -7;

        /// <summary>
        /// Maximum valid key signature fifths value.
        /// </summary>
        public const int MaxFifths = 7;

        /// <summary>
        /// Valid key signature modes.
        /// </summary>
        public static readonly ISet<string> ValidModes = new HashSet<string>
        {
            "major", "minor", "dorian", "phrygian", "lydian",
            "mixolydian", "aeolian", "ionian", "locrian"
        };

        /// <summary>
        /// Validates a pitch object.
        /// </summary>
        /// <remarks>
        /// Checks that the pitch step is valid (C, D, E, F, G, A, B) and
        /// the octave is within the valid range (0-9).
        /// Throws <see cref="MusicXmlValidationException"/> if validation fails.
        /// </remarks>
        public static void ValidatePitch(Pitch pitch, string line = null, Dictionary<string, string> context = null)
        {
            if (pitch == null) throw new ArgumentNullException(nameof(pitch));

            // Validate step
            if (!ValidPitchSteps.Contains(pitch.Step))
            {
                throw new MusicXmlValidationException(
                    $"Invalid pitch step \"{pitch.Step}\". Expected one of: {string.Join(", ", ValidPitchSteps)}",
                    rule: "pitch_step_validation",
                    line: line,
                    context: MergeContext(new Dictionary<string, string>
                    {
                        { "step", pitch.Step },
                        { "octave", pitch.Octave.ToString() },
                        { "alter", pitch.Alter?.ToString() }
                    }, context)
                );
            }

            // Validate octave
            if (pitch.Octave < MinOctave || pitch.Octave > MaxOctave)
            {
                throw new MusicXmlValidationException(
                    $"Pitch octave {pitch.Octave} is out of valid range ({MinOctave}-{MaxOctave})",
                    rule: "pitch_octave_validation",
                    line: line,
                    context: MergeContext(new Dictionary<string, string>
                    {
                        { "step", pitch.Step },
                        { "octave", pitch.Octave.ToString() },
                        { "alter", pitch.Alter?.ToString() }
                    }, context)
                );
            }

            // Validate alter (alteration should be reasonable)
            if (pitch.Alter.HasValue && (pitch.Alter.Value < -2 || pitch.Alter.Value > 2))
            {
                throw new MusicXmlValidationException(
                    $"Pitch alteration {pitch.Alter} is out of reasonable range (-2 to +2)",
                    rule: "pitch_alter_validation",
                    line: line,
                    context: MergeContext(new Dictionary<string, string>
                    {
                        { "step", pitch.Step },
                        { "octave", pitch.Octave.ToString() },
                        { "alter", pitch.Alter?.ToString() }
                    }, context)
                );
            }
        }

        /// <summary>
        /// Validates a duration object.
        /// </summary>
        /// <remarks>
        /// Checks that the duration value is positive.
        /// Throws <see cref="MusicXmlValidationException"/> if validation fails.
        /// </remarks>
        public static void ValidateDuration(Duration duration, string line = null, Dictionary<string, string> context = null)
        {
            if (duration == null) throw new ArgumentNullException(nameof(duration));

            if (duration.Value <= 0)
            {
                throw new MusicXmlValidationException(
                    $"Duration value must be positive, got {duration.Value}",
                    rule: "duration_positive_validation",
                    line: line,
                    context: MergeContext(new Dictionary<string, string>
                    {
                        { "value", duration.Value.ToString() },
                        { "divisions", duration.Divisions.ToString() }
                    }, context)
                );
            }

            if (duration.Divisions <= 0)
            {
                throw new MusicXmlValidationException(
                    $"Duration divisions must be positive, got {duration.Divisions}",
                    rule: "duration_divisions_validation",
                    line: line,
                    context: MergeContext(new Dictionary<string, string>
                    {
                        { "value", duration.Value.ToString() },
                        { "divisions", duration.Divisions.ToString() }
                    }, context)
                );
            }
        }

        /// <summary>
        /// Validates a key signature object.
        /// </summary>
        /// <remarks>
        /// Checks that the fifths value is within the valid range (-7 to +7)
        /// and the mode is valid if specified.
        /// Throws <see cref="MusicXmlValidationException"/> if validation fails.
        /// </remarks>
        public static void ValidateKeySignature(KeySignature keySignature, string line = null, Dictionary<string, string> context = null)
        {
            if (keySignature == null) throw new ArgumentNullException(nameof(keySignature));

            // Validate fifths
            if (keySignature.Fifths < MinFifths || keySignature.Fifths > MaxFifths)
            {
                throw new MusicXmlValidationException(
                    $"Key signature fifths {keySignature.Fifths} is out of valid range ({MinFifths} to {MaxFifths})",
                    rule: "key_signature_fifths_validation",
                    line: line,
                    context: MergeContext(new Dictionary<string, string>
                    {
                        { "fifths", keySignature.Fifths.ToString() },
                        { "mode", keySignature.Mode }
                    }, context)
                );
            }

            // Validate mode if specified
            if (!string.IsNullOrEmpty(keySignature.Mode) && !ValidModes.Contains(keySignature.Mode.ToLower()))
            {
                throw new MusicXmlValidationException(
                    $"Invalid key signature mode \"{keySignature.Mode}\". Expected one of: {string.Join(", ", ValidModes)}",
                    rule: "key_signature_mode_validation",
                    line: line,
                    context: MergeContext(new Dictionary<string, string>
                    {
                        { "fifths", keySignature.Fifths.ToString() },
                        { "mode", keySignature.Mode }
                    }, context)
                );
            }
        }

        /// <summary>
        /// Validates a time signature object.
        /// </summary>
        /// <remarks>
        /// Checks that beats is positive and beat type is a power of 2.
        /// Throws <see cref="MusicXmlValidationException"/> if validation fails.
        /// </remarks>
        public static void ValidateTimeSignature(TimeSignature timeSignature, string line = null, Dictionary<string, string> context = null)
        {
            if (timeSignature == null) throw new ArgumentNullException(nameof(timeSignature));

            // Validate beats
            if (timeSignature.Beats <= 0)
            {
                throw new MusicXmlValidationException(
                    $"Time signature beats must be positive, got {timeSignature.Beats}",
                    rule: "time_signature_beats_validation",
                    line: line,
                    context: MergeContext(new Dictionary<string, string>
                    {
                        { "beats", timeSignature.Beats.ToString() },
                        { "beatType", timeSignature.BeatType.ToString() }
                    }, context)
                );
            }

            // Validate beat type (should be a power of 2)
            if (timeSignature.BeatType <= 0 || !IsPowerOfTwo(timeSignature.BeatType))
            {
                throw new MusicXmlValidationException(
                    $"Time signature beat type must be a positive power of 2, got {timeSignature.BeatType}",
                    rule: "time_signature_beat_type_validation",
                    line: line,
                    context: MergeContext(new Dictionary<string, string>
                    {
                        { "beats", timeSignature.Beats.ToString() },
                        { "beatType", timeSignature.BeatType.ToString() }
                    }, context)
                );
            }
        }

        /// <summary>
        /// Validates a note object.
        /// </summary>
        /// <remarks>
        /// Performs comprehensive validation including pitch validation for non-rest notes
        /// and duration validation.
        /// Throws <see cref="MusicXmlValidationException"/> if validation fails.
        /// </remarks>
        public static void ValidateNote(Note note, string line = null, Dictionary<string, string> context = null)
        {
            if (note == null) throw new ArgumentNullException(nameof(note));

            // Validate duration if present
            if (note.Duration != null) // Assuming Duration is a class/struct and can be null
            {
                ValidateDuration(note.Duration, line: line, context: context);
            }

            // Validate pitch if not a rest
            if (!note.IsRest && note.Pitch != null) // Assuming Pitch is a class/struct and can be null
            {
                ValidatePitch(note.Pitch, line: line, context: context);
            }

            // Validate voice (should be positive if specified)
            if (note.Voice.HasValue && note.Voice.Value <= 0)
            {
                throw new MusicXmlValidationException(
                    $"Note voice must be positive, got {note.Voice}",
                    rule: "note_voice_validation",
                    line: line,
                    context: MergeContext(new Dictionary<string, string>
                    {
                        { "voice", note.Voice?.ToString() },
                        { "isRest", note.IsRest.ToString() }
                    }, context)
                );
            }

            // Validate that rests don't have pitches
            if (note.IsRest && note.Pitch != null)
            {
                throw new MusicXmlValidationException(
                    "Rest notes should not have pitch information",
                    rule: "rest_no_pitch_validation",
                    line: line,
                    context: MergeContext(new Dictionary<string, string>
                    {
                        { "isRest", note.IsRest.ToString() },
                        { "hasPitch", (note.Pitch != null).ToString() }
                    }, context)
                );
            }

            // Validate that non-rest notes have pitches (unless it's a special case like unpitched percussion)
            // This might need refinement based on how unpitched notes are represented.
            if (!note.IsRest && note.Pitch == null && !note.IsUnpitched) // Assuming an IsUnpitched property or similar
            {
                throw new MusicXmlValidationException(
                    "Non-rest, pitched notes must have pitch information",
                    rule: "note_pitch_required_validation",
                    line: line,
                    context: MergeContext(new Dictionary<string, string>
                    {
                        { "isRest", note.IsRest.ToString() },
                        { "hasPitch", (note.Pitch != null).ToString() },
                        {"isUnpitched", note.IsUnpitched.ToString()}
                    }, context)
                );
            }
        }

        // Placeholder for IsUnpitched if not directly on Note model
        // Example: Adapt based on your Note model structure
        // private static bool IsNoteUnpitched(Note note) => note.Unpitched != null;


        /// <summary>
        /// Validates that measure duration matches the time signature.
        /// </summary>
        /// <remarks>
        /// This is a simplified validation - a complete implementation would need
        /// to handle complex rhythmic patterns, grace notes, etc.
        /// Throws <see cref="MusicXmlValidationException"/> if validation fails.
        /// </remarks>
        public static void ValidateMeasureDuration(
            List<Note> notes,
            TimeSignature timeSignature,
            int? divisions,
            string line = null,
            Dictionary<string, string> context = null)
        {
            if (notes == null) throw new ArgumentNullException(nameof(notes));
            if (timeSignature == null || !divisions.HasValue)
            {
                return; // Can't validate without time signature and divisions
            }

            // Calculate expected measure duration in divisions
            var expectedDuration =
                (timeSignature.Beats * divisions.Value * 4) / timeSignature.BeatType;

            // Calculate actual duration from notes (skip notes without duration)
            long actualDuration = 0; // Use long to avoid overflow if many notes
            foreach (var note in notes)
            {
                if (note.Duration != null)
                {
                    actualDuration += note.Duration.Value;
                }
            }

            if (actualDuration != expectedDuration)
            {
                throw new MusicXmlValidationException(
                    $"Measure duration ({actualDuration}) does not match time signature expectation ({expectedDuration})",
                    rule: "measure_duration_validation",
                    line: line,
                    context: MergeContext(new Dictionary<string, string>
                    {
                        { "actualDuration", actualDuration.ToString() },
                        { "expectedDuration", expectedDuration.ToString() },
                        { "timeSignature", $"{timeSignature.Beats}/{timeSignature.BeatType}" },
                        { "divisions", divisions.Value.ToString() },
                        { "noteCount", notes.Count.ToString() }
                    }, context)
                );
            }
        }


        /// <summary>
        /// Helper method to check if a number is a power of 2.
        /// </summary>
        private static bool IsPowerOfTwo(int n)
        {
            return n > 0 && (n & (n - 1)) == 0;
        }

        /// <summary>
        /// Helper method to merge base context with additional context.
        /// </summary>
        private static Dictionary<string, string> MergeContext(Dictionary<string, string> baseContext, Dictionary<string, string> additionalContext)
        {
            if (additionalContext == null) return baseContext;
            if (baseContext == null) return additionalContext;

            var merged = new Dictionary<string, string>(baseContext);
            foreach (var item in additionalContext)
            {
                merged[item.Key] = item.Value; // Overwrites if key exists, which is typical for context override
            }
            return merged;
        }
    }
}
