using System.Reflection;
using MusicXMLParser.Models;

namespace MusicXMLParser.Tests;

public class BasicTests
{
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
        Assert.Equal("1", score.Parts[0].Measures[0].Number);
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
        Assert.NotNull(measure.Attributes?.Clef);
        Assert.Equal("G", measure.Attributes.Clef.Sign);
        Assert.Equal(2, measure.Attributes.Clef.Line);
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
        var invalidXml = "<invalid>xml</invalid>";

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