using System;
using System.Collections.Generic;
using System.Linq;

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a credit in a MusicXML score, such as titles, composer names, etc.
    /// </summary>
    public class Credit : IEquatable<Credit>
    {
        /// <summary>
        /// The page number where the credit appears. Optional.
        /// </summary>
        public int? Page { get; }

        /// <summary>
        /// The type of credit (e.g., "title", "subtitle", "composer").
        /// Corresponds to the text content of the <credit-type> element. Optional.
        /// </summary>
        public string? CreditType { get; }

        /// <summary>
        /// The words of the credit. A single <credit> can have multiple <credit-words> elements.
        /// Corresponds to the text content of <credit-words> elements. Defaults to an empty list.
        /// </summary>
        public List<string> CreditWords { get; }

        /// <summary>
        /// Creates a new <see cref="Credit"/> instance.
        /// </summary>
        public Credit(int? page = null, string? creditType = null, List<string> creditWords = null)
        {
            Page = page;
            CreditType = creditType;
            CreditWords = creditWords ?? new List<string>();
        }

        public override bool Equals(object? obj)
        {
            return Equals(obj as Credit);
        }

        public bool Equals(Credit? other)
        {
            return other != null &&
                   Page == other.Page &&
                   CreditType == other.CreditType &&
                   CreditWords.SequenceEqual(other.CreditWords);
        }

        public override int GetHashCode()
        {
            var hashCode = new HashCode();
            hashCode.Add(Page);
            hashCode.Add(CreditType);
            CreditWords.ForEach(w => hashCode.Add(w));
            return hashCode.ToHashCode();
        }

        public override string ToString()
        {
            var parts = new List<string>();
            if (Page.HasValue) parts.Add($"page: {Page}");
            if (!string.IsNullOrEmpty(CreditType)) parts.Add($"creditType: \"{CreditType}\"");
            if (CreditWords.Any()) parts.Add($"creditWords: {string.Join(", ", CreditWords.Select(w => $"\"{w}\""))}");

            return $"Credit{{{string.Join(", ", parts)}}}";
        }
    }
}
