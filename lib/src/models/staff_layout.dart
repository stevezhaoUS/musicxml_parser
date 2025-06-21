import 'package:meta/meta.dart';

@immutable
class StaffLayout {
  final int
      staffNumber; // staff number this layout applies to (default 1 if not present in XML attribute)
  final double? staffDistance; // distance from previous staff

  const StaffLayout({
    required this.staffNumber,
    this.staffDistance,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffLayout &&
          runtimeType == other.runtimeType &&
          staffNumber == other.staffNumber &&
          staffDistance == other.staffDistance;

  @override
  int get hashCode => staffNumber.hashCode ^ staffDistance.hashCode;

  @override
  String toString() {
    return 'StaffLayout{staffNumber: $staffNumber, staffDistance: $staffDistance}';
  }
}
