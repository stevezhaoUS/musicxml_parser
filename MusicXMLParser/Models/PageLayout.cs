using System.Collections.Generic;
using System.Linq;

namespace MusicXMLParser.Models
{
    public class PageMargins
    {
        public string Type { get; set; } // "odd", "even", "both"
        public double? LeftMargin { get; set; }
        public double? RightMargin { get; set; }
        public double? TopMargin { get; set; }
        public double? BottomMargin { get; set; }

        public override bool Equals(object obj)
        {
            if (obj is PageMargins other)
            {
                return Type == other.Type &&
                       LeftMargin == other.LeftMargin &&
                       RightMargin == other.RightMargin &&
                       TopMargin == other.TopMargin &&
                       BottomMargin == other.BottomMargin;
            }
            return false;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Type, LeftMargin, RightMargin, TopMargin, BottomMargin);
        }

        public override string ToString()
        {
            return $"PageMargins{{Type: {Type}, LeftMargin: {LeftMargin}, RightMargin: {RightMargin}, TopMargin: {TopMargin}, BottomMargin: {BottomMargin}}}";
        }
    }

    public class PageLayout
    {
        public double? PageHeight { get; set; }
        public double? PageWidth { get; set; }
        public List<PageMargins> PageMargins { get; set; } = new List<PageMargins>(); // Can have up to 2 (odd/even) or one for "both"

        public override bool Equals(object obj)
        {
            if (obj is PageLayout other)
            {
                return PageHeight == other.PageHeight &&
                       PageWidth == other.PageWidth &&
                       PageMargins.SequenceEqual(other.PageMargins);
            }
            return false;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(PageHeight, PageWidth, PageMargins);
        }

        public override string ToString()
        {
            return $"PageLayout{{PageHeight: {PageHeight}, PageWidth: {PageWidth}, PageMargins: {string.Join(", ", PageMargins)}}}";
        }
    }

    /// <summary>
    /// Represents scaling information in a MusicXML document.
    /// Typically found within <defaults>.
    /// </summary>
    public class Scaling
    {
        /// <summary>
        /// The number of millimeters per unit.
        /// </summary>
        public double Millimeters { get; set; }

        /// <summary>
        /// The number of tenths per unit.
        /// </summary>
        public double Tenths { get; set; }

        public Scaling(double millimeters, double tenths)
        {
            Millimeters = millimeters;
            Tenths = tenths;
        }

        public override bool Equals(object obj)
        {
            if (obj is Scaling other)
            {
                return Millimeters == other.Millimeters &&
                       Tenths == other.Tenths;
            }
            return false;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Millimeters, Tenths);
        }

        public override string ToString()
        {
            return $"Scaling{{Millimeters: {Millimeters}, Tenths: {Tenths}}}";
        }
    }
}
