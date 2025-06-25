// Assuming necessary using statements for MusicXML models, exceptions, and helpers
using System.Xml.Linq;
using System.Collections.Generic;
using System.Linq;
using MusicXMLParser.Models; // For Note, Pitch, Duration, Slur, Articulation, Tie, TimeModification etc.
// using MusicXMLParser.Enums; // Enums are in Models.Note now
using MusicXMLParser.Exceptions; // For MusicXmlStructureException, MusicXmlValidationException
using MusicXMLParser.Utils; // For WarningSystem and XmlHelper

namespace MusicXMLParser.Parser
{
    public class NoteParser
    {
        public WarningSystem WarningSystem { get; }

        public NoteParser(WarningSystem? warningSystem = null)
        {
            WarningSystem = warningSystem ?? new WarningSystem();
        }

        public Note? Parse(
            XElement element,
            int? parentDivisions,
            string partId,
            string measureNumber)
        {
            var line = XmlHelper.GetLineNumber(element);

            var isRest = element.Elements("rest").Any();
            Pitch pitch = null;

            if (!isRest)
            {
                var pitchElement = element.Elements("pitch").FirstOrDefault();
                if (pitchElement == null)
                {
                    throw new MusicXmlStructureException(
                        message: "Non-rest note is missing pitch element",
                        requiredElement: "pitch",
                        parentElement: "note",
                        line: line,
                        context: new Dictionary<string, object> { { "partId", partId }, { "measureNumber", measureNumber } }
                    );
                }
                pitch = ParsePitch(pitchElement, partId, measureNumber);
            }

            var durationElement = element.Elements("duration").FirstOrDefault();
            Duration duration = null;
            int? effectiveParentDivisions = parentDivisions;

            if (durationElement != null)
            {
                var durationValue = XmlHelper.GetElementTextAsInt(durationElement);
                if (durationValue.HasValue && durationValue.Value >= 0)
                {
                    if (!effectiveParentDivisions.HasValue || effectiveParentDivisions.Value <= 0)
                    {
                        WarningSystem.AddWarning(
                            message: "No valid divisions specified for note with duration. Using default divisions value 1.",
                            category: WarningCategories.NoteDivisions,
                            line: line,
                            context: new Dictionary<string, object>
                            {
                                { "part", partId }, { "measure", measureNumber },
                                { "original_divisions", parentDivisions }
                            }
                        );
                        effectiveParentDivisions = 1;
                    }
                    duration = new Duration(durationValue.Value, effectiveParentDivisions.Value);
                }
                else
                {
                    WarningSystem.AddWarning(
                        message: $"Invalid duration value: {durationValue} for note.",
                        category: WarningCategories.Validation, // Corrected category
                        rule: "note_duration_invalid",
                        line: line,
                        context: new Dictionary<string, object>
                        {
                            { "part", partId }, { "measure", measureNumber }, { "parsedDuration", durationValue?.ToString() }
                        }
                    );
                    return null;
                }
            }
            else
            {
                // This case should ideally not happen if XML is valid, as duration is required for a note.
                // If it does, it's a structural issue, or the note should be skipped.
                // For now, let's assume it's an error severe enough to not create a note.
                WarningSystem.AddWarning(
                    message: "Note without duration element present. Skipping note.",
                    category: WarningCategories.Structure, // Changed to Structure
                    rule: "note_missing_duration",
                    line: line,
                    elementName: "note",
                    context: new Dictionary<string, object>
                    {
                        { "part", partId }, { "measure", measureNumber }
                    }
                );
                return null; // Skip creating the note if duration is missing.
            }

            var typeElement = element.Elements("type").FirstOrDefault();
            var type = typeElement?.Value.Trim();

            var voiceElement = element.Elements("voice").FirstOrDefault();
            var voice = voiceElement?.Value.Trim();
            int? voiceNum = !string.IsNullOrEmpty(voice) && int.TryParse(voice, out int v) ? v : (int?)null;

            var dotElements = element.Elements("dot");
            int? dotsCount = dotElements.Any() ? dotElements.Count() : (int?)null;

            var timeModification = ParseTimeModification(
                element.Elements("time-modification").FirstOrDefault(),
                partId, measureNumber, line
            );

            var notationsData = ParseNotations(
                element.Elements("notations").FirstOrDefault(),
                partId, measureNumber, line
            );

            bool isChord = element.Elements("chord").Any();

            var noteBuilder = new NoteBuilder(line, new Dictionary<string, object>
            {
                { "part", partId }, { "measure", measureNumber }
            });

            var staffElement = element.Elements("staff").FirstOrDefault();
            int? staffNum = !string.IsNullOrEmpty(staffElement?.Value) && int.TryParse(staffElement.Value.Trim(), out int s) ? s : (int?)null;

            var stemElement = element.Elements("stem").FirstOrDefault();
            var stemStr = stemElement?.Value.Trim();
            StemDirection? stemDirection = stemStr switch {
                "up" => StemDirection.Up,
                "down" => StemDirection.Down,
                "double" => StemDirection.Double,
                "none" => StemDirection.None,
                _ => null
            };

            noteBuilder.SetDefaultX(XmlHelper.GetAttributeValueAsDouble(element, "default-x"));
            noteBuilder.SetDefaultY(XmlHelper.GetAttributeValueAsDouble(element, "default-y"));
            noteBuilder.SetDynamics(XmlHelper.GetAttributeValueAsDouble(element, "dynamics"));

            noteBuilder
                .SetIsRest(isRest)
                .SetPitch(pitch)
                .SetDuration(duration)
                .SetType(type)
                .SetVoice(voiceNum)
                .SetStaff(staffNum)
                .SetDots(dotsCount)
                .SetTimeModification(timeModification)
                .SetSlurs(notationsData.Slurs)
                .SetArticulations(notationsData.Articulations)
                .SetTies(notationsData.Ties)
                .SetIsChordElementPresent(isChord)
                .SetStemDirection(stemDirection);

            var accidentalElement = element.Element("accidental");
            if (accidentalElement != null)
            {
                noteBuilder.SetAccidental(ParseAccidentalEnum(accidentalElement.Value)); // Changed to use setter
            }

            // Removed try-catch for MusicXmlValidationException as NoteBuilder.Build() now calls new Note() directly.
            // Basic constructor argument checks in Note() will throw ArgumentException, which can be handled higher up if needed
            // or allowed to propagate to indicate a fundamental issue.
            // For now, letting ArgumentException propagate if basic invariants are violated.
            return noteBuilder.Build();
        }

        private TimeModification? ParseTimeModification( // Return type changed to nullable
            XElement? timeModificationElement, // Parameter changed to nullable
            string partId, string measureNumber, int noteLine)
        {
            if (timeModificationElement == null) return null;

            var tmLine = XmlHelper.GetLineNumber(timeModificationElement);
            var actualNotesElement = timeModificationElement.Elements("actual-notes").FirstOrDefault();
            var normalNotesElement = timeModificationElement.Elements("normal-notes").FirstOrDefault();

            if (actualNotesElement == null)
                throw new MusicXmlStructureException(
                    message: "<time-modification> is missing <actual-notes> element",
                    requiredElement: "actual-notes",
                    parentElement: "time-modification",
                    line: tmLine,
                    context: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber } });
            if (normalNotesElement == null)
                throw new MusicXmlStructureException(
                    message: "<time-modification> is missing <normal-notes> element",
                    requiredElement: "normal-notes",
                    parentElement: "time-modification",
                    line: tmLine,
                    context: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber } });

            var actualNotes = XmlHelper.GetElementTextAsInt(actualNotesElement);
            var normalNotes = XmlHelper.GetElementTextAsInt(normalNotesElement);

            if (!actualNotes.HasValue)
                throw new MusicXmlStructureException(
                    message: "<actual-notes> must contain an integer value",
                    parentElement: "time-modification",
                    line: XmlHelper.GetLineNumber(actualNotesElement),
                    context: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber } });
            if (!normalNotes.HasValue)
                throw new MusicXmlStructureException(
                    message: "<normal-notes> must contain an integer value",
                    parentElement: "time-modification",
                    line: XmlHelper.GetLineNumber(normalNotesElement),
                    context: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber } });

            var normalTypeElement = timeModificationElement.Elements("normal-type").FirstOrDefault();
            var normalType = normalTypeElement?.Value.Trim();
            var normalDotElements = timeModificationElement.Elements("normal-dot");
            int? normalDotCount = normalDotElements.Any() ? normalDotElements.Count() : (int?)null;

            // Directly construct TimeModification. Basic validation is in its constructor.
            // More complex MusicXML-specific validation is deferred.
            // ArgumentOutOfRangeException from constructor will propagate if basic invariants are violated.
            try
            {
                return new TimeModification(
                    actualNotes.Value,
                    normalNotes.Value,
                    normalType,
                    normalDotCount
                );
            }
            catch (ArgumentOutOfRangeException e)
            {
                // Optionally, catch ArgumentOutOfRangeException and convert to a warning or a more specific MusicXML exception.
                // For now, let it propagate or log a warning and return null.
                WarningSystem.AddWarning(
                    message: $"Invalid arguments for TimeModification: {e.Message}",
                    category: WarningCategories.Validation,
                    rule: "time_modification_invalid_arguments",
                    line: tmLine,
                    context: new Dictionary<string, object> {
                        { "part", partId }, { "measure", measureNumber }, { "noteLine", noteLine },
                        { "actualNotes", actualNotes.Value }, { "normalNotes", normalNotes.Value },
                        { "normalType", normalType ?? "null" }, {"normalDotCount", normalDotCount?.ToString() ?? "null" }
                    }
                );
                return null;
            }
        }

        private NotationsData ParseNotations(
            XElement? notationsElement, // Parameter changed to nullable
            string partId, string measureNumber, int noteLine)
        {
            if (notationsElement == null) return new NotationsData();

            var slurs = new List<Slur>();
            var articulations = new List<Articulation>();
            var ties = new List<Tie>();

            foreach (var notationChild in notationsElement.Elements())
            {
                switch (notationChild.Name.LocalName)
                {
                    case "slur":
                        var typeAttrSlur = notationChild.Attribute("type")?.Value;
                        if (string.IsNullOrEmpty(typeAttrSlur))
                            throw new MusicXmlStructureException(
                                message: "<slur> element missing required \"type\" attribute",
                                parentElement: "notations",
                                line: XmlHelper.GetLineNumber(notationChild),
                                context: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber }, { "noteLine", noteLine } });

                        var numberStrSlur = notationChild.Attribute("number")?.Value;
                        int numberAttrSlur = !string.IsNullOrEmpty(numberStrSlur) && int.TryParse(numberStrSlur, out int n) ? n : 1;
                        var placementAttrSlur = notationChild.Attribute("placement")?.Value;
                        slurs.Add(new Slur(typeAttrSlur, numberAttrSlur, placementAttrSlur));
                        break;
                    case "articulations":
                        foreach (var specificArtElement in notationChild.Elements())
                        {
                            var artType = specificArtElement.Name.LocalName;
                            if (!string.IsNullOrEmpty(artType))
                            {
                                var placementAttrArt = specificArtElement.Attribute("placement")?.Value;
                                articulations.Add(new Articulation(artType, placementAttrArt));
                            }
                        }
                        break;
                    case "tied":
                        var typeAttrTied = notationChild.Attribute("type")?.Value;
                        if (string.IsNullOrEmpty(typeAttrTied) || !new[] { "start", "stop", "continue" }.Contains(typeAttrTied))
                        {
                            WarningSystem.AddWarning(
                                message: $"<tied> element has invalid or missing \"type\" attribute. Found: \"{typeAttrTied}\". Skipping tie.",
                                category: WarningCategories.Structure,
                                line: XmlHelper.GetLineNumber(notationChild),
                                context: new Dictionary<string, object> { { "part", partId }, { "measure", measureNumber }, { "noteLine", noteLine } });
                        }
                        else
                        {
                            var placementAttrTied = notationChild.Attribute("placement")?.Value;
                            ties.Add(new Tie(typeAttrTied, placementAttrTied));
                        }
                        break;
                }
            }
            return new NotationsData(
                slurs.Any() ? slurs : null,
                articulations.Any() ? articulations : null,
                ties.Any() ? ties : null
            );
        }

        private Pitch ParsePitch(XElement element, string partId, string measureNumber)
        {
            // Assuming Pitch.FromXElement handles its own exceptions as in Dart
            return Pitch.FromXElement(element, partId, measureNumber);
        }

        private Accidental ParseAccidentalEnum(string text) // Renamed to use Accidental from Models.Note
        {
            return text switch
            {
                "sharp" => Accidental.Sharp,
                "flat" => Accidental.Flat,
                "natural" => Accidental.Natural,
                "double-sharp" => Accidental.DoubleSharp,
                "double-flat" => Accidental.DoubleFlat,
                "sharp-sharp" => Accidental.SharpSharp,
                "flat-flat" => Accidental.FlatFlat,
                "quarter-sharp" => Accidental.QuarterSharp,
                "quarter-flat" => Accidental.QuarterFlat,
                _ => Accidental.Other,
            };
        }
    }

    internal class NotationsData // Keep internal if only used by NoteParser
    {
        public List<Slur> Slurs { get; }
        public List<Articulation> Articulations { get; }
        public List<Tie> Ties { get; }

        public NotationsData(List<Slur> slurs = null, List<Articulation> articulations = null, List<Tie> ties = null)
        {
            Slurs = slurs;
            Articulations = articulations;
            Ties = ties;
        }
    }
}
