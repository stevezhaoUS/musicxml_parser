using System.Collections.Generic;

namespace MusicXMLParser.Models
{
    public class MeasureAttributes
    {
        internal MeasureAttributes()
        {
            Divisions = -1;
            Clefs = new List<Clef>();
        }

        public int Divisions { get; internal set; }

        public KeySignature? Key { get; internal set; }

        public TimeSignature? Time { get; internal set; }

        public List<Clef> Clefs { get; internal set; }
    }
} 