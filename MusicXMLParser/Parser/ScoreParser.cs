using System.Xml.Linq;
using MusicXMLParser.Models;
using MusicXMLParser.Exceptions;
using MusicXMLParser.Utils;
using System.Linq;
using System.Collections.Generic;

namespace MusicXMLParser.Parser
{
    public class ScoreParser
    {
        private readonly PartParser _partParser;
        private readonly ScalingParser _scalingParser;
        private readonly PageLayoutParser _pageLayoutParser;
        private readonly SystemLayoutParser _systemLayoutParser;
        private readonly StaffLayoutParser _staffLayoutParser; // Assuming this parser exists
        public WarningSystem WarningSystem { get; }

        // 缓存常用的上下文字典以减少内存分配
        private readonly Dictionary<string, object> _sharedContext = new();

        public ScoreParser(
            PartParser? partParser = null,
            ScalingParser? scalingParser = null,
            PageLayoutParser? pageLayoutParser = null,
            SystemLayoutParser? systemLayoutParser = null,
            StaffLayoutParser? staffLayoutParser = null,
            WarningSystem? warningSystem = null)
        {
            WarningSystem = warningSystem ?? new WarningSystem();
            _partParser = partParser ?? new PartParser(warningSystem: WarningSystem);
            _scalingParser = scalingParser ?? new ScalingParser();
            _pageLayoutParser = pageLayoutParser ?? new PageLayoutParser();
            _systemLayoutParser = systemLayoutParser ?? new SystemLayoutParser();
            _staffLayoutParser = staffLayoutParser ?? new StaffLayoutParser();
        }

        public Score Parse(XElement element)
        {
            var line = XmlHelper.GetLineNumber(element);
            var version = XmlHelper.GetAttributeValue(element, "version");

            if (string.IsNullOrEmpty(version))
            {
                throw new MusicXmlValidationException(
                    message: "Score element is missing required 'version' attribute",
                    line: line,
                    context: CreateContext()
                );
            }

            return ParseScorePartwise(element);
        }

        private Score ParseScorePartwise(XElement element)
        {
            var line = XmlHelper.GetLineNumber(element);
            var version = XmlHelper.GetAttributeValue(element, "version");

            var scoreBuilder = new ScoreBuilder(version ?? "3.0");

            // 使用优化的方法获取元素
            var workElement = element.Element("work");
            if (workElement != null)
            {
                scoreBuilder.SetWork(ParseWork(workElement));
            }

            var identificationElement = element.Element("identification");
            if (identificationElement != null)
            {
                scoreBuilder.SetIdentification(ParseIdentification(identificationElement));
            }

            var defaultElement = element.Element("defaults");
            if (defaultElement != null)
            {
                ParseDefaults(defaultElement, scoreBuilder);
            }

            // 处理所有<credit>元素，优先设置Title
            var creditElements = element.Elements("credit").ToList();
            bool titleSet = false;
            foreach (var creditElement in creditElements)
            {
                var creditType = XmlHelper.GetElementText(creditElement, "credit-type");
                if (!titleSet && creditType == "title")
                {
                    // 合并所有credit-words内容
                    var titleText = string.Join(" ", creditElement.Elements("credit-words").Select(e => e.Value.Trim()).Where(s => !string.IsNullOrEmpty(s)));
                    if (!string.IsNullOrEmpty(titleText))
                    {
                        scoreBuilder.SetTitle(titleText);
                        titleSet = true;
                    }
                }
                scoreBuilder.AddCredit(ParseCredit(creditElement));
            }

            var partListElement = element.Element("part-list");
            if (partListElement == null)
            {
                throw new MusicXmlStructureException(
                    message: "Score element is missing required <part-list> child",
                    requiredElement: "part-list",
                    parentElement: "score",
                    line: line,
                    context: CreateContext()
                );
            }

            // 调试输出 part-list 下的元素数量
            Console.WriteLine($"[ScoreParser] part-list children count: {partListElement.Elements().Count()}");

            var parts = ParsePartList(partListElement);
            scoreBuilder.SetParts(parts);

            return scoreBuilder.Build();
        }

        // 优化的上下文创建方法，减少内存分配
        private Dictionary<string, object> CreateContext(string? additionalKey = null, object? additionalValue = null)
        {
            _sharedContext.Clear();
            
            if (additionalKey != null && additionalValue != null)
            {
                _sharedContext[additionalKey] = additionalValue;
            }
            
            return new Dictionary<string, object>(_sharedContext);
        }

        private Work ParseWork(XElement workElement)
        {
            // 使用优化的方法获取元素文本
            var workTitle = XmlHelper.GetElementText(workElement, "work-title");

            return new Work(workTitle);
        }

        private Identification ParseIdentification(XElement identificationElement)
        {
            var creator = XmlHelper.GetElementText(identificationElement, "creator");
            var rights = XmlHelper.GetElementText(identificationElement, "rights");
            var source = XmlHelper.GetElementText(identificationElement, "source");
            var encoding = ParseEncoding(identificationElement.Element("encoding"));

            return new Identification(creator, null, null, rights, source, encoding);
        }

        private Encoding? ParseEncoding(XElement? encodingElement)
        {
            if (encodingElement == null) return null;

            var software = XmlHelper.GetElementText(encodingElement, "software");
            var encodingDate = XmlHelper.GetElementText(encodingElement, "encoding-date");
            var supports = XmlHelper.GetElementText(encodingElement, "supports");

            return new Encoding(software, encodingDate, supports);
        }

        private void ParseDefaults(XElement defaultsElement, ScoreBuilder scoreBuilder)
        {
            // 使用优化的方法获取元素
            var scalingElement = defaultsElement.Element("scaling");
            if (scalingElement != null)
            {
                scoreBuilder.SetScaling(_scalingParser.Parse(scalingElement));
            }

            var pageLayoutElement = defaultsElement.Element("page-layout");
            if (pageLayoutElement != null)
            {
                scoreBuilder.SetPageLayout(_pageLayoutParser.Parse(pageLayoutElement));
            }

            var systemLayoutElement = defaultsElement.Element("system-layout");
            if (systemLayoutElement != null)
            {
                scoreBuilder.SetDefaultSystemLayout(_systemLayoutParser.Parse(systemLayoutElement));
            }

            var staffLayouts = new List<StaffLayout>();
            foreach (var staffLayoutElement in defaultsElement.Elements("staff-layout"))
            {
                staffLayouts.Add(_staffLayoutParser.Parse(staffLayoutElement));
            }
            if (staffLayouts.Count > 0)
            {
                scoreBuilder.setDefaultStaffLayouts(staffLayouts);
            }

            var appearanceElement = defaultsElement.Element("appearance");
            if (appearanceElement != null)
            {
                scoreBuilder.SetAppearance(ParseAppearance(appearanceElement));
            }
        }

        private Credit ParseCredit(XElement creditElement)
        {
            var page = XmlHelper.GetAttributeValueAsInt(creditElement, "page");
            var creditType = XmlHelper.GetElementText(creditElement, "credit-type");
            var creditWords = new List<string>();
            
            foreach (var wordsElement in creditElement.Elements("credit-words"))
            {
                var text = wordsElement.Value.Trim();
                if (!string.IsNullOrEmpty(text))
                {
                    creditWords.Add(text);
                }
            }

            return new Credit(page, creditType, creditWords);
        }

        private List<Part> ParsePartList(XElement partListElement)
        {
            var parts = new List<Part>();

            // 获取整个文档的 <part> 节点集合
            var doc = partListElement.Document;
            var partNodes = doc?.Descendants("part").ToList();

            foreach (var child in partListElement.Elements())
            {
                switch (child.Name.LocalName)
                {
                    case "score-part":
                        var partId = child.Attribute("id")?.Value;
                        var partNode = partNodes?.FirstOrDefault(p => p.Attribute("id")?.Value == partId);
                        if (partNode != null)
                        {
                            // 调试输出
                            Console.WriteLine($"[ScoreParser] <part id={partId}> measure count: {partNode.Elements("measure").Count()}");
                            var part = _partParser.Parse(partNode, partListElement);
                            if (part != null)
                            {
                                parts.Add(part);
                            }
                        }
                        else
                        {
                            Console.WriteLine($"[ScoreParser] <part id={partId}> not found in document");
                        }
                        break;
                    case "part-group":
                        // 处理part-group逻辑
                        WarningSystem.AddWarning(
                            message: "Part-group elements are not yet fully supported",
                            category: WarningCategories.Generic,
                            rule: "part_group_not_supported",
                            line: XmlHelper.GetLineNumber(child),
                            elementName: "part-group",
                            context: CreateContext()
                        );
                        break;
                }
            }

            return parts;
        }

        private Appearance ParseAppearance(XElement appearanceElement)
        {
            var lineWidths = new List<LineWidth>();
            var noteSizes = new List<NoteSize>();

            foreach (var child in appearanceElement.Elements())
            {
                switch (child.Name.LocalName)
                {
                    case "line-width":
                        lineWidths.Add(ParseLineWidth(child));
                        break;
                    case "note-size":
                        noteSizes.Add(ParseNoteSize(child));
                        break;
                }
            }

            return new Appearance(lineWidths, noteSizes);
        }

        private LineWidth ParseLineWidth(XElement element)
        {
            var type = XmlHelper.GetAttributeValue(element, "type");
            var width = XmlHelper.GetElementTextAsDouble(element) ?? 0.0;

            return new LineWidth(type, width);
        }

        private NoteSize ParseNoteSize(XElement element)
        {
            var type = XmlHelper.GetAttributeValue(element, "type");
            var size = XmlHelper.GetElementTextAsDouble(element) ?? 0.0;

            return new NoteSize(type, size);
        }
    }
}
