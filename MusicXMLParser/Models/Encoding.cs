using System;

namespace MusicXMLParser.Models
{
    public class Encoding
    {
        internal Encoding()
        {
            Software = string.Empty;
            EncodingDate = DateTime.MinValue;
        }

        public string Software { get; internal set; }

        public DateTime EncodingDate { get; internal set; }
    }
} 