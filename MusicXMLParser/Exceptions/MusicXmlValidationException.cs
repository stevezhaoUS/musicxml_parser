using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MusicXMLParser.Exceptions
{
    /// <summary>
    /// Exception thrown when MusicXML content violates musical rules or constraints.
    /// </summary>
    /// <remarks>
    /// This exception is used for errors related to musical validation, such as
    /// invalid pitch ranges, incorrect measure durations, or inconsistent voice assignments.
    /// </remarks>
    public class MusicXmlValidationException : InvalidMusicXmlException
    {
        /// <summary>
        /// The specific validation rule that was violated.
        /// </summary>
        public string? Rule { get; }

        /// <summary>
        /// Additional context information about the validation failure.
        /// </summary>
        public Dictionary<string, object>? Context { get; } // Changed to Dictionary<string, object>

        /// <summary>
        /// Creates a new <see cref="MusicXmlValidationException"/> with the given message.
        /// </summary>
        /// <param name="message">A descriptive error message.</param>
        /// <param name="rule">The validation rule that was violated (optional).</param>
        /// <param name="line">The line number where the error occurred (optional).</param>
        /// <param name="node">The XML node where the error occurred (optional). For validation, this might be less relevant than context.</param>
        /// <param name="context">Additional context information (optional).</param>
        public MusicXmlValidationException(
            string message,
            string? rule = null,
            int line = -1, // Changed to int
            string? node = null, // Made node nullable
            Dictionary<string, object>? context = null) // Context is Dictionary<string, object>
            : base(message, line.ToString(), node)
        {
            Rule = rule;
            Context = context ?? new Dictionary<string, object>();
        }

        public override string ToString()
        {
            var buffer = new StringBuilder($"MusicXmlValidationException: {Message}");

            if (!string.IsNullOrEmpty(Rule))
            {
                buffer.Append($" [rule: {Rule}]");
            }

            if (!string.IsNullOrEmpty(Node))
            {
                buffer.Append($" (node: {Node}");
                if (!string.IsNullOrEmpty(Line)) // Line is string
                {
                    buffer.Append($", line: {Line}");
                }
                buffer.Append(")");
            }
            else if (!string.IsNullOrEmpty(Line))
            {
                buffer.Append($" (line: {Line})");
            }

            if (Context != null && Context.Any())
            {
                buffer.Append($" [context: {string.Join(", ", Context.Select(kv => $"{kv.Key}={kv.Value}"))}]");
            }

            return buffer.ToString();
        }
    }
}
