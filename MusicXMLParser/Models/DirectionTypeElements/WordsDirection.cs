using System;

namespace MusicXMLParser.Models.DirectionTypeElements
{
    /// <summary>
    /// Represents a textual direction from a <words> element within a <direction>.
    /// </summary>
    public class WordsDirection : IDirectionTypeElement, IEquatable<WordsDirection>
    {
        /// <summary>
        /// The text content of the <words> element.
        /// </summary>
        public string Text { get; }

        // Attributes from <words> element
        public string? Color { get; }
        public double? DefaultX { get; }
        public double? DefaultY { get; }
        public string? Dir { get; } // text-direction
        public string? Enclosure { get; } // enclosure-shape
        public string? FontFamily { get; }
        public string? FontSize { get; } // font-size (CSS size or numeric point size)
        public string? FontStyle { get; } // font-style (normal or italic)
        public string? FontWeight { get; } // font-weight (normal or bold)
        public string? Halign { get; } // left-center-right
        public string? Id { get; }
        public string? Justify { get; } // left-center-right
        public string? LetterSpacing { get; } // number-or-normal
        public string? LineHeight { get; } // number-or-normal
        public int? LineThrough { get; } // number-of-lines
        public int? Overline { get; } // number-of-lines
        public double? RelativeX { get; }
        public double? RelativeY { get; }
        public double? Rotation { get; } // rotation-degrees
        public int? Underline { get; } // number-of-lines
        public string? Valign { get; } // valign
        public string? XmlLang { get; }
        public string? XmlSpace { get; } // preserve or default

        /// <summary>
        /// Creates a new <see cref="WordsDirection"/> instance.
        /// </summary>
        public WordsDirection(string text, string? color = null, double? defaultX = null, double? defaultY = null,
                              string? dir = null, string? enclosure = null, string? fontFamily = null, string? fontSize = null,
                              string? fontStyle = null, string? fontWeight = null, string? halign = null, string? id = null,
                              string? justify = null, string? letterSpacing = null, string? lineHeight = null,
                              int? lineThrough = null, int? overline = null, double? relativeX = null, double? relativeY = null,
                              double? rotation = null, int? underline = null, string? valign = null, string? xmlLang = null, string? xmlSpace = null)
        {
            Text = text;
            Color = color;
            DefaultX = defaultX;
            DefaultY = defaultY;
            Dir = dir;
            Enclosure = enclosure;
            FontFamily = fontFamily;
            FontSize = fontSize;
            FontStyle = fontStyle;
            FontWeight = fontWeight;
            Halign = halign;
            Id = id;
            Justify = justify;
            LetterSpacing = letterSpacing;
            LineHeight = lineHeight;
            LineThrough = lineThrough;
            Overline = overline;
            RelativeX = relativeX;
            RelativeY = relativeY;
            Rotation = rotation;
            Underline = underline;
            Valign = valign;
            XmlLang = xmlLang;
            XmlSpace = xmlSpace;
        }

        public override bool Equals(object? obj) => Equals(obj as WordsDirection);

        public bool Equals(WordsDirection? other) =>
            other != null &&
            Text == other.Text &&
            Color == other.Color &&
            DefaultX == other.DefaultX &&
            DefaultY == other.DefaultY &&
            Dir == other.Dir &&
            Enclosure == other.Enclosure &&
            FontFamily == other.FontFamily &&
            FontSize == other.FontSize &&
            FontStyle == other.FontStyle &&
            FontWeight == other.FontWeight &&
            Halign == other.Halign &&
            Id == other.Id &&
            Justify == other.Justify &&
            LetterSpacing == other.LetterSpacing &&
            LineHeight == other.LineHeight &&
            LineThrough == other.LineThrough &&
            Overline == other.Overline &&
            RelativeX == other.RelativeX &&
            RelativeY == other.RelativeY &&
            Rotation == other.Rotation &&
            Underline == other.Underline &&
            Valign == other.Valign &&
            XmlLang == other.XmlLang &&
            XmlSpace == other.XmlSpace;

        public override int GetHashCode()
        {
            var hashCode = new HashCode();
            hashCode.Add(Text);
            hashCode.Add(Color);
            hashCode.Add(DefaultX);
            hashCode.Add(DefaultY);
            hashCode.Add(Dir);
            hashCode.Add(Enclosure);
            hashCode.Add(FontFamily);
            hashCode.Add(FontSize);
            hashCode.Add(FontStyle);
            hashCode.Add(FontWeight);
            hashCode.Add(Halign);
            hashCode.Add(Id);
            hashCode.Add(Justify);
            hashCode.Add(LetterSpacing);
            hashCode.Add(LineHeight);
            hashCode.Add(LineThrough);
            hashCode.Add(Overline);
            hashCode.Add(RelativeX);
            hashCode.Add(RelativeY);
            hashCode.Add(Rotation);
            hashCode.Add(Underline);
            hashCode.Add(Valign);
            hashCode.Add(XmlLang);
            hashCode.Add(XmlSpace);
            return hashCode.ToHashCode();
        }

        public override string ToString() => $"WordsDirection{{text: \"{Text}\", " +
            $"fontFamily: {FontFamily}, fontSize: {FontSize}, defaultX: {DefaultX}, defaultY: {DefaultY}, " +
            $"halign: {Halign}, valign: {Valign}, color: {Color}, dir: {Dir}, enclosure: {Enclosure}, " +
            $"fontStyle: {FontStyle}, fontWeight: {FontWeight}, id: {Id}, justify: {Justify}, " +
            $"letterSpacing: {LetterSpacing}, lineHeight: {LineHeight}, lineThrough: {LineThrough}, " +
            $"overline: {Overline}, relativeX: {RelativeX}, relativeY: {RelativeY}, rotation: {Rotation}, " +
            $"underline: {Underline}, xmlLang: {XmlLang}, xmlSpace: {XmlSpace}}}";
    }
}
