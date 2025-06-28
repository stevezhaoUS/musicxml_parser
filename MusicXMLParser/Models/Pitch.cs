namespace MusicXMLParser.Models
{
    public class Pitch
    {
        internal Pitch()
        {
            Step = 'C';
            Alter = 0;
            Octave = 4;
        }

        public char Step { get; internal set; }

        public int Alter { get; internal set; }

        public int Octave { get; internal set; }
    }
} 