using System;
using System.Collections.Generic;

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a repeat ending in MusicXML (e.g., 1st or 2nd ending).
    /// </summary>
    public class Ending : IEquatable<Ending>
    {
        /// <summary>
        /// The ending number(s), as a string (e.g., "1", "2", "1,3").
        /// This corresponds to the text content of the <ending> element in MusicXML 2.0,
        /// or the 'number' attribute in MusicXML 3.0+. For simplicity, we'll assume
        /// it's parsed from the 'number' attribute.
        /// </summary>
        public string Number { get; }

        /// <summary>
        /// The type of ending mark (e.g., "start", "stop", "discontinue").
        /// Corresponds to the 'type' attribute of the <ending> element.
        /// </summary>
        public string Type { get; }

        /// <summary>
        /// Indicates whether the ending text should be printed (e.g., "yes", "no").
        /// Corresponds to the 'print-object' attribute. Defaults to "yes".
        /// </summary>
        public string PrintObject { get; }

        /// <summary>
        /// Creates a new <see cref="Ending"/> instance.
        /// </summary>
        public Ending(string number, string type, string printObject = "yes")
        {
            Number = number;
            Type = type;
            PrintObject = printObject; // MusicXML default for print-object is "yes"
        }

        public override bool Equals(object obj) => Equals(obj as Ending);

        public bool Equals(Ending other) =>
            other != null &&
            Number == other.Number &&
            Type == other.Type &&
            PrintObject == other.PrintObject;

        public override int GetHashCode() => HashCode.Combine(Number, Type, PrintObject);

        public override string ToString()
        {
            var parts = new List<string>
            {
                $"number: {Number}",
                $"type: {Type}"
            };
            if (PrintObject != "yes") // Only show if not default
            {
                parts.Add($"printObject: {PrintObject}");
            }
            return $"Ending{{{string.Join(", ", parts)}}}";
        }
    }
}
