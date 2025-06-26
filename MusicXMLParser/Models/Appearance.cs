using System.Collections.Generic;
using System.Linq;

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a line width setting in MusicXML.
    /// </summary>
    public class LineWidth
    {
        /// <summary>
        /// The type of line (e.g., "light barline", "heavy barline", "beam", etc.).
        /// </summary>
        public string? Type { get; }

        /// <summary>
        /// The width value.
        /// </summary>
        public double Width { get; }

        /// <summary>
        /// Creates a new <see cref="LineWidth"/> instance.
        /// </summary>
        public LineWidth(string? type, double width)
        {
            Type = type;
            Width = width;
        }
    }

    /// <summary>
    /// Represents a note size setting in MusicXML.
    /// </summary>
    public class NoteSize
    {
        /// <summary>
        /// The type of note (e.g., "cue", "grace", etc.).
        /// </summary>
        public string? Type { get; }

        /// <summary>
        /// The size value as a percentage.
        /// </summary>
        public double Size { get; }

        /// <summary>
        /// Creates a new <see cref="NoteSize"/> instance.
        /// </summary>
        public NoteSize(string? type, double size)
        {
            Type = type;
            Size = size;
        }
    }

    /// <summary>
    /// Represents appearance settings in a MusicXML document.
    /// </summary>
    public class Appearance
    {
        /// <summary>
        /// Line width settings for different elements.
        /// </summary>
        public List<LineWidth> LineWidths { get; }

        /// <summary>
        /// Note size settings for different types of notes.
        /// </summary>
        public List<NoteSize> NoteSizes { get; }

        /// <summary>
        /// Creates a new <see cref="Appearance"/> instance.
        /// </summary>
        public Appearance(List<LineWidth>? lineWidths = null, List<NoteSize>? noteSizes = null)
        {
            LineWidths = lineWidths ?? new List<LineWidth>();
            NoteSizes = noteSizes ?? new List<NoteSize>();
        }
    }
}
