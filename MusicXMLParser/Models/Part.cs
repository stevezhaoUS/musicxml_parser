using System.Collections.Generic;

namespace MusicXMLParser.Models
{
    public class Part
    {
        internal Part()
        {
            Id = string.Empty;
            Name = string.Empty;
            Abbreviation = string.Empty;
            Measures = new List<Measure>();
        }

        public string Id { get; internal set; }

        public string Name { get; internal set; }

        public string Abbreviation { get; internal set; }

        public List<Measure> Measures { get; internal set; }
    }
} 