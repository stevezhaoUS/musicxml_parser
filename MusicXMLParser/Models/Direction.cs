using System;
using System.Collections.Generic;
using System.Linq;
using MusicXMLParser.Models.DirectionTypeElements; // Assuming this will be created later

namespace MusicXMLParser.Models
{
    public class Offset : IEquatable<Offset>
    {
        public double Value { get; }
        public bool Sound { get; } // Corresponds to the 'sound' attribute of <offset>

        public Offset(double value, bool sound = false)
        {
            Value = value;
            Sound = sound;
        }

        public override bool Equals(object? obj) => Equals(obj as Offset);
        public bool Equals(Offset? other) => other != null && Value == other.Value && Sound == other.Sound;
        public override int GetHashCode() => HashCode.Combine(Value, Sound);
        public override string ToString() => $"Offset{{value: {Value}, sound: {Sound}}}";
    }

    public class Staff : IEquatable<Staff>
    {
        public int Value { get; }

        public Staff(int value)
        {
            Value = value;
        }

        public override bool Equals(object? obj) => Equals(obj as Staff);
        public bool Equals(Staff? other) => other != null && Value == other.Value;
        public override int GetHashCode() => Value.GetHashCode();
        public override string ToString() => $"Staff{{value: {Value}}}";
    }

    public class Sound : IEquatable<Sound>
    {
        // Attributes related to playback
        public double? Tempo { get; } // MIDI tempo in beats per minute
        public double? Dynamics { get; } // Dynamic scaling factor (percentage)
        public bool? Dacapo { get; }
        public string? Segno { get; } // Value is text, e.g., name of segno mark
        public string? Coda { get; } // Value is text, e.g., name of coda mark
        public string? Fine { get; } // Value is text, e.g., text for fine mark
        public bool? TimeOnly { get; } // Specifies which parts of a metronome mark to play
        public bool? Pizzicato { get; }
        public double? Pan { get; }
        public double? Elevation { get; }
        // TODO: Add other sound attributes like pedal, etc. as needed
        // For <offset> child of <sound>
        public Offset? Offset { get; }

        public Sound(double? tempo = null, double? dynamics = null, bool? dacapo = null, string? segno = null,
                     string? coda = null, string? fine = null, bool? timeOnly = null, bool? pizzicato = null,
                     double? pan = null, double? elevation = null, Offset? offset = null)
        {
            Tempo = tempo;
            Dynamics = dynamics;
            Dacapo = dacapo;
            Segno = segno;
            Coda = coda;
            Fine = fine;
            TimeOnly = timeOnly;
            Pizzicato = pizzicato;
            Pan = pan;
            Elevation = elevation;
            Offset = offset;
        }

        public override bool Equals(object? obj) => Equals(obj as Sound);
        public bool Equals(Sound? other) =>
            other != null &&
            Tempo == other.Tempo &&
            Dynamics == other.Dynamics &&
            Dacapo == other.Dacapo &&
            Segno == other.Segno &&
            Coda == other.Coda &&
            Fine == other.Fine &&
            TimeOnly == other.TimeOnly &&
            Pizzicato == other.Pizzicato &&
            Pan == other.Pan &&
            Elevation == other.Elevation &&
            EqualityComparer<Offset?>.Default.Equals(Offset, other.Offset);

        public override int GetHashCode()
        {
            var hashCode = new HashCode();
            hashCode.Add(Tempo);
            hashCode.Add(Dynamics);
            hashCode.Add(Dacapo);
            hashCode.Add(Segno);
            hashCode.Add(Coda);
            hashCode.Add(Fine);
            hashCode.Add(TimeOnly);
            hashCode.Add(Pizzicato);
            hashCode.Add(Pan);
            hashCode.Add(Elevation);
            hashCode.Add(Offset);
            return hashCode.ToHashCode();
        }

        public override string ToString() =>
            $"Sound{{tempo: {Tempo}, dynamics: {Dynamics}, dacapo: {Dacapo}, segno: {Segno}, coda: {Coda}, fine: {Fine}, timeOnly: {TimeOnly}, pizzicato: {Pizzicato}, pan: {Pan}, elevation: {Elevation}, offset: {Offset}}}";
    }

    public class Direction : IEquatable<Direction>
    {
        public List<IDirectionTypeElement> DirectionTypes { get; } // Changed to interface
        public Offset? Offset { get; }
        public Staff? Staff { get; }
        public Sound? Sound { get; }
        // Attributes of <direction> element itself
        public string? Placement { get; } // above-below
        public string? Directive { get; } // yes-no
        public string? System { get; } // system-relation
        public string? Id { get; }

        public Direction(List<IDirectionTypeElement> directionTypes, Offset? offset = null, Staff? staff = null, Sound? sound = null,
                         string? placement = null, string? directive = null, string? system = null, string? id = null)
        {
            DirectionTypes = directionTypes ?? new List<IDirectionTypeElement>();
            Offset = offset;
            Staff = staff;
            Sound = sound;
            Placement = placement;
            Directive = directive;
            System = system;
            Id = id;
        }

        public override bool Equals(object? obj) => Equals(obj as Direction);
        public bool Equals(Direction? other) =>
            other != null &&
            DirectionTypes.SequenceEqual(other.DirectionTypes) &&
            EqualityComparer<Offset?>.Default.Equals(Offset, other.Offset) &&
            EqualityComparer<Staff?>.Default.Equals(Staff, other.Staff) &&
            EqualityComparer<Sound?>.Default.Equals(Sound, other.Sound) &&
            Placement == other.Placement &&
            Directive == other.Directive &&
            System == other.System &&
            Id == other.Id;

        public override int GetHashCode()
        {
            var hashCode = new HashCode();
            DirectionTypes.ForEach(dt => hashCode.Add(dt));
            hashCode.Add(Offset);
            hashCode.Add(Staff);
            hashCode.Add(Sound);
            hashCode.Add(Placement);
            hashCode.Add(Directive);
            hashCode.Add(System);
            hashCode.Add(Id);
            return hashCode.ToHashCode();
        }

        public override string ToString() =>
            $"Direction{{directionTypes: [{string.Join(", ", DirectionTypes)}], offset: {Offset}, staff: {Staff}, sound: {Sound}, placement: {Placement}, directive: {Directive}, system: {System}, id: {Id}}}";
    }
}
