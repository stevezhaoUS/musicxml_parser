import 'package:meta/meta.dart';
import 'package:musicxml_parser/src/models/direction_type_elements.dart';

@immutable
class Offset {
  final double value;
  final bool sound; // Corresponds to the 'sound' attribute of <offset>

  const Offset({required this.value, this.sound = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Offset &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          sound == other.sound;

  @override
  int get hashCode => value.hashCode ^ sound.hashCode;

  @override
  String toString() => 'Offset{value: $value, sound: $sound}';
}

@immutable
class Staff {
  final int value;

  const Staff({required this.value});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Staff && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Staff{value: $value}';
}

@immutable
class Sound {
  // Attributes related to playback
  final double? tempo; // MIDI tempo in beats per minute
  final double? dynamics; // Dynamic scaling factor (percentage)
  final bool? dacapo;
  final String? segno; // Value is text, e.g., name of segno mark
  final String? coda; // Value is text, e.g., name of coda mark
  final String? fine; // Value is text, e.g., text for fine mark
  final bool? timeOnly; // Specifies which parts of a metronome mark to play
  final bool? pizzicato;
  final double? pan;
  final double? elevation;
  // TODO: Add other sound attributes like pedal, etc. as needed
  // For <offset> child of <sound>
  final Offset? offset;

  const Sound({
    this.tempo,
    this.dynamics,
    this.dacapo,
    this.segno,
    this.coda,
    this.fine,
    this.timeOnly,
    this.pizzicato,
    this.pan,
    this.elevation,
    this.offset,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sound &&
          runtimeType == other.runtimeType &&
          tempo == other.tempo &&
          dynamics == other.dynamics &&
          dacapo == other.dacapo &&
          segno == other.segno &&
          coda == other.coda &&
          fine == other.fine &&
          timeOnly == other.timeOnly &&
          pizzicato == other.pizzicato &&
          pan == other.pan &&
          elevation == other.elevation &&
          offset == other.offset;

  @override
  int get hashCode =>
      tempo.hashCode ^
      dynamics.hashCode ^
      dacapo.hashCode ^
      segno.hashCode ^
      coda.hashCode ^
      fine.hashCode ^
      timeOnly.hashCode ^
      pizzicato.hashCode ^
      pan.hashCode ^
      elevation.hashCode ^
      offset.hashCode;

  @override
  String toString() {
    return 'Sound{tempo: $tempo, dynamics: $dynamics, dacapo: $dacapo, segno: $segno, coda: $coda, fine: $fine, timeOnly: $timeOnly, pizzicato: $pizzicato, pan: $pan, elevation: $elevation, offset: $offset}';
  }
}

@immutable
class Direction {
  final List<DirectionTypeElement> directionTypes;
  final Offset? offset;
  final Staff? staff;
  final Sound? sound;
  // Attributes of <direction> element itself
  final String? placement; // above-below
  final String? directive; // yes-no
  final String? system; // system-relation
  final String? id;

  const Direction({
    required this.directionTypes,
    this.offset,
    this.staff,
    this.sound,
    this.placement,
    this.directive,
    this.system,
    this.id,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Direction &&
          runtimeType == other.runtimeType &&
          ListEquality().equals(directionTypes, other.directionTypes) &&
          offset == other.offset &&
          staff == other.staff &&
          sound == other.sound &&
          placement == other.placement &&
          directive == other.directive &&
          system == other.system &&
          id == other.id;

  @override
  int get hashCode =>
      ListEquality().hash(directionTypes) ^
      offset.hashCode ^
      staff.hashCode ^
      sound.hashCode ^
      placement.hashCode ^
      directive.hashCode ^
      system.hashCode ^
      id.hashCode;

  @override
  String toString() {
    return 'Direction{directionTypes: $directionTypes, offset: $offset, staff: $staff, sound: $sound, placement: $placement, directive: $directive, system: $system, id: $id}';
  }
}

// Helper for list equality, copied from direction_type_elements.dart
// Consider moving to a common utility file if used in more places.
class ListEquality {
  bool equals(List? a, List? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int hash(List? a) {
    if (a == null) return 0;
    return a.fold(0, (prev, element) => prev ^ element.hashCode);
  }
}
