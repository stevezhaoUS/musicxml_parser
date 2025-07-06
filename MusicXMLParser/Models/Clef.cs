namespace MusicXMLParser.Models
{
    public class Clef
    {
        internal Clef()
        {
            Sign = string.Empty;
            Line = 1;
            OctaveChange = 0;
            Staff = 1; // 默认staff为1
        }

        public string Sign { get; internal set; }

        public int Line { get; internal set; }

        public int OctaveChange { get; internal set; }

        public int Staff { get; internal set; }
    }
} 