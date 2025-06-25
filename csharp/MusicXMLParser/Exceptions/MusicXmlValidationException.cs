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
        public string Rule { get; }

        /// <summary>
        /// Additional context information about the validation failure.
        /// </summary>
        public Dictionary<string, string> Context { get; }

        /// <summary>
        /// Creates a new <see cref="MusicXmlValidationException"/> with the given message.
        /// </summary>
        /// <param name="message">A descriptive error message.</param>
        /// <param name="rule">The validation rule that was violated (optional).</param>
        /// <param name="line">The line number where the error occurred (optional).</param>
        /// <param name="node">The XML node where the error occurred (optional).</param>
        /// <param name="context">Additional context information (optional).</param>
        public MusicXmlValidationException(
            string message,
            string rule = null,
            string line = null, // Changed to string
            string node = null,
            Dictionary<string, string> context = null)
            : base(message, line, node)
        {
            Rule = rule;
            Context = context;
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
