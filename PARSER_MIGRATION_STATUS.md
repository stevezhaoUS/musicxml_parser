# Parser Migration Status: Dart to C#

This document summarizes the migration status of MusicXML parser files and their primary public parsing functions from the Dart implementation to the C# implementation.

**Note on "Primary Public Parsing Methods" Estimation:**
The count of methods is an estimation focusing on the main public functions in each parser class that are responsible for parsing a significant MusicXML element or structure and typically return a model object or a collection of models. It generally excludes private helpers, simple getters/setters, or non-parsing utility functions within these classes.

## Detailed Parser Status

| Dart File (`lib/src/parser/`) | Dart Class(es) (Est. Methods) | C# File (`csharp/MusicXMLParser/Parser/`) | C# Class(es) (Est. Methods) | Migration Status                                       |
|-------------------------------|---------------------------------|-------------------------------------------|-------------------------------|--------------------------------------------------------|
| `attributes_parser.dart`      | `AttributesParser` (1)          | N/A                                       | N/A (0)                       | Not Started                                            |
| `beam_parser.dart`            | `BeamParser` (2)                | N/A                                       | N/A (0)                       | Not Started                                            |
| `measure_parser.dart`         | `MeasureParser` (1)             | N/A                                       | N/A (0)                       | Not Started                                            |
| `musicxml_parser.dart`        | `MusicXmlParser` (6)            | N/A                                       | N/A (0)                       | Not Started                                            |
| `note_parser.dart`            | `NoteParser` (1)                | N/A                                       | N/A (0)                       | Not Started                                            |
| `page_layout_parser.dart`     | `PageLayoutParser` (1), `ScalingParser` (1) | N/A                               | N/A (0)                       | Not Started                                            |
| `part_parser.dart`            | `PartParser` (1)                | N/A                                       | N/A (0)                       | Not Started                                            |
| `score_parser.dart`           | `ScoreParser` (1)               | `ScoreParser.cs`                          | `ScoreParser` (1)             | Partially Migrated (Stub for demonstrating TimeSignature integration. Does not match Dart version's scope.) |
| `staff_layout_parser.dart`    | `StaffLayoutParser` (1)         | N/A                                       | N/A (0)                       | Not Started                                            |
| `system_layout_parser.dart`   | `SystemLayoutParser` (1)        | N/A                                       | N/A (0)                       | Not Started                                            |

## Summary Totals

*   **Total Dart Parser Files Analyzed:** 10
*   **Total Estimated Dart Primary Public Parsing Methods:** 17
*   **Total C# Parser Files Implemented:** 1
*   **Total Estimated C# Primary Public Parsing Methods Implemented (includes stubs):** 1

This report reflects the status as of the last analysis. Further migration work will update these numbers.
