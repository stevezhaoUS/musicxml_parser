using System.IO;
using System.Reflection;
using BenchmarkDotNet.Attributes;
using MusicXMLParser;

namespace MusicXMLParser.Benchmarks
{
    [MemoryDiagnoser]
    public class ParserBenchmarks
    {
        private string _xmlContentSmall;
        private string _xmlContentMedium;
        private string _xmlContentLarge;

        private string ReadEmbeddedResource(string name)
        {
            var assembly = Assembly.GetExecutingAssembly();
            var resourceName = $"MusicXMLParser.Benchmarks.TestFiles.{name}";
            using var stream = assembly.GetManifestResourceStream(resourceName);
            if (stream == null)
                throw new FileNotFoundException($"Resource not found: {resourceName}");
            using var reader = new StreamReader(stream);
            return reader.ReadToEnd();
        }

        [GlobalSetup]
        public void Setup()
        {
            _xmlContentSmall = ReadEmbeddedResource("small.xml");
            _xmlContentMedium = ReadEmbeddedResource("medium.xml");
            _xmlContentLarge = ReadEmbeddedResource("large.xml");
        }

        [Benchmark]
        public void Parse_SmallFile()
        {
            var score = MusicXmlParser.GetScoreFromString(_xmlContentSmall);
        }

        [Benchmark]
        public void Parse_MediumFile()
        {
            var score = MusicXmlParser.GetScoreFromString(_xmlContentMedium);
        }

        [Benchmark]
        public void Parse_LargeFile()
        {
            var score = MusicXmlParser.GetScoreFromString(_xmlContentLarge);
        }
    }
} 