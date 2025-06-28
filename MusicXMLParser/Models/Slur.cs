namespace MusicXMLParser.Models
{
    public class Slur
    {
        internal Slur()
        {
            Number = 1;
            Type = SlurType.Start;
        }

        public int Number { get; internal set; }

        public SlurType Type { get; internal set; }
    }

    public enum SlurType
    {
        Start,
        Stop,
        Continue
    }
} 