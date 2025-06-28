namespace MusicXMLParser.Models
{
    public class Barline
    {
        internal Barline()
        {
            Location = BarlineLocation.Right;
            Style = BarlineStyle.Regular;
        }

        public BarlineLocation Location { get; internal set; }

        public BarlineStyle Style { get; internal set; }
    }

    public enum BarlineLocation
    {
        Left,
        Right,
        Middle
    }

    public enum BarlineStyle
    {
        Regular,
        Dotted,
        Dashed,
        Heavy,
        LightLight,
        LightHeavy,
        HeavyLight,
        HeavyHeavy,
        Tick,
        Short,
        None
    }
} 