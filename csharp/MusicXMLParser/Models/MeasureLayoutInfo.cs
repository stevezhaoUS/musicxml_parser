using System;

namespace MusicXMLParser.Models
{
    public class MeasureLayout : IEquatable<MeasureLayout>
    {
        public double? MeasureDistance { get; }

        public MeasureLayout(double? measureDistance = null)
        {
            MeasureDistance = measureDistance;
        }

        public override bool Equals(object obj) => Equals(obj as MeasureLayout);
        public bool Equals(MeasureLayout other) => other != null && MeasureDistance == other.MeasureDistance;
        public override int GetHashCode() => MeasureDistance.GetHashCode();
        public override string ToString() => $"MeasureLayout{{measureDistance: {MeasureDistance}}}";
    }

    public enum MeasureNumberingValue { None, Measure, System }

    public class MeasureNumbering : IEquatable<MeasureNumbering>
    {
        public MeasureNumberingValue Value { get; }
        public string Color { get; }
        public double? DefaultX { get; }
        public double? DefaultY { get; }
        public string FontFamily { get; }
        public string FontSize { get; }
        public string FontStyle { get; }
        public string FontWeight { get; }
        public string Halign { get; }
        public bool? MultipleRestAlways { get; } // yes-no
        public bool? MultipleRestRange { get; } // yes-no
        public double? RelativeX { get; }
        public double? RelativeY { get; }
        public int? Staff { get; } // staff-number
        public string System { get; } // system-relation-number (can be 'none', 'other', 'default', or a number)
        public string Valign { get; }

        public MeasureNumbering(
            MeasureNumberingValue value, string color = null, double? defaultX = null, double? defaultY = null,
            string fontFamily = null, string fontSize = null, string fontStyle = null, string fontWeight = null,
            string halign = null, bool? multipleRestAlways = null, bool? multipleRestRange = null,
            double? relativeX = null, double? relativeY = null, int? staff = null, string system = null, string valign = null)
        {
            Value = value;
            Color = color;
            DefaultX = defaultX;
            DefaultY = defaultY;
            FontFamily = fontFamily;
            FontSize = fontSize;
            FontStyle = fontStyle;
            FontWeight = fontWeight;
            Halign = halign;
            MultipleRestAlways = multipleRestAlways;
            MultipleRestRange = multipleRestRange;
            RelativeX = relativeX;
            RelativeY = relativeY;
            Staff = staff;
            System = system;
            Valign = valign;
        }

        public static MeasureNumberingValue ParseValue(string valueStr)
        {
            return valueStr?.ToLowerInvariant() switch
            {
                "none" => MeasureNumberingValue.None,
                "measure" => MeasureNumberingValue.Measure,
                "system" => MeasureNumberingValue.System,
                // As per spec, if not specified, it's 'measure' if part of <measure-style>,
                // but within <print>, it implies a specific value must be present.
                // However, for robustness, let's default or handle error.
                // For now, defaulting to 'measure' if text is unexpected, though strict parsing might throw.
                _ => MeasureNumberingValue.Measure, // Or throw an exception.
            };
        }

        public override bool Equals(object obj) => Equals(obj as MeasureNumbering);

        public bool Equals(MeasureNumbering other) =>
            other != null &&
            Value == other.Value &&
            Color == other.Color &&
            DefaultX == other.DefaultX &&
            DefaultY == other.DefaultY &&
            FontFamily == other.FontFamily &&
            FontSize == other.FontSize &&
            FontStyle == other.FontStyle &&
            FontWeight == other.FontWeight &&
            Halign == other.Halign &&
            MultipleRestAlways == other.MultipleRestAlways &&
            MultipleRestRange == other.MultipleRestRange &&
            RelativeX == other.RelativeX &&
            RelativeY == other.RelativeY &&
            Staff == other.Staff &&
            System == other.System &&
            Valign == other.Valign;

        public override int GetHashCode()
        {
            var hashCode = new HashCode();
            hashCode.Add(Value);
            hashCode.Add(Color);
            hashCode.Add(DefaultX);
            hashCode.Add(DefaultY);
            hashCode.Add(FontFamily);
            hashCode.Add(FontSize);
            hashCode.Add(FontStyle);
            hashCode.Add(FontWeight);
            hashCode.Add(Halign);
            hashCode.Add(MultipleRestAlways);
            hashCode.Add(MultipleRestRange);
            hashCode.Add(RelativeX);
            hashCode.Add(RelativeY);
            hashCode.Add(Staff);
            hashCode.Add(System);
            hashCode.Add(Valign);
            return hashCode.ToHashCode();
        }

        public override string ToString() =>
            $"MeasureNumbering{{value: {Value}, color: {Color}, defaultX: {DefaultX}, defaultY: {DefaultY}, fontFamily: {FontFamily}, fontSize: {FontSize}, fontStyle: {FontStyle}, fontWeight: {FontWeight}, halign: {Halign}, multipleRestAlways: {MultipleRestAlways}, multipleRestRange: {MultipleRestRange}, relativeX: {RelativeX}, relativeY: {RelativeY}, staff: {Staff}, system: {System}, valign: {Valign}}}";
    }
}
