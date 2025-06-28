namespace MusicXMLParser.Models
{
    public class MeasureAttributes
    {
        internal MeasureAttributes()
        {
            Divisions = -1;
        }

        public int Divisions { get; internal set; }

        public KeySignature? Key { get; internal set; }

        public TimeSignature? Time { get; internal set; }

        public Clef? Clef { get; internal set; }
    }
} 