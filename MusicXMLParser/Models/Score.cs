using System.Collections.Generic;

namespace MusicXMLParser.Models
{
    public class Score
    {
        internal Score()
        {
            Parts = new List<Part>();
            MovementTitle = string.Empty;
        }

        public string MovementTitle { get; internal set; }

        public Identification? Identification { get; internal set; }

        public Work? Work { get; internal set; }

        public List<Part> Parts { get; internal set; }
    }
} 