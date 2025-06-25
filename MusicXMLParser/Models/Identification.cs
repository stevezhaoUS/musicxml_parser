using System;

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents the identification information in a MusicXML file.
    /// This includes creator information (composer, lyricist, etc.),
    /// rights, encoding information, and source.
    /// </summary>
    public class Identification : IEquatable<Identification>
    {
        /// <summary>
        /// The composer of the work.
        /// </summary>
        public string Composer { get; }

        /// <summary>
        /// The lyricist of the work.
        /// </summary>
        public string Lyricist { get; }

        /// <summary>
        /// The arranger of the work.
        /// </summary>
        public string Arranger { get; }

        /// <summary>
        /// Copyright notice for the score.
        /// </summary>
        public string Rights { get; }

        /// <summary>
        /// Information about the source of the score.
        /// </summary>
        public string Source { get; }

        /// <summary>
        /// Information about the encoding of the score.
        /// </summary>
        public Encoding Encoding { get; }

        /// <summary>
        /// Creates a new <see cref="Identification"/> instance.
        /// </summary>
        public Identification(string composer = null, string lyricist = null, string arranger = null,
                              string rights = null, string source = null, Encoding encoding = null)
        {
            Composer = composer;
            Lyricist = lyricist;
            Arranger = arranger;
            Rights = rights;
            Source = source;
            Encoding = encoding;
        }

        public override bool Equals(object obj) => Equals(obj as Identification);

        public bool Equals(Identification other) =>
            other != null &&
            Composer == other.Composer &&
            Lyricist == other.Lyricist &&
            Arranger == other.Arranger &&
            Rights == other.Rights &&
            Source == other.Source &&
            System.Collections.Generic.EqualityComparer<Encoding>.Default.Equals(Encoding, other.Encoding);

        public override int GetHashCode() =>
            HashCode.Combine(Composer, Lyricist, Arranger, Rights, Source, Encoding);
    }

    /// <summary>
    /// Represents encoding information in the score.
    /// </summary>
    public class Encoding : IEquatable<Encoding>
    {
        /// <summary>
        /// The software used to create the score.
        /// </summary>
        public string Software { get; }

        /// <summary>
        /// The date when the score was encoded.
        /// </summary>
        public string EncodingDate { get; }

        /// <summary>
        /// The description of the encoding.
        /// </summary>
        public string Description { get; }

        /// <summary>
        /// Creates a new <see cref="Encoding"/> instance.
        /// </summary>
        public Encoding(string software = null, string encodingDate = null, string description = null)
        {
            Software = software;
            EncodingDate = encodingDate;
            Description = description;
        }

        public override bool Equals(object obj) => Equals(obj as Encoding);

        public bool Equals(Encoding other) =>
            other != null &&
            Software == other.Software &&
            EncodingDate == other.EncodingDate &&
            Description == other.Description;

        public override int GetHashCode() => HashCode.Combine(Software, EncodingDate, Description);
    }
}
