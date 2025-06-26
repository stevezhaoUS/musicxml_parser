using BenchmarkDotNet.Running;

namespace MusicXMLParser.Benchmarks
{
    public class Program
    {
        public static void Main(string[] args)
        {
            BenchmarkRunner.Run<ParserBenchmarks>();
        }
    }
}
