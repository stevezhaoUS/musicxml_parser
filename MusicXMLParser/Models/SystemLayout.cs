using System;

namespace MusicXMLParser.Models
{
    public class SystemMargins
    {
        public double? LeftMargin { get; set; }
        public double? RightMargin { get; set; }

        public SystemMargins(double? leftMargin = null, double? rightMargin = null)
        {
            LeftMargin = leftMargin;
            RightMargin = rightMargin;
        }

        public override bool Equals(object obj)
        {
            if (obj is SystemMargins other)
            {
                return LeftMargin == other.LeftMargin &&
                       RightMargin == other.RightMargin;
            }
            return false;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(LeftMargin, RightMargin);
        }

        public override string ToString()
        {
            return $"SystemMargins{{LeftMargin: {LeftMargin?.ToString() ?? "null"}, RightMargin: {RightMargin?.ToString() ?? "null"}}}";
        }
    }

    public class SystemDividers
    {
        public bool LeftDivider { get; set; }
        public bool RightDivider { get; set; }

        public SystemDividers(bool leftDivider = false, bool rightDivider = false)
        {
            LeftDivider = leftDivider;
            RightDivider = rightDivider;
        }

        public override bool Equals(object obj)
        {
            if (obj is SystemDividers other)
            {
                return LeftDivider == other.LeftDivider &&
                       RightDivider == other.RightDivider;
            }
            return false;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(LeftDivider, RightDivider);
        }

        public override string ToString()
        {
            return $"SystemDividers{{LeftDivider: {LeftDivider}, RightDivider: {RightDivider}}}";
        }
    }

    public class SystemLayout
    {
        public SystemMargins SystemMargins { get; set; }
        public double? SystemDistance { get; set; }
        public double? TopSystemDistance { get; set; }
        public SystemDividers SystemDividers { get; set; }

        public SystemLayout(
            SystemMargins systemMargins = null,
            double? systemDistance = null,
            double? topSystemDistance = null,
            SystemDividers systemDividers = null)
        {
            SystemMargins = systemMargins;
            SystemDistance = systemDistance;
            TopSystemDistance = topSystemDistance;
            SystemDividers = systemDividers;
        }

        public override bool Equals(object obj)
        {
            if (obj is SystemLayout other)
            {
                return object.Equals(SystemMargins, other.SystemMargins) &&
                       SystemDistance == other.SystemDistance &&
                       TopSystemDistance == other.TopSystemDistance &&
                       object.Equals(SystemDividers, other.SystemDividers);
            }
            return false;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(SystemMargins, SystemDistance, TopSystemDistance, SystemDividers);
        }

        public override string ToString()
        {
            return $"SystemLayout{{SystemMargins: {SystemMargins}, SystemDistance: {SystemDistance?.ToString() ?? "null"}, TopSystemDistance: {TopSystemDistance?.ToString() ?? "null"}, SystemDividers: {SystemDividers}}}";
        }
    }
}
