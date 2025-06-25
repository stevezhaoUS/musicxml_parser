using System;
using System.Text;

namespace MusicXMLParser.Exceptions
{
    /// <summary>
    /// Base exception for errors encountered during MusicXML parsing or validation.
    /// </summary>
    public class InvalidMusicXmlException : Exception
    {
        /// <summary>
        /// The XML node content or identifier where the error occurred, if available.
        /// </summary>
        public string? Node { get; }

        /// <summary>
        /// The line number in the XML file where the error occurred, if available.
        /// </summary>
        public string? Line { get; }

        /// <summary>
        /// Creates a new <see cref="InvalidMusicXmlException"/> with the given message.
        /// </summary>
        /// <param name="message">The error message.</param>
        /// <param name="line">The line number where the error occurred (optional).</param>
        /// <param name="node">The XML node where the error occurred (optional).</param>
        public InvalidMusicXmlException(string message, string? line = null, string? node = null)
            : base(message)
        {
            Node = node;
            Line = line;
        }

        /// <summary>
        /// Creates a new <see cref="InvalidMusicXmlException"/> with the given message and inner exception.
        /// </summary>
        /// <param name="message">The error message.</param>
        /// <param name="innerException">The inner exception.</param>
        /// <param name="line">The line number where the error occurred (optional).</param>
        /// <param name="node">The XML node where the error occurred (optional).</param>
        public InvalidMusicXmlException(string message, Exception? innerException, string? line = null, string? node = null)
            : base(message, innerException)
        {
            Node = node;
            Line = line;
        }

        public override string ToString()
        {
            var buffer = new StringBuilder($"{GetType().Name}: {Message}"); // Use GetType().Name for specific exception type
            if (!string.IsNullOrEmpty(Node))
            {
                buffer.Append($" (node: {Node}");
                if (!string.IsNullOrEmpty(Line))
                {
                    buffer.Append($", line: {Line}");
                }
                buffer.Append(")");
            }
            else if (!string.IsNullOrEmpty(Line))
            {
                buffer.Append($" (line: {Line})");
            }
            return buffer.ToString();
        }
    }
}
