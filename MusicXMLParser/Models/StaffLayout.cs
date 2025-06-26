using System;

namespace MusicXMLParser.Models
{
    public class StaffLayout
    {
        /// <summary>
        /// Staff number this layout applies to (default 1 if not present in XML attribute).
        /// </summary>
        public int StaffNumber { get; }

        /// <summary>
        /// Distance from the previous staff.
        /// </summary>
        public double? StaffDistance { get; }

        public StaffLayout(int staffNumber, double? staffDistance = null)
        {
            StaffNumber = staffNumber;
            StaffDistance = staffDistance;
        }

        public override bool Equals(object? obj)
        {
            if (obj is StaffLayout other)
            {
                return StaffNumber == other.StaffNumber &&
                       StaffDistance == other.StaffDistance;
            }
            return false;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(StaffNumber, StaffDistance);
        }

        public override string ToString()
        {
            return $"StaffLayout{{StaffNumber: {StaffNumber}, StaffDistance: {StaffDistance?.ToString() ?? "null"}}}";
        }
    }
}
