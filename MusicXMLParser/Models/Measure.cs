using System.Collections.Generic;

namespace MusicXMLParser.Models
{
    public class Measure
    {
        internal Measure()
        {
            Number = string.Empty;
            Width = -1;
            Notes = new List<Note>();
            Directions = new List<Direction>();
            Barlines = new List<Barline>();
        }

        public string Number { get; internal set; }

        public decimal Width { get; internal set; }

        public MeasureAttributes? Attributes { get; internal set; }

        public List<Note> Notes { get; internal set; }

        public List<Direction> Directions { get; internal set; }

        public List<Barline> Barlines { get; internal set; }
    }
} 