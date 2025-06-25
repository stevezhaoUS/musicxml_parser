using System;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using System.Threading.Tasks;
using MusicXMLParser.Models;
using MusicXMLParser.Exceptions;
using MusicXMLParser.Utils; // For WarningSystem

namespace MusicXMLParser.Parser
{
    /// <summary>
    /// The main parser class for MusicXML files.
    /// This class serves as the entry point for parsing MusicXML content.
    /// It delegates the actual parsing to specialized parser components.
    /// </summary>
    public class MusicXmlParser
    {
        private readonly ScoreParser _scoreParser;
        public WarningSystem WarningSystem { get; }

        public MusicXmlParser(ScoreParser? scoreParser = null, WarningSystem? warningSystem = null)
        {
            WarningSystem = warningSystem ?? new WarningSystem();
            _scoreParser = scoreParser ?? new ScoreParser(warningSystem: WarningSystem); // Pass warningSystem
        }

        /// <summary>
        /// Parses a MusicXML string into a <see cref="Score"/> object.
        /// </summary>
        /// <exception cref="MusicXmlParseException">For XML parsing issues.</exception>
        /// <exception cref="MusicXmlStructureException">For structural problems.</exception>
        /// <exception cref="MusicXmlValidationException">For validation issues.</exception>
        public Score Parse(string xmlString)
        {
            try
            {
                var document = XDocument.Parse(xmlString, LoadOptions.SetLineInfo);
                return _scoreParser.Parse(document);
            }
            catch (System.Xml.XmlException e)
            {
                throw new MusicXmlParseException($"XML parsing error: {e.Message}", e);
            }
            catch (MusicXmlParseException) { throw; }
            catch (MusicXmlStructureException) { throw; }
            catch (MusicXmlValidationException) { throw; }
            catch (Exception e)
            {
                throw new MusicXmlParseException($"Failed to parse MusicXML: {e.Message}", e);
            }
        }

        /// <summary>
        /// Parses a MusicXML file into a <see cref="Score"/> object.
        /// This method handles both plain XML files (.xml, .musicxml) and compressed MXL files (.mxl).
        /// </summary>
        /// <exception cref="MusicXmlParseException">For XML parsing or file access issues.</exception>
        /// <exception cref="MusicXmlStructureException">For structural problems.</exception>
        /// <exception cref="MusicXmlValidationException">For validation issues.</exception>
        public async Task<Score> ParseFileAsync(string filePath) // Renamed from parseFromFile to match C# async conventions
        {
            try
            {
                byte[] data = await File.ReadAllBytesAsync(filePath);
                return ParseData(data);
            }
            catch (Exception e) when (e is not MusicXmlParseException && e is not MusicXmlStructureException && e is not MusicXmlValidationException)
            {
                throw new MusicXmlParseException($"Failed to read or parse file {filePath}: {e.Message}", e);
            }
        }

        /// <summary>
        /// Synchronous version of <see cref="ParseFileAsync(string)"/>.
        /// Parses a MusicXML file into a <see cref="Score"/> object.
        /// This method handles both plain XML files (.xml, .musicxml) and compressed MXL files (.mxl).
        /// </summary>
        public Score ParseFileSync(string filePath)
        {
            try
            {
                byte[] data = File.ReadAllBytes(filePath);
                return ParseData(data);
            }
            catch (Exception e) when (e is not MusicXmlParseException && e is not MusicXmlStructureException && e is not MusicXmlValidationException)
            {
                throw new MusicXmlParseException($"Failed to read or parse file {filePath}: {e.Message}", e);
            }
        }


        /// <summary>
        /// Parses MusicXML data (byte array) into a <see cref="Score"/> object.
        /// Automatically detects if the input is plain XML or compressed MXL.
        /// </summary>
        public Score ParseData(byte[] data)
        {
            try
            {
                if (IsCompressedMxl(data))
                {
                    string xmlString = ExtractMusicXmlFromMxl(data);
                    return Parse(xmlString);
                }
                else
                {
                    string xmlString = System.Text.Encoding.UTF8.GetString(data); // Explicitly qualified
                    return Parse(xmlString);
                }
            }
            catch (Exception e) when (e is not MusicXmlParseException && e is not MusicXmlStructureException && e is not MusicXmlValidationException)
            {
                throw new MusicXmlParseException($"Failed to parse MusicXML data: {e.Message}", e);
            }
        }

        /// <summary>
        /// Parses ByteData (typically from Flutter assets or network) containing MXL data into a <see cref="Score"/> object.
        /// </summary>
        /// <param name="data">The ByteData containing the MXL file content.</param>
        /// <returns>A parsed <see cref="Score"/> object.</returns>
        /// <exception cref="MusicXmlParseException">If the data is not a valid MXL or parsing fails.</exception>
        public Score ParseMxlBytes(byte[] data) // Changed from ByteData for broader C# use
        {
            try
            {
                if (!IsCompressedMxl(data))
                {
                    throw new MusicXmlParseException("Input data is not a valid MXL (ZIP) file.");
                }
                string xmlString = ExtractMusicXmlFromMxl(data);
                return Parse(xmlString);
            }
            catch (Exception e) when (e is not MusicXmlParseException && e is not MusicXmlStructureException && e is not MusicXmlValidationException)
            {
                throw new MusicXmlParseException($"Failed to parse MXL byte data: {e.Message}", e);
            }
        }


        private bool IsCompressedMxl(byte[] data)
        {
            if (data.Length < 4) return false;
            // ZIP files start with PK\x03\x04 (0x50 0x4B 0x03 0x04)
            return data[0] == 0x50 && data[1] == 0x4B && data[2] == 0x03 && data[3] == 0x04;
        }

        private string ExtractMusicXmlFromMxl(byte[] data)
        {
            try
            {
                using (var memoryStream = new MemoryStream(data))
                using (var archive = new ZipArchive(memoryStream, ZipArchiveMode.Read))
                {
                    // Try to find META-INF/container.xml
                    var containerEntry = archive.GetEntry("META-INF/container.xml");
                    if (containerEntry != null)
                    {
                        using (var stream = containerEntry.Open())
                        using (var reader = new StreamReader(stream, System.Text.Encoding.UTF8)) // Explicitly qualified
                        {
                            var containerContent = reader.ReadToEnd();
                            var containerDoc = XDocument.Parse(containerContent);
                            var rootfileElement = containerDoc.Descendants("rootfile").FirstOrDefault();
                            if (rootfileElement != null)
                            {
                                var fullPath = rootfileElement.Attribute("full-path")?.Value;
                                if (!string.IsNullOrEmpty(fullPath))
                                {
                                    var mainEntry = archive.GetEntry(fullPath);
                                    if (mainEntry != null)
                                    {
                                        using (var mainStream = mainEntry.Open())
                                        using (var mainReader = new StreamReader(mainStream, System.Text.Encoding.UTF8)) // Explicitly qualified
                                        {
                                            return mainReader.ReadToEnd();
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // If no container.xml or specified file not found, look for any .xml or .musicxml file
                    var xmlFile = archive.Entries
                        .FirstOrDefault(e => !e.FullName.Contains("/") && (e.FullName.EndsWith(".xml", StringComparison.OrdinalIgnoreCase) || e.FullName.EndsWith(".musicxml", StringComparison.OrdinalIgnoreCase)));

                    if (xmlFile == null) // If not in root, try any
                    {
                         xmlFile = archive.Entries
                            .FirstOrDefault(e => e.FullName.EndsWith(".xml", StringComparison.OrdinalIgnoreCase) || e.FullName.EndsWith(".musicxml", StringComparison.OrdinalIgnoreCase));
                    }

                    if (xmlFile != null)
                    {
                        using (var stream = xmlFile.Open())
                        using (var reader = new StreamReader(stream, System.Text.Encoding.UTF8)) // Explicitly qualified
                        {
                            return reader.ReadToEnd();
                        }
                    }

                    throw new MusicXmlParseException("No valid MusicXML content found in the compressed MXL file.");
                }
            }
            catch (Exception e) when (e is not MusicXmlParseException)
            {
                throw new MusicXmlParseException($"Failed to extract MusicXML from compressed MXL file: {e.Message}", e);
            }
        }
    }
}
