using System.Collections.Generic;

namespace MusicXMLParser.Models
{
    public class Note
    {
        internal Note()
        {
            Type = string.Empty;
            Duration = -1;
            Voice = -1;
            Staff = -1;
            IsChordTone = false;
            IsRest = false;
            IsGrace = false;
            Accidental = string.Empty;
            Beams = new List<Beam>();
        }

        public string Type { get; internal set; }

        public int Voice { get; internal set; }

        public int Duration { get; internal set; }

        public int Staff { get; internal set; }

        public bool IsChordTone { get; internal set; }

        public bool IsRest { get; internal set; }

        public bool IsGrace { get; internal set; }

        public string Accidental { get; internal set; }

        public Pitch? Pitch { get; internal set; }

        public Tie? Tie { get; internal set; }

        public Slur? Slur { get; internal set; }

        public List<Beam> Beams { get; internal set; }
    }
} 