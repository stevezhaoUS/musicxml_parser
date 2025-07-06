using System.Collections.Generic;

namespace MusicXMLParser.Models
{
    public class Measure
    {
        internal Measure()
        {
            Number = 0;
            Width = -1.0f;
            Notes = new List<Note>();
            Directions = new List<Direction>();
            Barlines = new List<Barline>();
        }

        public int Number { get; internal set; }

        public float Width { get; internal set; }

        public MeasureAttributes? Attributes { get; internal set; }

        public List<Note> Notes { get; internal set; }

        public List<Direction> Directions { get; internal set; }

        public List<Barline> Barlines { get; internal set; }
    }
} 