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
            _scalingParser = scalingParser ?? new ScalingParser(); // Assuming parameterless constructor
            _pageLayoutParser = pageLayoutParser ?? new PageLayoutParser(); // Assuming parameterless constructor
            _systemLayoutParser = systemLayoutParser ?? new SystemLayoutParser(); // Assuming parameterless constructor
            _staffLayoutParser = staffLayoutParser ?? new StaffLayoutParser(); // Assuming parameterless constructor
        }

        public Score Parse(XDocument document)
        {
            var scorePartwiseElement = document.Elements("score-partwise").FirstOrDefault();
            if (scorePartwiseElement != null)
            {
                return ParseScorePartwise(scorePartwiseElement);
            }

            var scoreTimewiseElement = document.Elements("score-timewise").FirstOrDefault();
            if (scoreTimewiseElement != null)
            {
                throw new MusicXmlStructureException(
                    message: "Score-timewise format is not fully implemented",
                    requiredElement: "score-partwise",
                    parentElement: "score-timewise",
                    line: XmlHelper.GetLineNumber(scoreTimewiseElement),
                    context: null
                );
            }

            throw new MusicXmlStructureException(
                message: "Document is not a valid MusicXML file. Root element must be either \"score-partwise\" or \"score-timewise\"",
                requiredElement: "score-partwise or score-timewise",
                parentElement: document.Root?.Name.LocalName, // Get root name if available
                line: XmlHelper.GetLineNumber(document.Root), // Pass root for line number
                context: null
            );
        }

        private Score ParseScorePartwise(XElement element)
        {
            var title = XmlHelper.FindOptionalTextElement(element, "work/work-title") ??
                        XmlHelper.FindOptionalTextElement(element, "movement-title");
            var composer = XmlHelper.FindOptionalTextElement(element, "identification/creator[@type='composer']");
            var arranger = XmlHelper.FindOptionalTextElement(element, "identification/creator[@type='arranger']");
            var lyricist = XmlHelper.FindOptionalTextElement(element, "identification/creator[@type='lyricist']");
            var rights = XmlHelper.FindOptionalTextElement(element, "identification/rights");
            var source = XmlHelper.FindOptionalTextElement(element, "identification/source");
            var version = element.Attribute("version")?.Value;

            var partListElement = element.Elements("part-list").FirstOrDefault();
            if (partListElement == null)
            {
                WarningSystem.AddWarning(
                    message: "Missing part-list element in score",
                    category: WarningCategories.Structure, // Corrected category
                    rule: "score_missing_part_list",
                    line: XmlHelper.GetLineNumber(element),
                    elementName: element.Name.LocalName,
                    context: new Dictionary<string, object>() // No specific context beyond line and element
                );
            }

            var parts = element.Elements("part")
                               .Select(partEl => _partParser.Parse(partEl, partListElement))
                               .ToList();

            var defaultsData = ParseDefaults(element.Element("defaults"));

            var scoreBuilder = new ScoreBuilder(version) // Removed line number argument
                .SetTitle(title) // Title can be set directly or via Work
                .SetComposer(composer); // Composer can be set directly or via Identification

            scoreBuilder.SetParts(parts);

            scoreBuilder.SetPageLayout(defaultsData.PageLayout)
                        .SetDefaultSystemLayout(defaultsData.SystemLayout)
                        .setDefaultStaffLayouts(defaultsData.StaffLayouts) // Corrected method name casing
                        .SetScaling(defaultsData.Scaling)
                        .SetAppearance(defaultsData.Appearance);

            if (!string.IsNullOrEmpty(title)) { // Ensure title is not null or empty before creating Work
                 scoreBuilder.SetWork(new Work(title));
            }

            if (!string.IsNullOrEmpty(composer) || !string.IsNullOrEmpty(arranger) || !string.IsNullOrEmpty(lyricist) || !string.IsNullOrEmpty(rights) || !string.IsNullOrEmpty(source))
            {
                scoreBuilder.SetIdentification(new Identification(
                    composer: composer,
                    arranger: arranger,
                    lyricist: lyricist,
                    rights: rights,
                    source: source
                ));
            }

            var parsedCredits = ParseCredits(element);
            if (parsedCredits.Any())
            {
                scoreBuilder.SetCredits(parsedCredits);
            }

            return scoreBuilder.Build();
        }

        private DefaultsData ParseDefaults(XElement defaultsElement)
        {
            if (defaultsElement == null)
            {
                return new DefaultsData();
            }

            Scaling scaling = null;
            var scalingElement = defaultsElement.Element("scaling");
            if (scalingElement != null)
            {
                scaling = _scalingParser.Parse(scalingElement);
            }

            PageLayout pageLayout = null;
            var pageLayoutElement = defaultsElement.Element("page-layout");
            if (pageLayoutElement != null)
            {
                pageLayout = _pageLayoutParser.Parse(pageLayoutElement);
            }

            SystemLayout systemLayout = null;
            var systemLayoutElement = defaultsElement.Element("system-layout");
            if (systemLayoutElement != null)
            {
                systemLayout = _systemLayoutParser.Parse(systemLayoutElement);
            }

            var staffLayouts = defaultsElement.Elements("staff-layout")
                                             .Select(el => _staffLayoutParser.Parse(el))
                                             .ToList();

            var appearance = ParseAppearance(defaultsElement);

            return new DefaultsData(
                scaling: scaling,
                pageLayout: pageLayout,
                systemLayout: systemLayout,
                staffLayouts: staffLayouts,
                appearance: appearance
            );
        }

        private List<Credit> ParseCredits(XElement scoreElement)
        {
            var parsedCredits = new List<Credit>();
            foreach (var creditElement in scoreElement.Elements("credit"))
            {
                string pageStr = creditElement.Attribute("page")?.Value;
                int? page = !string.IsNullOrEmpty(pageStr) && int.TryParse(pageStr, out int pVal) ? pVal : (int?)null;

                var creditTypeElement = creditElement.Elements("credit-type").FirstOrDefault();
                string creditType = creditTypeElement?.Value.Trim();

                var creditWordsList = new List<string>();
                foreach (var wordsElement in creditElement.Elements("credit-words"))
                {
                    var text = wordsElement.Value.Trim();
                    if (!string.IsNullOrEmpty(text))
                    {
                        creditWordsList.Add(text);
                    }
                }

                if ((!string.IsNullOrEmpty(creditType)) || creditWordsList.Any())
                {
                    parsedCredits.Add(new Credit(page, creditType, creditWordsList));
                }
                else if (page.HasValue) // Credit can exist with only a page number
                {
                     parsedCredits.Add(new Credit(page, creditType, creditWordsList));
                }
            }
            return parsedCredits;
        }

        private Appearance ParseAppearance(XElement defaultsElement)
        {
            if (defaultsElement == null) return null;
            var appearanceElement = defaultsElement.Element("appearance");
            if (appearanceElement == null) return null;

            var lineWidths = new List<LineWidth>();
            var noteSizes = new List<NoteSize>();

            foreach (var lineWidthElement in appearanceElement.Elements("line-width"))
            {
                var type = lineWidthElement.Attribute("type")?.Value;
                if (string.IsNullOrEmpty(type)) continue;

                if (double.TryParse(lineWidthElement.Value, out double width))
                {
                    lineWidths.Add(new LineWidth(type, width));
                }
            }

            foreach (var noteSizeElement in appearanceElement.Elements("note-size"))
            {
                var type = noteSizeElement.Attribute("type")?.Value;
                if (string.IsNullOrEmpty(type)) continue;

                if (double.TryParse(noteSizeElement.Value, out double size))
                {
                    noteSizes.Add(new NoteSize(type, size));
                }
            }

            // Only return Appearance if there's something in it
            if (lineWidths.Any() || noteSizes.Any())
            {
                 return new Appearance(lineWidths, noteSizes);
            }
            return null;
        }


        // Helper class, similar to _DefaultsData in Dart
        private class DefaultsData
        {
            public Scaling Scaling { get; }
            public PageLayout PageLayout { get; }
            public SystemLayout SystemLayout { get; }
            public List<StaffLayout> StaffLayouts { get; }
            public Appearance Appearance { get; }

            public DefaultsData(Scaling scaling = null, PageLayout pageLayout = null, SystemLayout systemLayout = null, List<StaffLayout> staffLayouts = null, Appearance appearance = null)
            {
                Scaling = scaling;
                PageLayout = pageLayout;
                SystemLayout = systemLayout;
                StaffLayouts = staffLayouts ?? new List<StaffLayout>();
                Appearance = appearance;
            }
        }
    }
}
