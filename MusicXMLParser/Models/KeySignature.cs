namespace MusicXMLParser.Models
{
    public class KeySignature
    {
        internal KeySignature()
        {
            Fifths = 0;
            Mode = string.Empty;
        }

        public int Fifths { get; internal set; }

        public string Mode { get; internal set; }
    }
} 