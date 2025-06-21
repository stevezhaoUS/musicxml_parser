import 'package:meta/meta.dart';
import 'package:collection/collection.dart'; // For DeepCollectionEquality
import 'package:musicxml_parser/src/models/appearance.dart';
import 'package:musicxml_parser/src/models/credit.dart';
import 'package:musicxml_parser/src/models/identification.dart';
import 'package:musicxml_parser/src/models/page_layout.dart';
import 'package:musicxml_parser/src/models/part.dart';
import 'package:musicxml_parser/src/models/work.dart';
import 'system_layout.dart';
import 'staff_layout.dart';

/// Represents a complete MusicXML score document.
///
/// This is the top-level object for a parsed MusicXML file. It contains
/// metadata such as [version], [work] information, [identification] details,
/// and a list of [parts] that make up the score. It also holds default
/// layout information ([pageLayout], [defaultSystemLayout], [defaultStaffLayouts]),
/// [scaling], and [appearance] settings.
///
/// Instances are typically created via [ScoreBuilder].
/// Objects of this class are immutable.
@immutable
class Score {
  /// The version of the MusicXML format used for the score (e.g., "3.1", "4.0").
  final String version;

  /// Information about the musical work itself (e.g., title).
  final Work? work;

  /// Identification metadata for the score (e.g., composer, rights).
  final Identification? identification;

  /// The list of [Part] objects that constitute the score.
  final List<Part> parts;

  /// Default page layout settings for the score.
  final PageLayout? pageLayout;

  /// Default system layout settings (e.g., margins, distances between systems).
  final SystemLayout? defaultSystemLayout;

  /// List of default staff layout settings (e.g., staff distances).
  final List<StaffLayout> defaultStaffLayouts;

  /// Scaling information used for rendering (e.g., millimeters per tenth).
  final Scaling? scaling;

  /// Default appearance settings (e.g., line widths, note sizes).
  final Appearance? appearance;

  /// The primary title of the score.
  /// Often also found within [work] or [identification] elements.
  final String? title;

  /// The primary composer of the score.
  /// Often also found within [identification] elements.
  final String? composer;

  /// A list of [Credit] entries for the score (e.g., copyright, arranger).
  final List<Credit>? credits;

  /// Creates a new [Score] instance.
  ///
  /// It is generally recommended to use [ScoreBuilder] for constructing [Score]
  /// objects, as it simplifies the process of incrementally adding properties
  /// during parsing.
  const Score({
    required this.version,
    this.work,
    this.identification,
    required this.parts,
    this.pageLayout,
    this.defaultSystemLayout,
    this.defaultStaffLayouts = const [],
    this.scaling,
    this.appearance,
    this.title,
    this.composer,
    this.credits,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Score &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          work == other.work &&
          identification == other.identification &&
          const DeepCollectionEquality().equals(parts, other.parts) &&
          pageLayout == other.pageLayout &&
          defaultSystemLayout == other.defaultSystemLayout &&
          const DeepCollectionEquality()
              .equals(defaultStaffLayouts, other.defaultStaffLayouts) &&
          scaling == other.scaling &&
          appearance == other.appearance &&
          title == other.title &&
          composer == other.composer &&
          const DeepCollectionEquality().equals(credits, other.credits);

  @override
  int get hashCode =>
      version.hashCode ^
      (work?.hashCode ?? 0) ^
      (identification?.hashCode ?? 0) ^
      const DeepCollectionEquality().hash(parts) ^
      (pageLayout?.hashCode ?? 0) ^
      (defaultSystemLayout?.hashCode ?? 0) ^
      const DeepCollectionEquality().hash(defaultStaffLayouts) ^
      (scaling?.hashCode ?? 0) ^
      (appearance?.hashCode ?? 0) ^
      (title?.hashCode ?? 0) ^
      (composer?.hashCode ?? 0) ^
      (credits != null ? const DeepCollectionEquality().hash(credits!) : 0);

  @override
  String toString() {
    final buffer = StringBuffer('Score{version: $version');
    if (title != null) {
      buffer.write(', title: $title');
    }
    if (composer != null) {
      buffer.write(', composer: $composer');
    }
    if (work != null) {
      buffer.write(', work: $work');
    }
    if (identification != null) {
      buffer.write(', identification: $identification');
    }
    buffer.write(', parts: ${parts.length}');
    if (pageLayout != null) {
      buffer.write(', defaultPageLayout: $pageLayout');
    }
    if (defaultSystemLayout != null) {
      buffer.write(', defaultSystemLayout: $defaultSystemLayout');
    }
    if (defaultStaffLayouts.isNotEmpty) {
      buffer.write(', defaultStaffLayouts: $defaultStaffLayouts');
    }
    if (scaling != null) {
      buffer.write(', scaling: $scaling');
    }
    if (appearance != null) {
      buffer.write(', appearance: $appearance');
    }
    if (credits != null && credits!.isNotEmpty) {
      buffer.write(', credits: ${credits!.length}');
    }
    buffer.write('}');
    return buffer.toString();
  }
}

/// Builder for creating [Score] objects incrementally.
///
/// This builder is useful during the parsing process for MusicXML `<score-partwise>`
/// elements, allowing various score-level properties and parts to be added
/// as they are parsed. The [build] method finalizes the score construction.
///
/// Example:
/// ```dart
/// final scoreBuilder = ScoreBuilder(version: "4.0", line: 1)
///   .setTitle("My Great Symphony")
///   .setComposer("J. S. Bach");
/// scoreBuilder.addPart(violinPart);
/// scoreBuilder.addPart(celloPart);
/// final Score myScore = scoreBuilder.build();
/// ```
class ScoreBuilder {
  String _version;
  Work? _work;
  Identification? _identification;
  List<Part> _parts = [];
  PageLayout? _pageLayout;
  SystemLayout? _defaultSystemLayout;
  List<StaffLayout> _defaultStaffLayouts = [];
  Scaling? _scaling;
  Appearance? _appearance;
  String? _title;
  String? _composer;
  List<Credit>? _credits;

  /// Line number in the XML for error reporting context.
  final int? _line;

  /// Additional context for error reporting.
  final Map<String, dynamic>? _context;

  /// Creates a [ScoreBuilder].
  ///
  /// [version] is the MusicXML version. Defaults to "3.0" if not provided or empty.
  /// [line] and [context] can be provided for more detailed error messages.
  ScoreBuilder({String? version, int? line, Map<String, dynamic>? context})
      : _version = (version != null && version.isNotEmpty) ? version : "3.0",
        _line = line,
        _context = context;

  /// Sets the MusicXML version. Defaults to "3.0" if [version] is empty.
  ScoreBuilder setVersion(String version) {
    _version = version.isNotEmpty ? version : "3.0";
    return this;
  }

  /// Sets the [Work] information for the score.
  ScoreBuilder setWork(Work? work) {
    _work = work;
    return this;
  }

  /// Sets the [Identification] metadata for the score.
  ScoreBuilder setIdentification(Identification? identification) {
    _identification = identification;
    return this;
  }

  /// Sets all [Part]s for the score.
  ScoreBuilder setParts(List<Part> parts) {
    _parts = parts;
    return this;
  }

  /// Adds a single [Part] to the score.
  ScoreBuilder addPart(Part part) {
    _parts.add(part);
    return this;
  }

  /// Sets the default [PageLayout] for the score.
  ScoreBuilder setPageLayout(PageLayout? pageLayout) {
    _pageLayout = pageLayout;
    return this;
  }

  /// Sets the default [SystemLayout] for the score.
  ScoreBuilder setDefaultSystemLayout(SystemLayout? systemLayout) {
    _defaultSystemLayout = systemLayout;
    return this;
  }

  /// Sets all default [StaffLayout]s for the score.
  ScoreBuilder setDefaultStaffLayouts(List<StaffLayout> staffLayouts) {
    _defaultStaffLayouts = staffLayouts;
    return this;
  }

  /// Adds a single default [StaffLayout] to the score.
  ScoreBuilder addDefaultStaffLayout(StaffLayout staffLayout) {
    _defaultStaffLayouts.add(staffLayout);
    return this;
  }

  /// Sets the [Scaling] information for the score.
  ScoreBuilder setScaling(Scaling? scaling) {
    _scaling = scaling;
    return this;
  }

  /// Sets the default [Appearance] settings for the score.
  ScoreBuilder setAppearance(Appearance? appearance) {
    _appearance = appearance;
    return this;
  }

  /// Sets the primary title of the score.
  ScoreBuilder setTitle(String? title) {
    _title = title;
    return this;
  }

  /// Sets the primary composer of the score.
  ScoreBuilder setComposer(String? composer) {
    _composer = composer;
    return this;
  }

  /// Sets all [Credit]s for the score.
  ScoreBuilder setCredits(List<Credit>? credits) {
    _credits = credits;
    return this;
  }

  /// Adds a single [Credit] to the score.
  ScoreBuilder addCredit(Credit credit) {
    _credits ??= [];
    _credits!.add(credit);
    return this;
  }

  /// Builds the [Score] instance.
  ///
  /// This method constructs the [Score] object from the properties set
  /// on the builder. It ensures that a version is set (defaulting to "3.0")
  /// and that the list of parts is initialized.
  Score build() {
    // Basic validation: parts list should not be null, version should be present.
    // MusicXML spec implies a score typically has parts, but an empty list is technically possible
    // if the <score-partwise> element is empty.
    // Version is required by the Score constructor and handled by builder's default.

    return Score(
      version: _version,
      work: _work,
      identification: _identification,
      parts: _parts,
      pageLayout: _pageLayout,
      defaultSystemLayout: _defaultSystemLayout,
      defaultStaffLayouts: _defaultStaffLayouts,
      scaling: _scaling,
      appearance: _appearance,
      title: _title,
      composer: _composer,
      credits: _credits,
    );
  }
}
