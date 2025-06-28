namespace MusicXMLParser.Models
{
    public class Tie
    {
        internal Tie()
        {
            Type = TieType.Start;
        }

        public TieType Type { get; internal set; }
    }

    public enum TieType
    {
        Start,
        Stop
    }
} 