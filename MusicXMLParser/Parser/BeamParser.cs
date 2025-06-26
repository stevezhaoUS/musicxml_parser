// Assuming the necessary using statements for MusicXML models
// e.g., using MusicXMLParser.Models;
using System.Xml.Linq;
using System.Collections.Generic;
using System.Linq;
using MusicXMLParser.Models; // Assuming this is where Beam model is

namespace MusicXMLParser.Parser
{
    public static class BeamParser
    {
        /// <summary>
        /// Parses beam elements from a note element.
        /// </summary>
        /// <param name="noteElement">The XML element representing the note.</param>
        /// <param name="noteIndex">The index of the note within the measure.</param>
        /// <param name="measureNumber">The measure number this beam belongs to.</param>
        /// <returns>A list of Beam objects parsed from the note element.</returns>
        public static List<Beam> Parse(
            XElement noteElement, int noteIndex, string measureNumber)
        {
            var beams = new List<Beam>();

            var beamElements = noteElement.Elements("beam");
            foreach (var beamElement in beamElements)
            {
                var beamType = beamElement.Value.Trim();
                var beamNumberAttr = beamElement.Attribute("number")?.Value;
                var beamNumber = !string.IsNullOrEmpty(beamNumberAttr) && int.TryParse(beamNumberAttr, out int num) ? num : 1;

                beams.Add(new Beam(
                    number: beamNumber,
                    type: beamType,
                    measureNumber: measureNumber,
                    noteIndices: new List<int> { noteIndex } // Will be merged later
                ));
            }

            return beams;
        }

        /// <summary>
        /// Merges individual note beam elements into complete beam groups.
        /// This method connects related beam elements based on their number and type (begin, continue, end)
        /// attributes to form complete beam groups.
        /// </summary>
        /// <param name="individualBeams">A list of beams, each associated with a single note.</param>
        /// <param name="measureNumber">The measure number these beams belong to.</param>
        /// <returns>A list of merged Beam objects representing complete beam groups.</returns>
        public static List<Beam> MergeBeams(
            List<Beam> individualBeams, string measureNumber)
        {
            if (individualBeams == null || !individualBeams.Any()) return new List<Beam>();

            // Group beams by beam number
            var beamsByNumber = individualBeams
                .GroupBy(b => b.Number)
                .ToDictionary(g => g.Key, g => g.ToList());

            var result = new List<Beam>();

            // Process each beam number separately
            foreach (var entry in beamsByNumber)
            {
                var number = entry.Key;
                var beams = entry.Value;

                // Sort beams by noteIndex to ensure correct order
                beams.Sort((a, b) => a.NoteIndices.First().CompareTo(b.NoteIndices.First()));

                // Temporary storage for the currently processed beam group
                Beam? currentBeamContext = null;
                List<int> currentNoteIndices = new List<int>();
                string? currentType = null; // Stores the type of the start of the beam ('begin')

                // Process each beam in order
                foreach (var beam in beams)
                {
                    // If current beam is 'begin' or the previous beam group is completed, start a new beam group
                    if (beam.Type == "begin" || currentBeamContext == null)
                    {
                        // If there's an unfinished beam group, add it to the result
                        if (currentBeamContext != null && currentNoteIndices.Any())
                        {
                            result.Add(new Beam(
                                number: currentBeamContext.Number,
                                type: currentType ?? "unknown", // Should be the type of the first beam in the group
                                measureNumber: measureNumber,
                                noteIndices: new List<int>(currentNoteIndices)
                            ));
                        }

                        // Start a new beam group
                        currentBeamContext = beam;
                        currentType = beam.Type; // This is the 'begin' type
                        currentNoteIndices = new List<int>(beam.NoteIndices);
                    }
                    // If it's 'continue' or 'end', add to the current beam group
                    else if (beam.Type == "continue" || beam.Type == "end")
                    {
                        if (currentBeamContext != null) // Ensure there's an active beam group
                        {
                            currentNoteIndices.AddRange(beam.NoteIndices);

                            // If it's 'end', complete the current beam group
                            if (beam.Type == "end")
                            {
                                result.Add(new Beam(
                                    number: currentBeamContext.Number,
                                    type: currentType, // Use the stored 'begin' type
                                    measureNumber: measureNumber,
                                    noteIndices: new List<int>(currentNoteIndices)
                                ));

                                // Reset state
                                currentBeamContext = null;
                                currentNoteIndices = new List<int>();
                                currentType = null;
                            }
                        }
                        else
                        {
                            // This case (continue/end without a begin) might indicate a malformed MusicXML
                            // or a beam starting mid-measure without a prior 'begin' in this segment.
                            // Depending on strictness, this could be an error or handled gracefully.
                            // For now, we'll create a new beam segment.
                             result.Add(new Beam(
                                number: beam.Number,
                                type: beam.Type, // Could be 'continue' or 'end'
                                measureNumber: measureNumber,
                                noteIndices: new List<int>(beam.NoteIndices)
                            ));
                        }
                    }
                    // For standalone 'forward hook' or 'backward hook'
                    else if (beam.Type == "forward hook" || beam.Type == "backward hook")
                    {
                        // These are typically independent and added directly to the result
                        result.Add(beam);
                    }
                }

                // Handle any remaining unfinished beam group
                if (currentBeamContext != null && currentNoteIndices.Any())
                {
                    result.Add(new Beam(
                        number: currentBeamContext.Number,
                        type: currentType ?? "unknown",
                        measureNumber: measureNumber,
                        noteIndices: new List<int>(currentNoteIndices)
                    ));
                }
            }
            return result;
        }
    }
}
