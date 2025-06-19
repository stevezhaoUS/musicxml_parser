/// A Dart package for parsing MusicXML files into Dart objects.
///
/// This library provides a comprehensive set of tools for parsing MusicXML files,
/// which are a standard format for representing musical scores in XML.
/// The parsed data is converted into immutable Dart objects that can be used
/// in any Dart application.
library;

// Export exceptions
export 'src/exceptions/invalid_musicxml_exception.dart';
export 'src/exceptions/musicxml_parse_exception.dart';
export 'src/exceptions/musicxml_structure_exception.dart';
export 'src/exceptions/musicxml_validation_exception.dart';
// Export models
export 'src/models/beam.dart';
export 'src/models/duration.dart';
export 'src/models/key_signature.dart';
export 'src/models/measure.dart';
export 'src/models/note.dart';
export 'src/models/part.dart';
export 'src/models/pitch.dart';
export 'src/models/score.dart';
export 'src/models/time_signature.dart';
// Export main parser
export 'src/parser/musicxml_parser.dart';
// Export specialized parsers (for advanced usage)
export 'src/parser/attributes_parser.dart';
export 'src/parser/measure_parser.dart';
export 'src/parser/note_parser.dart';
export 'src/parser/part_parser.dart';
export 'src/parser/score_parser.dart';
export 'src/parser/xml_helper.dart';
// Export utils
export 'src/utils/musicxml_utils.dart';
export 'src/utils/validation_utils.dart';
export 'src/utils/warning_system.dart';
