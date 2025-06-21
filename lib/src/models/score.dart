import 'package:meta/meta.dart';
import 'package:collection/collection.dart'; // For DeepCollectionEquality
import 'package:musicxml_parser/src/models/appearance.dart';
import 'package:musicxml_parser/src/models/credit.dart'; // Import for Credit
import 'package:musicxml_parser/src/models/identification.dart';
import 'package:musicxml_parser/src/models/page_layout.dart';
import 'package:musicxml_parser/src/models/part.dart';
import 'package:musicxml_parser/src/models/work.dart';
import 'system_layout.dart'; // New import
import 'staff_layout.dart'; // New import

/// Represents a MusicXML score document.
@immutable
class Score {
  /// The version of MusicXML used.
  final String version;

  /// Information about the musical work.
  final Work? work;

  /// Metadata about the score.
  final Identification? identification;

  /// List of parts in the score.
  final List<Part> parts;

  /// Default page layout information.
  final PageLayout? pageLayout; // Renamed from defaultPageLayout for consistency with existing

  /// Default system layout information.
  final SystemLayout? defaultSystemLayout;

  /// Default staff layout information.
  final List<StaffLayout> defaultStaffLayouts;

  /// Scaling information.
  final Scaling? scaling;

  /// Appearance settings.
  final Appearance? appearance;

  /// The title of the score.
  final String? title;

  /// The composer of the score.
  final String? composer;

  /// A list of credits for the score.
  final List<Credit>? credits;

  /// Creates a new [Score] instance.
  const Score({
    required this.version,
    this.work,
    this.identification,
    required this.parts,
    this.pageLayout, // This is the default page layout
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
          const DeepCollectionEquality().equals(defaultStaffLayouts, other.defaultStaffLayouts) &&
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
