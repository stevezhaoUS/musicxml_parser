using System;
using System.Collections.Generic;
using System.Linq;

namespace MusicXMLParser.Models
{
    public class PrintObject
    {
        public bool NewPage { get; set; }
        public bool NewSystem { get; set; }
        public int? BlankPage { get; set; }
        public string PageNumber { get; set; }
        public PageLayout LocalPageLayout { get; set; } // Assuming PageLayout class exists
        public SystemLayout LocalSystemLayout { get; set; } // Assuming SystemLayout class exists
        public List<StaffLayout> LocalStaffLayouts { get; set; } = new List<StaffLayout>(); // Assuming StaffLayout class exists
        public MeasureLayoutInfo MeasureLayout { get; set; } // Assuming MeasureLayoutInfo (or MeasureLayout) class exists
        public MeasureNumbering MeasureNumbering { get; set; } // Assuming MeasureNumbering class exists

        public PrintObject(
            bool newPage = false,
            bool newSystem = false,
            int? blankPage = null,
            string pageNumber = null,
            PageLayout localPageLayout = null,
            SystemLayout localSystemLayout = null,
            List<StaffLayout> localStaffLayouts = null,
            MeasureLayoutInfo measureLayout = null,
            MeasureNumbering measureNumbering = null)
        {
            NewPage = newPage;
            NewSystem = newSystem;
            BlankPage = blankPage;
            PageNumber = pageNumber;
            LocalPageLayout = localPageLayout;
            LocalSystemLayout = localSystemLayout;
            LocalStaffLayouts = localStaffLayouts ?? new List<StaffLayout>();
            MeasureLayout = measureLayout;
            MeasureNumbering = measureNumbering;
        }

        public override bool Equals(object obj)
        {
            if (obj is PrintObject other)
            {
                return NewPage == other.NewPage &&
                       NewSystem == other.NewSystem &&
                       BlankPage == other.BlankPage &&
                       PageNumber == other.PageNumber &&
                       object.Equals(LocalPageLayout, other.LocalPageLayout) &&
                       object.Equals(LocalSystemLayout, other.LocalSystemLayout) &&
                       LocalStaffLayouts.SequenceEqual(other.LocalStaffLayouts) &&
                       object.Equals(MeasureLayout, other.MeasureLayout) &&
                       object.Equals(MeasureNumbering, other.MeasureNumbering);
            }
            return false;
        }

        public override int GetHashCode()
        {
            var hashCode = new HashCode();
            hashCode.Add(NewPage);
            hashCode.Add(NewSystem);
            hashCode.Add(BlankPage);
            hashCode.Add(PageNumber);
            hashCode.Add(LocalPageLayout);
            hashCode.Add(LocalSystemLayout);
            // For lists, a common approach is to combine hash codes of elements or use a more sophisticated method if order matters.
            // Here's a simple way if order and content matter:
            if (LocalStaffLayouts != null)
            {
                foreach (var item in LocalStaffLayouts)
                {
                    hashCode.Add(item);
                }
            }
            hashCode.Add(MeasureLayout);
            hashCode.Add(MeasureNumbering);
            return hashCode.ToHashCode();
        }

        public override string ToString()
        {
            return $"PrintObject{{NewPage: {NewPage}, NewSystem: {NewSystem}, BlankPage: {BlankPage?.ToString() ?? "null"}, PageNumber: {PageNumber ?? "null"}, LocalPageLayout: {LocalPageLayout}, LocalSystemLayout: {LocalSystemLayout}, LocalStaffLayouts: [{string.Join(", ", LocalStaffLayouts)}], MeasureLayout: {MeasureLayout}, MeasureNumbering: {MeasureNumbering}}}";
        }
    }

    // Assuming MeasureNumbering is a simple class or enum.
    // If it's complex, it should be in its own file.
    // For now, let's assume it's part of MeasureLayoutInfo or a simple enum-like structure.
    // Example:
    // public enum MeasureNumberingValue { None, Measure, System }
    // public class MeasureNumbering
    // {
    //     public MeasureNumberingValue Value { get; set; }
    //     // Add other properties if needed from the Dart model
    // }
    // NOTE: The Dart model 'measure_layout_info.dart' defines MeasureNumbering.
    // It will be ported later. For now, this placeholder might be okay,
    // or PrintObject can temporarily use a more generic type if MeasureNumbering is complex.
}
