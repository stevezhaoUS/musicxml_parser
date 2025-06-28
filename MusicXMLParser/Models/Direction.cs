namespace MusicXMLParser.Models
{
    public class Direction
    {
        internal Direction()
        {
            Words = string.Empty;
        }

        public string Words { get; internal set; }

        public Dynamics? Dynamics { get; internal set; }
    }
} 