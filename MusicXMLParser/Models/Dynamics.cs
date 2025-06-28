namespace MusicXMLParser.Models
{
    public class Dynamics
    {
        internal Dynamics()
        {
            Piano = false;
            Forte = false;
            MezzoPiano = false;
            MezzoForte = false;
            Pianissimo = false;
            Fortissimo = false;
        }

        public bool Piano { get; internal set; }

        public bool Forte { get; internal set; }

        public bool MezzoPiano { get; internal set; }

        public bool MezzoForte { get; internal set; }

        public bool Pianissimo { get; internal set; }

        public bool Fortissimo { get; internal set; }
    }
} 