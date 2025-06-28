namespace MusicXMLParser.Models
{
    public class TimeSignature
    {
        internal TimeSignature()
        {
            Beats = 4;
            BeatType = 4;
        }

        public int Beats { get; internal set; }

        public int BeatType { get; internal set; }
    }
} 