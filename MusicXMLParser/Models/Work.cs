using System; // For IEquatable if needed later

namespace MusicXMLParser.Models
{
    public class Work : IEquatable<Work>
    {
        public string? Title { get; } // work-title

        // Other potential fields from MusicXML <work> element:
        // public string? WorkNumber { get; }
        // public string? OpusLink { get; } // attribute of <opus>
        // etc.

        public Work(string? title = null)
        {
            Title = title;
        }

        public override bool Equals(object? obj) => Equals(obj as Work);

        public bool Equals(Work? other) =>
            other != null &&
            Title == other.Title;

        public override int GetHashCode() => HashCode.Combine(Title);

        public override string ToString() => $"Work{{Title: {Title ?? "N/A"}}}";
    }
}
