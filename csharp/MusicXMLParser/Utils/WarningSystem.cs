using System.Collections.Generic;
using System; // For Console.WriteLine as a placeholder

namespace MusicXMLParser.Utils
{
    // Placeholder for WarningCategories if not defined elsewhere
    public enum WarningCategories
    {
        Structure,
        Validation,
        NoteDivisions, // From NoteParser
        Duration,      // From NoteParser
        Generic,
        // Add other categories as they are identified
    }

    public class Warning
    {
        public string Message { get; }
        public WarningCategories Category { get; }
        public string? Rule { get; }
        public int Line { get; }
        public string? ElementName {get; }
        public Dictionary<string, object> Context { get; } // Keep as non-nullable, initialized to empty if null

        public Warning(string message, WarningCategories category, string? rule = null, int line = -1, string? elementName = null, Dictionary<string, object>? context = null)
        {
            Message = message ?? string.Empty; // Ensure message is not null
            Category = category;
            Rule = rule;
            Line = line;
            ElementName = elementName;
            Context = context ?? new Dictionary<string, object>();
        }

        public override string ToString()
        {
            return $"[Line {Line}, Element {ElementName ?? "N/A"}, Rule {Rule ?? "N/A"}] {Category}: {Message} {string.Join(", ", Context.Select(kv => kv.Key + "=" + kv.Value))}";
        }
    }

    public class WarningSystem
    {
        private readonly List<Warning> _warnings = new List<Warning>();
        public IReadOnlyList<Warning> Warnings => _warnings.AsReadOnly();

        public void AddWarning(string message, WarningCategories category, string? rule = null, int line = -1, string? elementName = null, Dictionary<string, object>? context = null)
        {
            var warning = new Warning(message, category, rule, line, elementName, context);
            _warnings.Add(warning);
            // For now, just print to console. In a real app, this might log to a file or UI.
            Console.WriteLine($"Warning: {warning.ToString()}");
        }

        // Removing this ambiguous overload. The main overload with all optional parameters should suffice.
        // public void AddWarning(string message, WarningCategories category, string? elementName = null, int line = -1, Dictionary<string, object>? context = null)
        // {
        //      AddWarning(message, category, null, line, elementName, context);
        // }


        public void ClearWarnings()
        {
            _warnings.Clear();
        }
    }
}
