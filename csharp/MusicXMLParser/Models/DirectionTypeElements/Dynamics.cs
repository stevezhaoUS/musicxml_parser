using System;
using System.Collections.Generic;
using System.Linq;

namespace MusicXMLParser.Models.DirectionTypeElements
{
    public class Dynamics : IDirectionTypeElement, IEquatable<Dynamics>
    {
        public string Color { get; }
        public double? DefaultX { get; }
        public double? DefaultY { get; }
        public string Enclosure { get; }
        public string FontFamily { get; }
        public string FontSize { get; }
        public string FontStyle { get; }
        public string FontWeight { get; }
        public string Halign { get; }
        public string Id { get; }
        public int? LineThrough { get; }
        public int? Overline { get; }
        public string Placement { get; }
        public double? RelativeX { get; }
        public double? RelativeY { get; }
        public int? Underline { get; }
        public string Valign { get; }
        public List<string> Values { get; } // e.g. ["p", "f", "sfz"] or ["other-dynamics"] content

        public Dynamics(string color = null, double? defaultX = null, double? defaultY = null, string enclosure = null,
                        string fontFamily = null, string fontSize = null, string fontStyle = null, string fontWeight = null,
                        string halign = null, string id = null, int? lineThrough = null, int? overline = null,
                        string placement = null, double? relativeX = null, double? relativeY = null, int? underline = null,
                        string valign = null, List<string> values = null)
        {
            Color = color;
            DefaultX = defaultX;
            DefaultY = defaultY;
            Enclosure = enclosure;
            FontFamily = fontFamily;
            FontSize = fontSize;
            FontStyle = fontStyle;
            FontWeight = fontWeight;
            Halign = halign;
            Id = id;
            LineThrough = lineThrough;
            Overline = overline;
            Placement = placement;
            RelativeX = relativeX;
            RelativeY = relativeY;
            Underline = underline;
            Valign = valign;
            Values = values ?? new List<string>();
        }

        public override bool Equals(object obj) => Equals(obj as Dynamics);

        public bool Equals(Dynamics other) =>
            other != null &&
            Color == other.Color &&
            DefaultX == other.DefaultX &&
            DefaultY == other.DefaultY &&
            Enclosure == other.Enclosure &&
            FontFamily == other.FontFamily &&
            FontSize == other.FontSize &&
            FontStyle == other.FontStyle &&
            FontWeight == other.FontWeight &&
            Halign == other.Halign &&
            Id == other.Id &&
            LineThrough == other.LineThrough &&
            Overline == other.Overline &&
            Placement == other.Placement &&
            RelativeX == other.RelativeX &&
            RelativeY == other.RelativeY &&
            Underline == other.Underline &&
            Valign == other.Valign &&
            Values.SequenceEqual(other.Values);

        public override int GetHashCode()
        {
            var hashCode = new HashCode();
            hashCode.Add(Color);
            hashCode.Add(DefaultX);
            hashCode.Add(DefaultY);
            hashCode.Add(Enclosure);
            hashCode.Add(FontFamily);
            hashCode.Add(FontSize);
            hashCode.Add(FontStyle);
            hashCode.Add(FontWeight);
            hashCode.Add(Halign);
            hashCode.Add(Id);
            hashCode.Add(LineThrough);
            hashCode.Add(Overline);
            hashCode.Add(Placement);
            hashCode.Add(RelativeX);
            hashCode.Add(RelativeY);
            hashCode.Add(Underline);
            hashCode.Add(Valign);
            Values.ForEach(v => hashCode.Add(v));
            return hashCode.ToHashCode();
        }

        public override string ToString() =>
            $"Dynamics{{color: {Color}, defaultX: {DefaultX}, defaultY: {DefaultY}, enclosure: {Enclosure}, fontFamily: {FontFamily}, fontSize: {FontSize}, fontStyle: {FontStyle}, fontWeight: {FontWeight}, halign: {Halign}, id: {Id}, lineThrough: {LineThrough}, overline: {Overline}, placement: {Placement}, relativeX: {RelativeX}, relativeY: {RelativeY}, underline: {Underline}, valign: {Valign}, values: [{string.Join(", ", Values)}]}}";
    }
}
