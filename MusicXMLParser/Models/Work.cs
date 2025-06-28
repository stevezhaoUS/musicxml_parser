namespace MusicXMLParser.Models
{
    public class Work
    {
        internal Work()
        {
            Title = string.Empty;
            Number = string.Empty;
        }

        public string Title { get; internal set; }

        public string Number { get; internal set; }
    }
} 