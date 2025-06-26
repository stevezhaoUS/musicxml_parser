using System;

namespace MusicXMLParser.Models.DirectionTypeElements
{
    public class Segno : IDirectionTypeElement, IEquatable<Segno>
    {
        public string? Color { get; }
        public double? DefaultX { get; }
        public double? DefaultY { get; }
        public string? FontFamily { get; }
        public string? FontSize { get; }
        public string? FontStyle { get; }
        public string? FontWeight { get; }
        public string? Halign { get; }
        public string? Id { get; }
        public double? RelativeX { get; }
        public double? RelativeY { get; }
        public string? Smufl { get; }
        public string? Valign { get; }

        public Segno(string? color = null, double? defaultX = null, double? defaultY = null, string? fontFamily = null,
                     string? fontSize = null, string? fontStyle = null, string? fontWeight = null, string? halign = null,
                     string? id = null, double? relativeX = null, double? relativeY = null, string? smufl = null, string? valign = null)
        {
            Color = color;
            DefaultX = defaultX;
            DefaultY = defaultY;
            FontFamily = fontFamily;
            FontSize = fontSize;
            FontStyle = fontStyle;
            FontWeight = fontWeight;
            Halign = halign;
            Id = id;
            RelativeX = relativeX;
            RelativeY = relativeY;
            Smufl = smufl;
            Valign = valign;
        }

        public override bool Equals(object? obj) => Equals(obj as Segno);

        public bool Equals(Segno? other) =>
            other != null &&
            Color == other.Color &&
            DefaultX == other.DefaultX &&
            DefaultY == other.DefaultY &&
            FontFamily == other.FontFamily &&
            FontSize == other.FontSize &&
            FontStyle == other.FontStyle &&
            FontWeight == other.FontWeight &&
            Halign == other.Halign &&
            Id == other.Id &&
            RelativeX == other.RelativeX &&
            RelativeY == other.RelativeY &&
            Smufl == other.Smufl &&
            Valign == other.Valign;

        public override int GetHashCode()
        {
            var hashCode = new HashCode();
            hashCode.Add(Color);
            hashCode.Add(DefaultX);
            hashCode.Add(DefaultY);
            hashCode.Add(FontFamily);
            hashCode.Add(FontSize);
            hashCode.Add(FontStyle);
            hashCode.Add(FontWeight);
            hashCode.Add(Halign);
            hashCode.Add(Id);
            hashCode.Add(RelativeX);
            hashCode.Add(RelativeY);
            hashCode.Add(Smufl);
            hashCode.Add(Valign);
            return hashCode.ToHashCode();
        }

        public override string ToString() =>
            $"Segno{{color: {Color}, defaultX: {DefaultX}, defaultY: {DefaultY}, fontFamily: {FontFamily}, fontSize: {FontSize}, fontStyle: {FontStyle}, fontWeight: {FontWeight}, halign: {Halign}, id: {Id}, relativeX: {RelativeX}, relativeY: {RelativeY}, smufl: {Smufl}, valign: {Valign}}}";
    }
}
