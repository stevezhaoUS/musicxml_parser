using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a complete MusicXML score document.
    /// </summary>
    /// <remarks>
    /// This is the top-level object for a parsed MusicXML file. It contains
    /// metadata such as <see cref="Version"/>, <see cref="Work"/> information, <see cref="Identification"/> details,
    /// and a list of <see cref="Parts"/> that make up the score. It also holds default
    /// layout information (<see cref="PageLayout"/>, <see cref="DefaultSystemLayout"/>, <see cref="DefaultStaffLayouts"/>),
    /// <see cref="Scaling"/>, and <see cref="Appearance"/> settings.
    /// Instances are typically created via <see cref="ScoreBuilder"/>.
    /// Objects of this class are immutable once created by the builder.
    /// </remarks>
    public class Score
    {
        /// <summary>
        /// The version of the MusicXML format used for the score (e.g., "3.1", "4.0").
        /// </summary>
        public string? Version { get; }

        /// <summary>
        /// Information about the musical work itself (e.g., title).
        /// </summary>
        public Work? Work { get; } // Assuming Work class will be ported

        /// <summary>
        /// Identification metadata for the score (e.g., composer, rights).
        /// </summary>
        public Identification? Identification { get; } // Assuming Identification class exists

        /// <summary>
        /// The list of <see cref="Part"/> objects that constitute the score.
        /// </summary>
        public List<Part> Parts { get; }

        /// <summary>
        /// Default page layout settings for the score.
        /// </summary>
        public PageLayout? PageLayout { get; } // Assuming PageLayout class exists

        /// <summary>
        /// Default system layout settings (e.g., margins, distances between systems).
        /// </summary>
        public SystemLayout? DefaultSystemLayout { get; } // Assuming SystemLayout placeholder exists

        /// <summary>
        /// List of default staff layout settings (e.g., staff distances).
        /// </summary>
        public List<StaffLayout> DefaultStaffLayouts { get; } // Assuming StaffLayout placeholder exists

        /// <summary>
        /// Scaling information used for rendering (e.g., millimeters per tenth).
        /// </summary>
        public Scaling? Scaling { get; } // Assuming Scaling class exists (part of PageLayout.cs)

        /// <summary>
        /// Default appearance settings (e.g., line widths, note sizes).
        /// </summary>
        public Appearance? Appearance { get; } // Assuming Appearance class exists

        /// <summary>
        /// The primary title of the score.
        /// Often also found within <see cref="Work"/> or <see cref="Identification"/> elements.
        /// </summary>
        public string? Title { get; }

        /// <summary>
        /// The primary composer of the score.
        /// Often also found within <see cref="Identification"/> elements.
        /// </summary>
        public string? Composer { get; }

        /// <summary>
        /// A list of <see cref="Credit"/> entries for the score (e.g., copyright, arranger).
        /// </summary>
        public List<Credit> Credits { get; } // Assuming Credit class exists

        /// <summary>
        /// Creates a new <see cref="Score"/> instance.
        /// </summary>
        /// <remarks>
        /// It is generally recommended to use <see cref="ScoreBuilder"/> for constructing <see cref="Score"/>
        /// objects, as it simplifies the process of incrementally adding properties
        /// during parsing.
        /// </remarks>
        public Score(
            string? version,
            List<Part>? parts,
            Work? work = null,
            Identification? identification = null,
            PageLayout? pageLayout = null,
            SystemLayout? defaultSystemLayout = null,
            List<StaffLayout>? defaultStaffLayouts = null,
            Scaling? scaling = null,
            Appearance? appearance = null,
            string? title = null,
            string? composer = null,
            List<Credit>? credits = null)
        {
            if (string.IsNullOrEmpty(version))
                throw new ArgumentException("Version cannot be null or empty.", nameof(version));

            Version = version;
            Parts = parts ?? new List<Part>();
            Work = work;
            Identification = identification;
            PageLayout = pageLayout;
            DefaultSystemLayout = defaultSystemLayout;
            DefaultStaffLayouts = defaultStaffLayouts ?? new List<StaffLayout>();
            Scaling = scaling;
            Appearance = appearance;
            Title = title;
            Composer = composer;
            Credits = credits ?? new List<Credit>();
        }

        public override bool Equals(object? obj)
        {
            if (obj is Score other)
            {
                return Version == other.Version &&
                       object.Equals(Work, other.Work) &&
                       object.Equals(Identification, other.Identification) &&
                       Parts.SequenceEqual(other.Parts) &&
                       object.Equals(PageLayout, other.PageLayout) &&
                       object.Equals(DefaultSystemLayout, other.DefaultSystemLayout) &&
                       DefaultStaffLayouts.SequenceEqual(other.DefaultStaffLayouts) &&
                       object.Equals(Scaling, other.Scaling) &&
                       object.Equals(Appearance, other.Appearance) &&
                       Title == other.Title &&
                       Composer == other.Composer &&
                       Credits.SequenceEqual(other.Credits);
            }
            return false;
        }

        public override int GetHashCode()
        {
            var hashCode = new HashCode();
            hashCode.Add(Version);
            hashCode.Add(Work);
            hashCode.Add(Identification);
            Parts?.ForEach(p => hashCode.Add(p)); // Simplified; consider a more robust list hashing
            hashCode.Add(PageLayout);
            hashCode.Add(DefaultSystemLayout);
            DefaultStaffLayouts?.ForEach(s => hashCode.Add(s)); // Simplified
            hashCode.Add(Scaling);
            hashCode.Add(Appearance);
            hashCode.Add(Title);
            hashCode.Add(Composer);
            Credits?.ForEach(c => hashCode.Add(c)); // Simplified
            return hashCode.ToHashCode();
        }

        public override string ToString()
        {
            var buffer = new StringBuilder($"Score{{Version: {Version}");
            if (!string.IsNullOrEmpty(Title)) buffer.Append($", Title: {Title}");
            if (!string.IsNullOrEmpty(Composer)) buffer.Append($", Composer: {Composer}");
            if (Work != null) buffer.Append($", Work: {Work}");
            if (Identification != null) buffer.Append($", Identification: {Identification}");
            buffer.Append($", Parts: {Parts?.Count ?? 0}");
            if (PageLayout != null) buffer.Append($", DefaultPageLayout: {PageLayout}");
            if (DefaultSystemLayout != null) buffer.Append($", DefaultSystemLayout: {DefaultSystemLayout}");
            if (DefaultStaffLayouts != null && DefaultStaffLayouts.Any()) buffer.Append($", DefaultStaffLayouts: [{string.Join(", ", DefaultStaffLayouts)}]");
            if (Scaling != null) buffer.Append($", Scaling: {Scaling}");
            if (Appearance != null) buffer.Append($", Appearance: {Appearance}");
            if (Credits != null && Credits.Any()) buffer.Append($", Credits: {Credits.Count}");
            buffer.Append("}");
            return buffer.ToString();
        }
    }

    /// <summary>
    /// Builder for creating <see cref="Score"/> objects incrementally.
    /// </summary>
    public class ScoreBuilder
    {
        private string _version = "3.0"; // Default version
        private Work? _work;
        private Identification? _identification;
        private List<Part> _parts = new List<Part>();
        private PageLayout? _pageLayout;
        private SystemLayout? _defaultSystemLayout;
        private List<StaffLayout> _defaultStaffLayouts = new List<StaffLayout>();
        private Scaling? _scaling;
        private Appearance? _appearance;
        private string? _title;
        private string? _composer;
        private List<Credit> _credits = new List<Credit>();

        public ScoreBuilder(string version = "3.0")
        {
            SetVersion(version);
        }

        public ScoreBuilder SetVersion(string version)
        {
            _version = !string.IsNullOrEmpty(version) ? version : "3.0";
            return this;
        }

        public ScoreBuilder SetWork(Work? work) { _work = work; return this; }
        public ScoreBuilder SetIdentification(Identification? identification) { _identification = identification; return this; }
        public ScoreBuilder SetParts(List<Part>? parts) { _parts = parts ?? new List<Part>(); return this; }
        public ScoreBuilder AddPart(Part? part) { if (part != null) _parts.Add(part); return this; }
        public ScoreBuilder SetPageLayout(PageLayout? pageLayout) { _pageLayout = pageLayout; return this; }
        public ScoreBuilder SetDefaultSystemLayout(SystemLayout? systemLayout) { _defaultSystemLayout = systemLayout; return this; }
        public ScoreBuilder setDefaultStaffLayouts(List<StaffLayout>? staffLayouts) { _defaultStaffLayouts = staffLayouts ?? new List<StaffLayout>(); return this; }
        public ScoreBuilder AddDefaultStaffLayout(StaffLayout? staffLayout) { if (staffLayout != null) _defaultStaffLayouts.Add(staffLayout); return this; }
        public ScoreBuilder SetScaling(Scaling? scaling) { _scaling = scaling; return this; }
        public ScoreBuilder SetAppearance(Appearance? appearance) { _appearance = appearance; return this; }
        public ScoreBuilder SetTitle(string? title) { _title = title; return this; }
        public ScoreBuilder SetComposer(string? composer) { _composer = composer; return this; }
        public ScoreBuilder SetCredits(List<Credit>? credits) { _credits = credits ?? new List<Credit>(); return this; }
        public ScoreBuilder AddCredit(Credit? credit) { if (credit != null) _credits.Add(credit); return this; }

        public Score Build()
        {
            return new Score(
                _version,
                _parts,
                _work,
                _identification,
                _pageLayout,
                _defaultSystemLayout,
                _defaultStaffLayouts,
                _scaling,
                _appearance,
                _title,
                _composer,
                _credits
            );
        }
    }
}
