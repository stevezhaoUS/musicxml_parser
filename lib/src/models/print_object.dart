import 'package:meta/meta.dart';
import 'package:collection/collection.dart';
import 'page_layout.dart';
import 'system_layout.dart';
import 'staff_layout.dart';

@immutable
class PrintObject {
  final bool newPage;
  final bool newSystem;
  final int? blankPage;
  final String? pageNumber;
  final PageLayout? localPageLayout;
  final SystemLayout? localSystemLayout;
  final List<StaffLayout> localStaffLayouts;

  const PrintObject({
    this.newPage = false,
    this.newSystem = false,
    this.blankPage,
    this.pageNumber,
    this.localPageLayout,
    this.localSystemLayout,
    this.localStaffLayouts = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintObject &&
          runtimeType == other.runtimeType &&
          newPage == other.newPage &&
          newSystem == other.newSystem &&
          blankPage == other.blankPage &&
          pageNumber == other.pageNumber &&
          localPageLayout == other.localPageLayout &&
          localSystemLayout == other.localSystemLayout &&
          const DeepCollectionEquality()
              .equals(localStaffLayouts, other.localStaffLayouts);

  @override
  int get hashCode =>
      newPage.hashCode ^
      newSystem.hashCode ^
      blankPage.hashCode ^
      pageNumber.hashCode ^
      localPageLayout.hashCode ^
      localSystemLayout.hashCode ^
      const DeepCollectionEquality().hash(localStaffLayouts);

  @override
  String toString() {
    return 'PrintObject{newPage: $newPage, newSystem: $newSystem, blankPage: $blankPage, pageNumber: $pageNumber, localPageLayout: $localPageLayout, localSystemLayout: $localSystemLayout, localStaffLayouts: $localStaffLayouts}';
  }
}
