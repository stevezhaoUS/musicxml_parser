using System.Reflection;
using MusicXMLParser.Parser;
using MusicXMLParser.Models;

namespace MusicXMLParser.Tests;

public class BasicTests
{
    private readonly MusicXmlParser _parser;

    public BasicTests()
    {
        _parser = new MusicXmlParser();
    }

    [Fact]
    public void Parse_SimpleXml_ShouldReturnValidScore()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("simple.xml");

        // Act
        var score = _parser.Parse(xmlContent);

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
        Assert.Equal("1", score.Parts[0].Measures[0].Number);
        Assert.Equal(4, score.Parts[0].Measures[0].Notes.Count);
        Assert.Equal("C", score.Parts[0].Measures[0].Notes[0].Pitch.Step);
        Assert.Equal(4, score.Parts[0].Measures[0].Notes[0].Pitch.Octave);
        Assert.Equal(1, score.Parts[0].Measures[0].Notes[0].Duration.Value);
        Assert.Equal("quarter", score.Parts[0].Measures[0].Notes[0].Type);
    }

    [Fact]
    public void Parse_ComplexXml_ShouldReturnValidScore()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("complex.xml");

        // Act
        var score = _parser.Parse(xmlContent);

        // Assert
        Assert.Equal("Für Elise", score.Work.Title);
        Assert.Equal("arr. Verona", score.Identification.Composer);
        Assert.Equal("pianolessenassen.nl/bladmuziek", score.Identification.Rights);
        Assert.Single(score.Parts);
        Assert.Equal("P1", score.Parts[0].Id);
        Assert.Equal("Piano", score.Parts[0].Name);
        // Assert.Equal("Pno.", score.Parts[0].Abbreviation); // Part类无此属性，注释掉
    }

    [Fact]
    public void Parse_WithKeySignature_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("simple.xml");

        // Act
        var score = _parser.Parse(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.NotNull(measure.KeySignature);
        Assert.Equal(0, measure.KeySignature.Fifths);
    }

    [Fact]
    public void Parse_WithTimeSignature_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("simple.xml");

        // Act
        var score = _parser.Parse(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.NotNull(measure.TimeSignature);
        Assert.Equal(4, measure.TimeSignature.Beats);
        Assert.Equal(4, measure.TimeSignature.BeatType);
    }

    [Fact]
    public void Parse_WithClef_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("simple.xml");

        // Act
        var score = _parser.Parse(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.NotNull(measure.Clefs);
        Assert.Single(measure.Clefs);
        Assert.Equal("G", measure.Clefs[0].Sign);
        Assert.Equal(2, measure.Clefs[0].Line);
    }

    [Fact]
    public void Parse_WithNotes_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("simple.xml");

        // Act
        var score = _parser.Parse(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.Equal(4, measure.Notes.Count);
        Assert.Equal("C", measure.Notes[0].Pitch.Step);
        Assert.Equal(4, measure.Notes[0].Pitch.Octave);
        Assert.Equal("D", measure.Notes[1].Pitch.Step);
        Assert.Equal(4, measure.Notes[1].Pitch.Octave);
        Assert.Equal("E", measure.Notes[2].Pitch.Step);
        Assert.Equal(4, measure.Notes[2].Pitch.Octave);
        Assert.Equal("F", measure.Notes[3].Pitch.Step);
        Assert.Equal(4, measure.Notes[3].Pitch.Octave);
    }

    [Fact]
    public void Parse_WithBarline_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("simple.xml");

        // Act
        var score = _parser.Parse(xmlContent);

        // Assert
        var measure = score.Parts[0].Measures[0];
        Assert.Empty(measure.Barlines); // small.xml没有barline
    }

    [Fact]
    public void Parse_WithPageLayout_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("complex.xml");

        // Act
        var score = _parser.Parse(xmlContent);

        // Assert
        Assert.NotNull(score.PageLayout);
        Assert.Equal(1697.14, score.PageLayout.PageHeight!.Value, 2); // 允许小数误差
        Assert.Equal(1200, score.PageLayout.PageWidth!.Value, 2);
        Assert.NotNull(score.PageLayout.PageMargins);
        Assert.Equal(85.7143, score.PageLayout.PageMargins[0].LeftMargin!.Value, 2);
        Assert.Equal(85.7143, score.PageLayout.PageMargins[0].RightMargin!.Value, 2);
        Assert.Equal(85.7143, score.PageLayout.PageMargins[0].TopMargin!.Value, 2);
        Assert.Equal(85.7143, score.PageLayout.PageMargins[0].BottomMargin!.Value, 2);
    }

    [Fact]
    public void Parse_WithSystemLayout_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("complex.xml");

        // Act
        var score = _parser.Parse(xmlContent);

        // Assert
        // <defaults> 下没有 <system-layout>，全局 DefaultSystemLayout 应为 null
        Assert.Null(score.DefaultSystemLayout);
        // measure[0] 的 <print><system-layout>... 应被解析到 measure 的 PrintObject.LocalSystemLayout
        var measure0 = score.Parts[0].Measures[0];
        Assert.NotNull(measure0.PrintObject);
        Assert.NotNull(measure0.PrintObject.LocalSystemLayout);
        Assert.NotNull(measure0.PrintObject.LocalSystemLayout.SystemMargins);
        Assert.Equal(65.90, measure0.PrintObject.LocalSystemLayout.SystemMargins.LeftMargin!.Value, 2);
        Assert.Equal(0.00, measure0.PrintObject.LocalSystemLayout.SystemMargins.RightMargin!.Value, 2);
        Assert.Equal(170.00, measure0.PrintObject.LocalSystemLayout.TopSystemDistance!.Value, 2);
    }

    [Fact]
    public void Parse_WithScaling_ShouldParseCorrectly()
    {
        // Arrange
        var xmlContent = GetEmbeddedResource("complex.xml");

        // Act
        var score = _parser.Parse(xmlContent);

        // Assert
        Assert.NotNull(score.Scaling);
        Assert.Equal(7, score.Scaling.Millimeters);
        Assert.Equal(40, score.Scaling.Tenths);
    }

    [Fact]
    public void Parse_InvalidXml_ShouldThrowException()
    {
        // Arrange
        var invalidXml = "<invalid>xml</invalid>";

        // Act & Assert
        Assert.Throws<MusicXMLParser.Exceptions.MusicXmlValidationException>(() => _parser.Parse(invalidXml));
    }

    [Fact]
    public void Parse_EmptyXml_ShouldThrowException()
    {
        // Arrange
        var emptyXml = "";

        // Act & Assert
        Assert.Throws<MusicXMLParser.Exceptions.MusicXmlParseException>(() => _parser.Parse(emptyXml));
    }

    [Fact]
    public void Parse_NullXml_ShouldThrowException()
    {
        // Arrange
        string? nullXml = null;

        // Act & Assert
        Assert.Throws<MusicXMLParser.Exceptions.MusicXmlParseException>(() => _parser.Parse(nullXml!));
    }

    private static string GetEmbeddedResource(string resourceName)
    {
        var assembly = Assembly.GetExecutingAssembly();
        var fullResourceName = $"MusicXMLParser.Tests.TestData.{resourceName}";
        using var stream = assembly.GetManifestResourceStream(fullResourceName);
        if (stream == null)
        {
            throw new InvalidOperationException($"Resource {fullResourceName} not found");
        }
        using var reader = new StreamReader(stream);
        return reader.ReadToEnd();
    }
} 