namespace MusicXMLParser.Models
{
    public class Beam
    {
        internal Beam()
        {
            Number = 1;
            Type = BeamType.Begin;
        }

        public int Number { get; internal set; }

        public BeamType Type { get; internal set; }
    }

    public enum BeamType
    {
        Begin,
        Continue,
        End,
        BackwardHook,
        ForwardHook
    }
} 