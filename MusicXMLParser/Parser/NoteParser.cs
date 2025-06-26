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
        
        // 缓存常用的上下文字典以减少内存分配
        private readonly Dictionary<string, object> _sharedContext = new();

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

            // 使用优化的方法检查元素存在性
            var isRest = XmlHelper.HasElement(element, "rest");
            Pitch? pitch = null;

            if (!isRest)
            {
                // 使用更高效的Element()方法
                var pitchElement = element.Element("pitch");
                if (pitchElement == null)
                {
                    throw new MusicXmlStructureException(
                        message: "Non-rest note is missing pitch element",
                        requiredElement: "pitch",
                        parentElement: "note",
                        line: line,
                        context: CreateContext(partId, measureNumber)
                    );
                }
                pitch = ParsePitch(pitchElement, partId, measureNumber);
            }

            // 使用优化的方法获取元素文本
            var durationValue = XmlHelper.GetElementTextAsInt(element, "duration");
            Duration? duration = null;
            int? effectiveParentDivisions = parentDivisions;

            if (durationValue.HasValue && durationValue.Value >= 0)
            {
                if (!effectiveParentDivisions.HasValue || effectiveParentDivisions.Value <= 0)
                {
                    WarningSystem.AddWarning(
                        message: "No valid divisions specified for note with duration. Using default divisions value 1.",
                        category: WarningCategories.NoteDivisions,
                        line: line,
                        context: CreateContext(partId, measureNumber, "original_divisions", parentDivisions)
                    );
                    effectiveParentDivisions = 1;
                }
                duration = new Duration(durationValue.Value, effectiveParentDivisions.Value);
            }
            else if (durationValue.HasValue)
            {
                WarningSystem.AddWarning(
                    message: $"Invalid duration value: {durationValue} for note.",
                    category: WarningCategories.Validation, // Corrected category
                    rule: "note_duration_invalid",
                    line: line,
                    context: CreateContext(partId, measureNumber, "parsedDuration", durationValue.ToString())
                );
                return null;
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
                    context: CreateContext(partId, measureNumber)
                );
                return null; // Skip creating the note if duration is missing.
            }

            // 使用优化的方法获取元素文本
            var type = XmlHelper.GetElementText(element, "type");
            var voice = XmlHelper.GetElementText(element, "voice");
            int? voiceNum = !string.IsNullOrEmpty(voice) && int.TryParse(voice, out int v) ? v : (int?)null;

            // 使用优化的方法计算元素数量
            var dotsCount = XmlHelper.GetElementCount(element, "dot");

            var timeModification = ParseTimeModification(
                element.Element("time-modification"),
                partId, measureNumber, line
            );

            var notationsData = ParseNotations(
                element.Element("notations"),
                partId, measureNumber, line
            );

            bool isChord = XmlHelper.HasElement(element, "chord");

            var noteBuilder = new NoteBuilder(line, CreateContext(partId, measureNumber));

            // 使用优化的方法获取属性值
            var staffNum = XmlHelper.GetAttributeValueAsInt(element, "staff");
            var stemStr = XmlHelper.GetAttributeValue(element, "stem");
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

        // 优化的上下文创建方法，减少内存分配
        private Dictionary<string, object> CreateContext(string partId, string measureNumber, string? additionalKey = null, object? additionalValue = null)
        {
            _sharedContext.Clear();
            _sharedContext["part"] = partId;
            _sharedContext["measure"] = measureNumber;
            
            if (additionalKey != null && additionalValue != null)
            {
                _sharedContext[additionalKey] = additionalValue;
            }
            
            return new Dictionary<string, object>(_sharedContext);
        }

        // 重载方法支持多个额外参数
        private Dictionary<string, object> CreateContext(string partId, string measureNumber, params object[] additionalPairs)
        {
            _sharedContext.Clear();
            _sharedContext["part"] = partId;
            _sharedContext["measure"] = measureNumber;
            
            for (int i = 0; i < additionalPairs.Length; i += 2)
            {
                if (i + 1 < additionalPairs.Length && additionalPairs[i] is string key)
                {
                    _sharedContext[key] = additionalPairs[i + 1];
                }
            }
            
            return new Dictionary<string, object>(_sharedContext);
        }

        private TimeModification? ParseTimeModification( // Return type changed to nullable
            XElement? timeModificationElement, // Parameter changed to nullable
            string partId, string measureNumber, int noteLine)
        {
            if (timeModificationElement == null) return null;

            var tmLine = XmlHelper.GetLineNumber(timeModificationElement);
            
            // 使用优化的方法获取元素
            var actualNotes = XmlHelper.GetElementTextAsInt(timeModificationElement, "actual-notes");
            var normalNotes = XmlHelper.GetElementTextAsInt(timeModificationElement, "normal-notes");

            if (!actualNotes.HasValue)
                throw new MusicXmlStructureException(
                    message: "<time-modification> is missing <actual-notes> element",
                    requiredElement: "actual-notes",
                    parentElement: "time-modification",
                    line: tmLine,
                    context: CreateContext(partId, measureNumber));
                    
            if (!normalNotes.HasValue)
                throw new MusicXmlStructureException(
                    message: "<time-modification> is missing <normal-notes> element",
                    requiredElement: "normal-notes",
                    parentElement: "time-modification",
                    line: tmLine,
                    context: CreateContext(partId, measureNumber));

            var normalType = XmlHelper.GetElementText(timeModificationElement, "normal-type");
            var normalDotCount = XmlHelper.GetElementCount(timeModificationElement, "normal-dot");

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
            catch (ArgumentOutOfRangeException)
            {
                throw new MusicXmlValidationException(
                    message: $"Invalid time modification values: actual={actualNotes}, normal={normalNotes}",
                    line: tmLine,
                    context: CreateContext(partId, measureNumber, "actualNotes", actualNotes, "normalNotes", normalNotes)
                );
            }
        }

        private NotationsData ParseNotations(
            XElement? notationsElement, // Parameter changed to nullable
            string partId, string measureNumber, int noteLine)
        {
            if (notationsElement == null)
                return new NotationsData();

            var slurs = new List<Slur>();
            var articulations = new List<Articulation>();
            var ties = new List<Tie>();

            foreach (var child in notationsElement.Elements())
            {
                switch (child.Name.LocalName)
                {
                    case "slur":
                        var slurType = XmlHelper.GetAttributeValue(child, "type");
                        var slurNumber = XmlHelper.GetAttributeValueAsInt(child, "number") ?? 1;
                        var slurPlacement = XmlHelper.GetAttributeValue(child, "placement");
                        if (!string.IsNullOrEmpty(slurType))
                        {
                            slurs.Add(new Slur(slurType, slurNumber, slurPlacement));
                        }
                        break;
                    case "articulations":
                        foreach (var articulationElement in child.Elements())
                        {
                            var articulationType = articulationElement.Name.LocalName;
                            var articulationPlacement = XmlHelper.GetAttributeValue(articulationElement, "placement");
                            articulations.Add(new Articulation(articulationType, articulationPlacement));
                        }
                        break;
                    case "tied":
                        var tieType = XmlHelper.GetAttributeValue(child, "type");
                        var tiePlacement = XmlHelper.GetAttributeValue(child, "placement");
                        if (!string.IsNullOrEmpty(tieType))
                        {
                            ties.Add(new Tie(tieType, tiePlacement));
                        }
                        break;
                }
            }

            return new NotationsData(slurs, articulations, ties);
        }

        private Pitch ParsePitch(XElement element, string partId, string measureNumber)
        {
            // 使用优化的方法获取元素文本
            var step = XmlHelper.GetElementText(element, "step");
            var octave = XmlHelper.GetElementTextAsInt(element, "octave");
            var alter = XmlHelper.GetElementTextAsInt(element, "alter");

            return new Pitch(step, octave ?? 0, alter);
        }

        private Accidental ParseAccidentalEnum(string text) // Renamed to use Accidental from Models.Note
        {
            return text.Trim().ToLowerInvariant() switch
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
                _ => Accidental.Other
            };
        }

        internal class NotationsData // Keep internal if only used by NoteParser
        {
            public List<Slur> Slurs { get; }
            public List<Articulation> Articulations { get; }
            public List<Tie> Ties { get; }

            public NotationsData(List<Slur>? slurs = null, List<Articulation>? articulations = null, List<Tie>? ties = null)
            {
                Slurs = slurs ?? new List<Slur>();
                Articulations = articulations ?? new List<Articulation>();
                Ties = ties ?? new List<Tie>();
            }
        }
    }
}
