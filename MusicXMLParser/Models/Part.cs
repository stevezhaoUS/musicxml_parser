using System;
using System.Collections.Generic;
using System.Linq;

namespace MusicXMLParser.Models
{
    /// <summary>
    /// Represents a single part (e.g., a single instrument or voice) within a musical score.
    /// </summary>
    /// <remarks>
    /// A part consists of a unique <see cref="Id"/>, an optional <see cref="Name"/>, and a list of <see cref="Measures"/>
    /// that make up the musical content of the part.
    /// Instances are typically created via <see cref="PartBuilder"/>.
    /// Objects of this class are immutable once created by the builder.
    /// </remarks>
    public class Part
    {
        /// <summary>
        /// The unique identifier for this part within the score.
        /// </summary>
        public string Id { get; }

        /// <summary>
        /// The display name of the part (e.g., "Violin I", "Piano Left Hand").
        /// </summary>
        public string Name { get; }

        /// <summary>
        /// The list of <see cref="Measure"/> objects that constitute this part.
        /// </summary>
        public List<Measure> Measures { get; }

        /// <summary>
        /// Creates a new <see cref="Part"/> instance.
        /// </summary>
        /// <remarks>
        /// It is generally recommended to use <see cref="PartBuilder"/> for constructing <see cref="Part"/>
        /// objects, especially during parsing.
        /// </remarks>
        public Part(string id, string name, List<Measure> measures)
        {
            Id = id;
            Name = name;
            Measures = measures;
        }

        public override bool Equals(object obj)
        {
            if (obj is Part other)
            {
                return Id == other.Id &&
                       Name == other.Name &&
                       Measures.SequenceEqual(other.Measures);
            }
            return false;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Id, Name, Measures);
        }

        public override string ToString() =>
            $"Part{{Id: {Id}, Name: {Name}, Measures: {Measures.Count}}}";
    }

    /// <summary>
    /// Builder for creating <see cref="Part"/> objects incrementally.
    /// </summary>
    /// <remarks>
    /// This builder is useful during the parsing process for MusicXML &lt;part&gt; elements,
    /// allowing measures to be added one by one as they are parsed.
    /// The <see cref="Build"/> method finalizes the part construction.
    /// </remarks>
    /// <example>
    /// <code>
    /// var partBuilder = new PartBuilder("P1").SetName("Flute");
    /// partBuilder.AddMeasure(firstMeasure);
    /// partBuilder.AddMeasure(secondMeasure);
    /// Part flutePart = partBuilder.Build();
    /// </code>
    /// </example>
    public class PartBuilder
    {
        private readonly string _id;
        private string _name;
        private List<Measure> _measures = new List<Measure>();

        /// <summary>
        /// Creates a <see cref="PartBuilder"/> for a part with the given <paramref name="id"/>.
        /// </summary>
        public PartBuilder(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                throw new ArgumentException("Part ID cannot be null or empty.", nameof(id));
            }
            _id = id;
        }

        /// <summary>
        /// Sets the name of the part.
        /// </summary>
        public PartBuilder SetName(string name)
        {
            _name = name;
            return this;
        }

        /// <summary>
        /// Sets all measures for the part.
        /// </summary>
        public PartBuilder SetMeasures(List<Measure> measures)
        {
            _measures = measures ?? new List<Measure>();
            return this;
        }

        /// <summary>
        /// Adds a single <see cref="Measure"/> to the part.
        /// </summary>
        public PartBuilder AddMeasure(Measure measure)
        {
            if (measure != null)
            {
                _measures.Add(measure);
            }
            return this;
        }

        /// <summary>
        /// Builds the <see cref="Part"/> instance.
        /// </summary>
        /// <remarks>
        /// This method constructs the <see cref="Part"/> object from the properties set
        /// on the builder.
        /// </remarks>
        public Part Build()
        {
            return new Part(_id, _name, _measures);
        }
    }
}
