using System;
using System.Collections.Generic;
using System.Text;

namespace MusicXMLParser.Exceptions
{
    /// <summary>
    /// Exception thrown when MusicXML content has structural problems.
    /// </summary>
    /// <remarks>
    /// This exception is used for errors related to the overall structure of the
    /// MusicXML document, such as missing required elements, invalid element hierarchy,
    /// or incorrect document format.
    /// </remarks>
    public class MusicXmlStructureException : InvalidMusicXmlException
    {
        /// <summary>
        /// The required element that is missing or invalid.
        /// </summary>
        public string RequiredElement { get; }

        /// <summary>
        /// The parent element where the structure problem occurred.
        /// </summary>
        public string ParentElement { get; }

        /// <summary>
        /// Additional context information about the structural problem.
        /// </summary>
        public Dictionary<string, string> Context { get; }

        /// <summary>
        /// An optional rule identifier associated with this structural error.
        /// </summary>
        public string Rule { get; }

        /// <summary>
        /// Creates a new <see cref="MusicXmlStructureException"/> with the given message.
        /// </summary>
        /// <param name="message">A descriptive error message.</param>
        /// <param name="requiredElement">The required element that is missing or invalid (optional).</param>
        /// <param name="parentElement">The parent element where the problem occurred (optional).</param>
        /// <param name="line">The line number where the error occurred (optional).</param>
        /// <param name="node">The XML node where the error occurred (optional).</param>
        /// <param name="context">Additional context information (optional).</param>
        /// <param name="rule">An optional rule identifier (optional).</param>
        public MusicXmlStructureException(
            string message,
            string requiredElement = null,
            string parentElement = null,
            string line = null, // Changed to string to match Pitch.cs
            string node = null,
            Dictionary<string, string> context = null,
            string rule = null)
            : base(message, line, node)
        {
            RequiredElement = requiredElement;
            ParentElement = parentElement;
            Context = context;
            Rule = rule;
        }

        public override string ToString()
        {
            var buffer = new StringBuilder($"MusicXmlStructureException: {Message}");

            if (!string.IsNullOrEmpty(RequiredElement))
            {
                buffer.Append($" [required: {RequiredElement}");
                if (!string.IsNullOrEmpty(ParentElement))
                {
                    buffer.Append($" in {ParentElement}");
                }
                buffer.Append("]");
            }

            if (!string.IsNullOrEmpty(Node)) // Assuming Node and Line are properties in Base
            {
                buffer.Append($" (node: {Node}");
                if (!string.IsNullOrEmpty(Line)) // Assuming Line is a string property in Base
                {
                    buffer.Append($", line: {Line}");
                }
                buffer.Append(")");
            }
            else if (!string.IsNullOrEmpty(Line))
            {
                buffer.Append($" (line: {Line})");
            }

            if (Context != null && Context.Count > 0)
            {
                buffer.Append($" [context: {string.Join(", ", Context.Select(kv => $"{kv.Key}={kv.Value}"))}]");
            }

            if (!string.IsNullOrEmpty(Rule))
            {
                buffer.Append($" [rule: {Rule}]");
            }

            return buffer.ToString();
        }
    }
}
