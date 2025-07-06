using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using System.Xml;
using MusicXMLParser.Models;
using System.IO.Compression;
using System.Linq;

namespace MusicXMLParser
{
    public static class MusicXmlParser
    {
        public static Score GetScore(string filename)
        {
            if (filename.EndsWith(".mxl", StringComparison.OrdinalIgnoreCase))
            {
                using var archive = System.IO.Compression.ZipFile.OpenRead(filename);
                // 找到第一个 .xml 文件
                var entry = archive.Entries.FirstOrDefault(e => e.FullName.EndsWith(".xml", StringComparison.OrdinalIgnoreCase));
                if (entry == null)
                    throw new FileNotFoundException("No .xml file found in .mxl archive.");
                using var stream = entry.Open();
                return GetScore(GetXmlDocument(stream));
            }
            else
            {
                return GetScore(GetXmlDocumentFromFile(filename));
            }
        }

        public static Score GetScoreFromString(string str)
        {
            return GetScore(GetXmlDocumentFromString(str));
        }

        public static Score GetScore(Stream stream)
        {
            return GetScore(GetXmlDocument(stream));
        }

        private static Score GetScore(XmlDocument document)
        {
            var score = new Score();

            // 解析 movement-title
            var movementTitleNode = document.SelectSingleNode("score-partwise/movement-title");
            if (movementTitleNode != null)
                score.MovementTitle = movementTitleNode.InnerText;

            // 解析 identification
            score.Identification = GetIdentification(document);

            // 解析 work
            score.Work = GetWork(document);

            // 解析 parts
            var partNodes = document.SelectNodes("score-partwise/part-list/score-part");
            if (partNodes != null)
            {
                foreach (XmlNode partNode in partNodes)
                {
                    var part = new Part();
                    score.Parts.Add(part);

                    // 解析 part id
                    if (partNode.Attributes != null)
                    {
                        var idAttr = partNode.Attributes["id"];
                        if (idAttr != null)
                            part.Id = idAttr.InnerText;
                    }

                    // 解析 part-name
                    var partNameNode = partNode.SelectSingleNode("part-name");
                    if (partNameNode != null)
                        part.Name = partNameNode.InnerText;

                    // 解析 part-abbreviation
                    var partAbbrevNode = partNode.SelectSingleNode("part-abbreviation");
                    if (partAbbrevNode != null)
                        part.Abbreviation = partAbbrevNode.InnerText;

                    // 解析 measures
                    var measuresXpath = $"//part[@id='{part.Id}']/measure";
                    var measureNodes = document.SelectNodes(measuresXpath);

                    if (measureNodes != null)
                    {
                        foreach (XmlNode measureNode in measureNodes)
                        {
                            var measure = GetMeasure(measureNode);
                            part.Measures.Add(measure);
                        }
                    }
                }
            }

            return score;
        }

        private static Work GetWork(XmlNode document)
        {
            var workNode = document.SelectSingleNode("score-partwise/work");
            if (workNode == null) return null;

            var work = new Work();

            var workTitleNode = workNode.SelectSingleNode("work-title");
            if (workTitleNode != null)
                work.Title = workTitleNode.InnerText;

            var workNumberNode = workNode.SelectSingleNode("work-number");
            if (workNumberNode != null)
                work.Number = workNumberNode.InnerText;

            return work;
        }

        private static Measure GetMeasure(XmlNode measureNode)
        {
            var measure = new Measure();

            // 解析 measure 属性
            if (measureNode.Attributes != null)
            {
                var numberAttr = measureNode.Attributes["number"];
                if (numberAttr != null && int.TryParse(numberAttr.InnerText, out var number))
                    measure.Number = number;

                var widthAttr = measureNode.Attributes["width"];
                if (widthAttr != null && float.TryParse(widthAttr.InnerText, NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out var width))
                    measure.Width = width;
            }

            // 解析 attributes
            var attributesNode = measureNode.SelectSingleNode("attributes");
            if (attributesNode != null)
            {
                measure.Attributes = GetMeasureAttributes(attributesNode);
            }

            // 解析 measure 内容
            var childNodes = measureNode.ChildNodes;
            foreach (XmlNode node in childNodes)
            {
                switch (node.Name)
                {
                    case "note":
                        var note = GetNote(node);
                        measure.Notes.Add(note);
                        break;
                    case "direction":
                        var direction = GetDirection(node);
                        measure.Directions.Add(direction);
                        break;
                    case "barline":
                        var barline = GetBarline(node);
                        measure.Barlines.Add(barline);
                        break;
                    case "print":
                        // 处理 print 元素
                        break;
                }
            }

            return measure;
        }

        private static MeasureAttributes GetMeasureAttributes(XmlNode attributesNode)
        {
            var attributes = new MeasureAttributes();

            // 解析 divisions
            var divisionsNode = attributesNode.SelectSingleNode("divisions");
            if (divisionsNode != null)
                attributes.Divisions = Convert.ToInt32(divisionsNode.InnerText);

            // 解析 key
            var keyNode = attributesNode.SelectSingleNode("key");
            if (keyNode != null)
                attributes.Key = GetKeySignature(keyNode);

            // 解析 time
            var timeNode = attributesNode.SelectSingleNode("time");
            if (timeNode != null)
                attributes.Time = GetTimeSignature(timeNode);

            // 解析 clef (支持多个clef)
            var clefNodes = attributesNode.SelectNodes("clef");
            if (clefNodes != null)
            {
                foreach (XmlNode clefNode in clefNodes)
                {
                    var clef = GetClef(clefNode);
                    attributes.Clefs.Add(clef);
                }
            }

            return attributes;
        }

        private static KeySignature GetKeySignature(XmlNode keyNode)
        {
            var key = new KeySignature();

            var fifthsNode = keyNode.SelectSingleNode("fifths");
            if (fifthsNode != null)
                key.Fifths = Convert.ToInt32(fifthsNode.InnerText);

            var modeNode = keyNode.SelectSingleNode("mode");
            if (modeNode != null)
                key.Mode = modeNode.InnerText;

            return key;
        }

        private static TimeSignature GetTimeSignature(XmlNode timeNode)
        {
            var time = new TimeSignature();

            var beatsNode = timeNode.SelectSingleNode("beats");
            if (beatsNode != null)
                time.Beats = Convert.ToInt32(beatsNode.InnerText);

            var beatTypeNode = timeNode.SelectSingleNode("beat-type");
            if (beatTypeNode != null)
                time.BeatType = Convert.ToInt32(beatTypeNode.InnerText);

            return time;
        }

        private static Clef GetClef(XmlNode clefNode)
        {
            var clef = new Clef();

            // 解析 number 属性（对应staff编号）
            if (clefNode.Attributes != null)
            {
                var numberAttr = clefNode.Attributes["number"];
                if (numberAttr != null && int.TryParse(numberAttr.InnerText, out var staffNumber))
                    clef.Staff = staffNumber;
            }

            var signNode = clefNode.SelectSingleNode("sign");
            if (signNode != null)
                clef.Sign = signNode.InnerText;

            var lineNode = clefNode.SelectSingleNode("line");
            if (lineNode != null)
                clef.Line = Convert.ToInt32(lineNode.InnerText);

            var octaveChangeNode = clefNode.SelectSingleNode("octave-change");
            if (octaveChangeNode != null)
                clef.OctaveChange = Convert.ToInt32(octaveChangeNode.InnerText);

            return clef;
        }

        private static Note GetNote(XmlNode noteNode)
        {
            var note = new Note();

            // 解析 note 类型
            var typeNode = noteNode.SelectSingleNode("type");
            if (typeNode != null)
                note.Type = typeNode.InnerText;

            // 解析 voice
            var voiceNode = noteNode.SelectSingleNode("voice");
            if (voiceNode != null)
                note.Voice = Convert.ToInt32(voiceNode.InnerText);

            // 解析 duration
            var durationNode = noteNode.SelectSingleNode("duration");
            if (durationNode != null)
                note.Duration = Convert.ToInt32(durationNode.InnerText);

            // 解析 accidental
            var accidentalNode = noteNode.SelectSingleNode("accidental");
            if (accidentalNode != null)
                note.Accidental = accidentalNode.InnerText;

            // 解析 staff
            var staffNode = noteNode.SelectSingleNode("staff");
            if (staffNode != null)
                note.Staff = Convert.ToInt32(staffNode.InnerText);

            // 解析 chord
            var chordNode = noteNode.SelectSingleNode("chord");
            if (chordNode != null)
                note.IsChordTone = true;

            // 解析 rest
            var restNode = noteNode.SelectSingleNode("rest");
            if (restNode != null)
                note.IsRest = true;

            // 解析 grace
            var graceNode = noteNode.SelectSingleNode("grace");
            if (graceNode != null)
                note.IsGrace = true;

            // 解析 pitch
            note.Pitch = GetPitch(noteNode);

            // 解析 tie
            note.Tie = GetTie(noteNode);

            // 解析 slur
            note.Slur = GetSlur(noteNode);

            // 解析 beam
            note.Beams = GetBeams(noteNode);

            return note;
        }

        private static Pitch GetPitch(XmlNode noteNode)
        {
            var pitchNode = noteNode.SelectSingleNode("pitch");
            if (pitchNode == null) return null;

            var pitch = new Pitch();

            var stepNode = pitchNode.SelectSingleNode("step");
            if (stepNode != null)
                pitch.Step = stepNode.InnerText[0];

            var alterNode = pitchNode.SelectSingleNode("alter");
            if (alterNode != null)
                pitch.Alter = Convert.ToInt32(alterNode.InnerText);

            var octaveNode = pitchNode.SelectSingleNode("octave");
            if (octaveNode != null)
                pitch.Octave = Convert.ToInt32(octaveNode.InnerText);

            return pitch;
        }

        private static Tie GetTie(XmlNode noteNode)
        {
            var tieNode = noteNode.SelectSingleNode("tie");
            if (tieNode?.Attributes == null) return null;

            var tie = new Tie();

            var typeAttr = tieNode.Attributes["type"];
            if (typeAttr != null)
            {
                tie.Type = typeAttr.Value switch
                {
                    "start" => TieType.Start,
                    "stop" => TieType.Stop,
                    _ => TieType.Start
                };
            }

            return tie;
        }

        private static Slur GetSlur(XmlNode noteNode)
        {
            var notationsNode = noteNode.SelectSingleNode("notations");
            if (notationsNode == null) return null;

            var slurNode = notationsNode.SelectSingleNode("slur");
            if (slurNode?.Attributes == null) return null;

            var slur = new Slur();

            var numberAttr = slurNode.Attributes["number"];
            if (numberAttr != null)
                slur.Number = Convert.ToInt32(numberAttr.Value);

            var typeAttr = slurNode.Attributes["type"];
            if (typeAttr != null)
            {
                slur.Type = typeAttr.Value switch
                {
                    "start" => SlurType.Start,
                    "stop" => SlurType.Stop,
                    "continue" => SlurType.Continue,
                    _ => SlurType.Start
                };
            }

            return slur;
        }

        private static List<Beam> GetBeams(XmlNode noteNode)
        {
            var beams = new List<Beam>();
            var beamNodes = noteNode.SelectNodes("beam");

            if (beamNodes != null)
            {
                foreach (XmlNode beamNode in beamNodes)
                {
                    var beam = new Beam();

                    var numberAttr = beamNode.Attributes["number"];
                    if (numberAttr != null)
                        beam.Number = Convert.ToInt32(numberAttr.Value);

                    beam.Type = beamNode.InnerText switch
                    {
                        "begin" => BeamType.Begin,
                        "continue" => BeamType.Continue,
                        "end" => BeamType.End,
                        "backward hook" => BeamType.BackwardHook,
                        "forward hook" => BeamType.ForwardHook,
                        _ => BeamType.Begin
                    };

                    beams.Add(beam);
                }
            }

            return beams;
        }

        private static Direction GetDirection(XmlNode directionNode)
        {
            var direction = new Direction();

            var directionTypeNode = directionNode.SelectSingleNode("direction-type");
            if (directionTypeNode != null)
            {
                // 解析 direction-type 内容
                var wordsNode = directionTypeNode.SelectSingleNode("words");
                if (wordsNode != null)
                {
                    direction.Words = wordsNode.InnerText;
                }

                var dynamicsNode = directionTypeNode.SelectSingleNode("dynamics");
                if (dynamicsNode != null)
                {
                    direction.Dynamics = GetDynamics(dynamicsNode);
                }
            }

            return direction;
        }

        private static Dynamics GetDynamics(XmlNode dynamicsNode)
        {
            var dynamics = new Dynamics();

            // 解析各种力度标记
            var childNodes = dynamicsNode.ChildNodes;
            foreach (XmlNode node in childNodes)
            {
                switch (node.Name)
                {
                    case "p":
                        dynamics.Piano = true;
                        break;
                    case "f":
                        dynamics.Forte = true;
                        break;
                    case "mp":
                        dynamics.MezzoPiano = true;
                        break;
                    case "mf":
                        dynamics.MezzoForte = true;
                        break;
                    case "pp":
                        dynamics.Pianissimo = true;
                        break;
                    case "ff":
                        dynamics.Fortissimo = true;
                        break;
                }
            }

            return dynamics;
        }

        private static Barline GetBarline(XmlNode barlineNode)
        {
            var barline = new Barline();

            var locationAttr = barlineNode.Attributes["location"];
            if (locationAttr != null)
            {
                barline.Location = locationAttr.Value switch
                {
                    "left" => BarlineLocation.Left,
                    "right" => BarlineLocation.Right,
                    "middle" => BarlineLocation.Middle,
                    _ => BarlineLocation.Right
                };
            }

            var barStyleNode = barlineNode.SelectSingleNode("bar-style");
            if (barStyleNode != null)
            {
                barline.Style = barStyleNode.InnerText switch
                {
                    "regular" => BarlineStyle.Regular,
                    "dotted" => BarlineStyle.Dotted,
                    "dashed" => BarlineStyle.Dashed,
                    "heavy" => BarlineStyle.Heavy,
                    "light-light" => BarlineStyle.LightLight,
                    "light-heavy" => BarlineStyle.LightHeavy,
                    "heavy-light" => BarlineStyle.HeavyLight,
                    "heavy-heavy" => BarlineStyle.HeavyHeavy,
                    "tick" => BarlineStyle.Tick,
                    "short" => BarlineStyle.Short,
                    "none" => BarlineStyle.None,
                    _ => BarlineStyle.Regular
                };
            }

            return barline;
        }

        private static Identification GetIdentification(XmlNode document)
        {
            var identificationNode = document.SelectSingleNode("score-partwise/identification");
            if (identificationNode == null) return null;

            var identification = new Identification();

            var composerNode = identificationNode.SelectSingleNode("creator[@type='composer']");
            if (composerNode != null)
                identification.Composer = composerNode.InnerText;

            var rightsNode = identificationNode.SelectSingleNode("rights");
            if (rightsNode != null)
                identification.Rights = rightsNode.InnerText;

            var encodingNode = identificationNode.SelectSingleNode("encoding");
            if (encodingNode != null)
                identification.Encoding = GetEncoding(encodingNode);

            return identification;
        }

        private static MusicXMLParser.Models.Encoding GetEncoding(XmlNode encodingNode)
        {
            var encoding = new MusicXMLParser.Models.Encoding();

            var softwareNode = encodingNode.SelectSingleNode("software");
            if (softwareNode != null)
                encoding.Software = softwareNode.InnerText;

            var encodingDateNode = encodingNode.SelectSingleNode("encoding-date");
            if (encodingDateNode != null)
                encoding.EncodingDate = Convert.ToDateTime(encodingDateNode.InnerText);

            return encoding;
        }

        private static XmlDocument GetXmlDocumentFromString(string str)
        {
            var document = new XmlDocument();
            document.XmlResolver = null;
            document.LoadXml(str);
            return document;
        }

        private static XmlDocument GetXmlDocumentFromFile(string fileName)
        {
            var document = new XmlDocument();
            document.XmlResolver = null;
            document.Load(fileName);
            return document;
        }

        private static XmlDocument GetXmlDocument(Stream stream)
        {
            var document = new XmlDocument();
            document.XmlResolver = null;
            document.Load(stream);
            return document;
        }
    }
} 