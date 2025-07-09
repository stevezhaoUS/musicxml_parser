using System.Reflection;
using MusicXMLParser.Models;

namespace MusicXMLParser.Tests;

public class BasicTests
{
    [Fact]
    public void ParseFileSync_LargeXml_ShouldReturnValidScore()
    {
        // Arrange
        var filePath = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!, "TestData", "large.xml");

        // Act
        var score = MusicXmlParser.GetScore(filePath);

        // Assert (basic checks, can be expanded as needed)
        Assert.NotNull(score);
        Assert.NotNull(score.Parts);
        Assert.True(score.Parts.Count > 0);
        Assert.True(score.Parts[0].Measures.Count > 0);
        // Optionally print some info for debug
        Console.WriteLine($"[ParseFileSync] Work: {score.Work?.Title}");
        Console.WriteLine($"[ParseFileSync] Parts: {score.Parts.Count}");
        Console.WriteLine($"[ParseFileSync] First part name: {score.Parts[0].Name}");
        Console.WriteLine($"[ParseFileSync] First measure notes: {score.Parts[0].Measures[0].Notes.Count}");
    }
    [Fact]
    public void Parse_LargeXml_ShouldReturnValidScore()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("large.xml");

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert (basic checks, can be expanded as needed)
        Assert.NotNull(score);
        Assert.NotNull(score.Parts);
        Assert.True(score.Parts.Count > 0);
        Assert.True(score.Parts[0].Measures.Count > 0);
        // Optionally print some info for debug
        Console.WriteLine($"Work: {score.Work?.Title}");
        Console.WriteLine($"Parts: {score.Parts.Count}");
        Console.WriteLine($"First part name: {score.Parts[0].Name}");
        Console.WriteLine($"First measure notes: {score.Parts[0].Measures[0].Notes.Count}");
    }
    [Fact]
    public void Parse_SimpleXml_ShouldReturnValidScore()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("simple.xml");

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Debug: 输出实际解析结果
        Console.WriteLine($"Score: {score}");
        Console.WriteLine($"Work: {score.Work}");
        Console.WriteLine($"Parts count: {score.Parts?.Count ?? 0}");
        if (score.Parts?.Count > 0)
        {
            Console.WriteLine($"First part: {score.Parts[0]}");
            Console.WriteLine($"Measures count: {score.Parts[0].Measures?.Count ?? 0}");
        }

        // Assert
        Assert.Single(score.Parts);
        Assert.Equal("P1", score.Parts[0].Id);
        Assert.Equal("Piano", score.Parts[0].Name);
        Assert.Single(score.Parts[0].Measures);
        Assert.Equal(1, score.Parts[0].Measures[0].Number);
        Assert.Equal(4, score.Parts[0].Measures[0].Notes.Count);
        Assert.Equal('C', score.Parts[0].Measures[0].Notes[0].Pitch.Step);
        Assert.Equal(4, score.Parts[0].Measures[0].Notes[0].Pitch.Octave);
        Assert.Equal(1, score.Parts[0].Measures[0].Notes[0].Duration);
        Assert.Equal("quarter", score.Parts[0].Measures[0].Notes[0].Type);
    }

    [Fact]
    public void Parse_ComplexXml_ShouldReturnValidScore()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("complex.xml");

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert
        Assert.Equal("Für Elise", score.Work.Title);
        Assert.Equal("arr. Verona", score.Identification.Composer);
        Assert.Equal("pianolessenassen.nl/bladmuziek", score.Identification.Rights);
        Assert.Single(score.Parts);
        Assert.Equal("P1", score.Parts[0].Id);
        Assert.Equal("Piano", score.Parts[0].Name);
    }

    [Fact]
    public void Parse_WithKeySignature_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("simple.xml");

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.NotNull(measure.Attributes?.Key);
        Assert.Equal(0, measure.Attributes.Key.Fifths);
    }

    [Fact]
    public void Parse_WithTimeSignature_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("simple.xml");

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.NotNull(measure.Attributes?.Time);
        Assert.Equal(4, measure.Attributes.Time.Beats);
        Assert.Equal(4, measure.Attributes.Time.BeatType);
    }

    [Fact]
    public void Parse_WithClef_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("simple.xml");

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.NotNull(measure.Attributes?.Clefs);
        Assert.Single(measure.Attributes.Clefs); // 应该只有一个clef
        Assert.Equal("G", measure.Attributes.Clefs[0].Sign);
        Assert.Equal(2, measure.Attributes.Clefs[0].Line);
        Assert.Equal(1, measure.Attributes.Clefs[0].Staff); // 默认staff为1
    }

    [Fact]
    public void Parse_WithNotes_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("simple.xml");

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.Equal(4, measure.Notes.Count);
        Assert.Equal('C', measure.Notes[0].Pitch.Step);
        Assert.Equal(4, measure.Notes[0].Pitch.Octave);
        Assert.Equal('D', measure.Notes[1].Pitch.Step);
        Assert.Equal(4, measure.Notes[1].Pitch.Octave);
        Assert.Equal('E', measure.Notes[2].Pitch.Step);
        Assert.Equal(4, measure.Notes[2].Pitch.Octave);
        Assert.Equal('F', measure.Notes[3].Pitch.Step);
        Assert.Equal(4, measure.Notes[3].Pitch.Octave);
    }

    [Fact]
    public void Parse_WithBarline_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("simple.xml");

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.Empty(measure.Barlines); // small.xml没有barline
    }

    [Fact]
    public void Parse_InvalidXml_ShouldThrowException()
    {
        // Arrange
        var invalidXml = "<invalid>xml"; // 缺少闭合标签，必定抛出 XmlException

        // Act & Assert
        Assert.Throws<System.Xml.XmlException>(() => MusicXmlParser.GetScoreFromString(invalidXml));
    }

    [Fact]
    public void Parse_EmptyXml_ShouldThrowException()
    {
        // Arrange
        var emptyXml = "";

        // Act & Assert
        Assert.Throws<System.Xml.XmlException>(() => MusicXmlParser.GetScoreFromString(emptyXml));
    }

    [Fact]
    public void Parse_NullXml_ShouldThrowException()
    {
        // Arrange
        string? nullXml = null;

        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => MusicXmlParser.GetScoreFromString(nullXml!));
    }

    [Fact]
    public void ParseFileSync_LargeMxl_ShouldReturnValidScore()
    {
        // Arrange
        var filePath = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!, "TestData", "large.mxl");

        // Act
        var score = MusicXmlParser.GetScore(filePath);

        // Assert（与 large.xml 测试一致）
        Assert.NotNull(score);
        Assert.NotNull(score.Parts);
        Assert.True(score.Parts.Count > 0);
        Assert.True(score.Parts[0].Measures.Count > 0);
        // Optionally print some info for debug
        Console.WriteLine($"[ParseFileSync-MXL] Work: {score.Work?.Title}");
        Console.WriteLine($"[ParseFileSync-MXL] Parts: {score.Parts.Count}");
        Console.WriteLine($"[ParseFileSync-MXL] First part name: {score.Parts[0].Name}");
        Console.WriteLine($"[ParseFileSync-MXL] First measure notes: {score.Parts[0].Measures[0].Notes.Count}");
    }

    [Fact]
    public void Parse_MeasureWidth_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("complex.xml");

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.Equal(160.41f, measure.Width); // 第一个measure的width应该是160.41
        
        // 检查其他measure的width
        var measure14 = score.Parts[0].Measures[14];
        Assert.Equal(313.46f, measure14.Width);
        
        var measure33 = score.Parts[0].Measures[33];
        Assert.Equal(539.03f, measure33.Width);
    }

    [Fact]
    public void Parse_WithForward_ShouldInsertRestNotes()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("forward.xml");

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert
        Assert.Single(score.Parts);
        Assert.Equal("P1", score.Parts[0].Id);
        Assert.Equal("Piano", score.Parts[0].Name);
        Assert.Equal(2, score.Parts[0].Measures.Count);

        // 检查第一个measure
        var measure1 = score.Parts[0].Measures[0];
        Assert.Equal(1, measure1.Number);
        Assert.Equal(4, measure1.Notes.Count); // 2个音符 + 2个forward生成的rest

        // 检查音符
        Assert.Equal('C', measure1.Notes[0].Pitch.Step);
        Assert.Equal(4, measure1.Notes[0].Pitch.Octave);
        Assert.Equal(480, measure1.Notes[0].Duration);
        Assert.Equal("quarter", measure1.Notes[0].Type);
        Assert.False(measure1.Notes[0].IsRest);

        // 检查第一个forward生成的rest
        Assert.True(measure1.Notes[1].IsRest);
        Assert.Equal(480, measure1.Notes[1].Duration);
        Assert.Equal("quarter", measure1.Notes[1].Type);
        Assert.Null(measure1.Notes[1].Pitch);

        // 检查音符
        Assert.Equal('E', measure1.Notes[2].Pitch.Step);
        Assert.Equal(4, measure1.Notes[2].Pitch.Octave);
        Assert.Equal(480, measure1.Notes[2].Duration);
        Assert.Equal("quarter", measure1.Notes[2].Type);
        Assert.False(measure1.Notes[2].IsRest);

        // 检查第二个forward生成的rest
        Assert.True(measure1.Notes[3].IsRest);
        Assert.Equal(960, measure1.Notes[3].Duration);
        Assert.Equal("half", measure1.Notes[3].Type);
        Assert.Null(measure1.Notes[3].Pitch);

        // 检查第二个measure
        var measure2 = score.Parts[0].Measures[1];
        Assert.Equal(2, measure2.Number);
        Assert.Equal(3, measure2.Notes.Count); // 2个音符 + 1个forward生成的rest

        // 检查音符
        Assert.Equal('G', measure2.Notes[0].Pitch.Step);
        Assert.Equal(4, measure2.Notes[0].Pitch.Octave);
        Assert.Equal(480, measure2.Notes[0].Duration);
        Assert.Equal("quarter", measure2.Notes[0].Type);
        Assert.False(measure2.Notes[0].IsRest);

        // 检查forward生成的rest
        Assert.True(measure2.Notes[1].IsRest);
        Assert.Equal(240, measure2.Notes[1].Duration);
        Assert.Equal("eighth", measure2.Notes[1].Type);
        Assert.Null(measure2.Notes[1].Pitch);

        // 检查音符
        Assert.Equal('A', measure2.Notes[2].Pitch.Step);
        Assert.Equal(4, measure2.Notes[2].Pitch.Octave);
        Assert.Equal(720, measure2.Notes[2].Duration);
        Assert.Equal("dotted-half", measure2.Notes[2].Type);
        Assert.False(measure2.Notes[2].IsRest);
    }

    [Fact]
    public void Parse_ForwardWithoutDuration_ShouldNotInsertRest()
    {
        // Arrange
        var xmlContent = @"<?xml version=""1.0"" encoding=""UTF-8""?>
<score-partwise version=""3.1"">
  <part-list>
    <score-part id=""P1"">
      <part-name>Piano</part-name>
    </score-part>
  </part-list>
  <part id=""P1"">
    <measure number=""1"">
      <attributes>
        <divisions>480</divisions>
      </attributes>
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>480</duration>
        <type>quarter</type>
      </note>
      <forward>
        <!-- 没有duration子元素 -->
      </forward>
    </measure>
  </part>
</score-partwise>";

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.Single(measure.Notes); // 只有原始音符，没有rest
        Assert.Equal('C', measure.Notes[0].Pitch.Step);
        Assert.False(measure.Notes[0].IsRest);
    }

    [Fact]
    public void Parse_ForwardWithInvalidDuration_ShouldNotInsertRest()
    {
        // Arrange
        var xmlContent = @"<?xml version=""1.0"" encoding=""UTF-8""?>
<score-partwise version=""3.1"">
  <part-list>
    <score-part id=""P1"">
      <part-name>Piano</part-name>
    </score-part>
  </part-list>
  <part id=""P1"">
    <measure number=""1"">
      <attributes>
        <divisions>480</divisions>
      </attributes>
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>480</duration>
        <type>quarter</type>
      </note>
      <forward>
        <duration>invalid</duration>
      </forward>
    </measure>
  </part>
</score-partwise>";

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.Single(measure.Notes); // 只有原始音符，没有rest
        Assert.Equal('C', measure.Notes[0].Pitch.Step);
        Assert.False(measure.Notes[0].IsRest);
    }

    [Fact]
    public void Parse_WithBackup_ShouldInsertRestNotes()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("backup.xml");

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert
        Assert.Single(score.Parts);
        Assert.Equal("P1", score.Parts[0].Id);
        Assert.Equal("Piano", score.Parts[0].Name);
        Assert.Equal(2, score.Parts[0].Measures.Count);

        // 检查第一个measure - backup会插入rest note
        var measure1 = score.Parts[0].Measures[0];
        Assert.Equal(1, measure1.Number);
        Assert.Equal(4, measure1.Notes.Count); // 2个音符 + 2个backup生成的rest

        // 检查音符
        Assert.Equal('C', measure1.Notes[0].Pitch.Step);
        Assert.Equal(4, measure1.Notes[0].Pitch.Octave);
        Assert.Equal(480, measure1.Notes[0].Duration);
        Assert.Equal("quarter", measure1.Notes[0].Type);
        Assert.False(measure1.Notes[0].IsRest);

        // 检查第一个backup生成的rest
        Assert.True(measure1.Notes[1].IsRest);
        Assert.Equal(480, measure1.Notes[1].Duration);
        Assert.Equal("quarter", measure1.Notes[1].Type);
        Assert.Null(measure1.Notes[1].Pitch);

        // 检查音符
        Assert.Equal('E', measure1.Notes[2].Pitch.Step);
        Assert.Equal(4, measure1.Notes[2].Pitch.Octave);
        Assert.Equal(480, measure1.Notes[2].Duration);
        Assert.Equal("quarter", measure1.Notes[2].Type);
        Assert.False(measure1.Notes[2].IsRest);

        // 检查第二个backup生成的rest
        Assert.True(measure1.Notes[3].IsRest);
        Assert.Equal(960, measure1.Notes[3].Duration);
        Assert.Equal("half", measure1.Notes[3].Type);
        Assert.Null(measure1.Notes[3].Pitch);

        // 检查第二个measure
        var measure2 = score.Parts[0].Measures[1];
        Assert.Equal(2, measure2.Number);
        Assert.Equal(3, measure2.Notes.Count); // 2个音符 + 1个backup生成的rest

        // 检查音符
        Assert.Equal('G', measure2.Notes[0].Pitch.Step);
        Assert.Equal(4, measure2.Notes[0].Pitch.Octave);
        Assert.Equal(480, measure2.Notes[0].Duration);
        Assert.Equal("quarter", measure2.Notes[0].Type);
        Assert.False(measure2.Notes[0].IsRest);

        // 检查backup生成的rest
        Assert.True(measure2.Notes[1].IsRest);
        Assert.Equal(240, measure2.Notes[1].Duration);
        Assert.Equal("eighth", measure2.Notes[1].Type);
        Assert.Null(measure2.Notes[1].Pitch);

        // 检查音符
        Assert.Equal('A', measure2.Notes[2].Pitch.Step);
        Assert.Equal(4, measure2.Notes[2].Pitch.Octave);
        Assert.Equal(720, measure2.Notes[2].Duration);
        Assert.Equal("dotted-half", measure2.Notes[2].Type);
        Assert.False(measure2.Notes[2].IsRest);
    }

    [Fact]
    public void Parse_BackupWithoutDuration_ShouldNotInsertRest()
    {
        // Arrange
        var xmlContent = @"<?xml version=""1.0"" encoding=""UTF-8""?>
<score-partwise version=""3.1"">
  <part-list>
    <score-part id=""P1"">
      <part-name>Piano</part-name>
    </score-part>
  </part-list>
  <part id=""P1"">
    <measure number=""1"">
      <attributes>
        <divisions>480</divisions>
      </attributes>
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>480</duration>
        <type>quarter</type>
      </note>
      <backup>
        <!-- 没有duration子元素 -->
      </backup>
    </measure>
  </part>
</score-partwise>";

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.Single(measure.Notes); // 只有原始音符，backup没有duration不插入rest
        Assert.Equal('C', measure.Notes[0].Pitch.Step);
        Assert.False(measure.Notes[0].IsRest);
    }

    [Fact]
    public void Parse_BackupWithInvalidDuration_ShouldNotInsertRest()
    {
        // Arrange
        var xmlContent = @"<?xml version=""1.0"" encoding=""UTF-8""?>
<score-partwise version=""3.1"">
  <part-list>
    <score-part id=""P1"">
      <part-name>Piano</part-name>
    </score-part>
  </part-list>
  <part id=""P1"">
    <measure number=""1"">
      <attributes>
        <divisions>480</divisions>
      </attributes>
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>480</duration>
        <type>quarter</type>
      </note>
      <backup>
        <duration>invalid</duration>
      </backup>
    </measure>
  </part>
</score-partwise>";

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.Single(measure.Notes); // 只有原始音符，backup无效duration不插入rest
        Assert.Equal('C', measure.Notes[0].Pitch.Step);
        Assert.False(measure.Notes[0].IsRest);
    }

    [Fact]
    public void Parse_WithStem_ShouldParseStemDirectionCorrectly()
    {
        // Arrange
        var xmlContent = @"<?xml version=""1.0"" encoding=""UTF-8""?>
<score-partwise version=""3.1"">
  <part-list>
    <score-part id=""P1"">
      <part-name>Piano</part-name>
    </score-part>
  </part-list>
  <part id=""P1"">
    <measure number=""1"">
      <note>
        <pitch><step>C</step><octave>4</octave></pitch>
        <duration>1</duration>
        <type>quarter</type>
        <stem>up</stem>
      </note>
      <note>
        <pitch><step>D</step><octave>4</octave></pitch>
        <duration>1</duration>
        <type>quarter</type>
        <stem>down</stem>
      </note>
      <note>
        <pitch><step>E</step><octave>4</octave></pitch>
        <duration>1</duration>
        <type>quarter</type>
        <stem>none</stem>
      </note>
      <note>
        <pitch><step>F</step><octave>4</octave></pitch>
        <duration>1</duration>
        <type>quarter</type>
        <!-- 没有stem元素 -->
      </note>
    </measure>
  </part>
</score-partwise>";

        // Act
        var score = MusicXmlParser.GetScoreFromString(xmlContent);
        var notes = score.Parts[0].Measures[0].Notes;

        // Assert
        Assert.Equal(1, notes[0].Stem);   // up
        Assert.Equal(-1, notes[1].Stem);  // down
        Assert.Equal(0, notes[2].Stem);   // none
        Assert.Equal(0, notes[3].Stem);   // missing
    }

    private static string GetEmbeddedResource(string resourceName)
    {
        var assembly = Assembly.GetExecutingAssembly();
        var fullResourceName = $"MusicXMLParser.Tests.TestData.{resourceName}";

        using var stream = assembly.GetManifestResourceStream(fullResourceName);
        if (stream == null)
            throw new InvalidOperationException($"Resource {fullResourceName} not found");

        using var reader = new StreamReader(stream);
        return reader.ReadToEnd();
    }
} 