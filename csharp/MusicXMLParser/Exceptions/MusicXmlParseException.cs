using System;

namespace MusicXMLParser.Exceptions
{
    public class MusicXmlParseException : Exception
    {
        public MusicXmlParseException() { }
        public MusicXmlParseException(string message) : base(message) { }
        public MusicXmlParseException(string message, Exception innerException) : base(message, innerException) { }

        // Custom properties if needed, similar to Dart version (e.g., line, context)
        public string? ElementName { get; }
        public int Line { get; }
        public object? Context { get; } // Or a more specific type like Dictionary<string, object>

        public MusicXmlParseException(string message, string? elementName = null, int line = -1, object? context = null, Exception? innerException = null)
            : base(message, innerException)
        {
            ElementName = elementName;
            Line = line;
            Context = context ?? new Dictionary<string, object>(); // Initialize if null
        }
    }
}
