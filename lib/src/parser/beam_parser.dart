import 'package:musicxml_parser/src/models/beam.dart';
import 'package:xml/xml.dart';

class BeamParser {
  /// Parses beam elements from a note element.
  ///
  /// [noteElement] - The XML element representing the note.
  /// [noteIndex] - The index of the note within the measure.
  /// [measureNumber] - The measure number this beam belongs to.
  static List<Beam> parse(
      XmlElement noteElement, int noteIndex, String measureNumber) {
    final beams = <Beam>[];

    final beamElements = noteElement.findElements('beam');
    for (final beamElement in beamElements) {
      final beamType = beamElement.innerText.trim();
      final beamNumberAttr = beamElement.getAttribute('number');
      final beamNumber =
          beamNumberAttr != null ? int.tryParse(beamNumberAttr) ?? 1 : 1;

      beams.add(Beam(
        number: beamNumber,
        type: beamType,
        measureNumber: measureNumber,
        noteIndices: [noteIndex], // 后续再合并
      ));
    }

    return beams;
  }

  /// 将单个 note 的 beam 元素合并为完整的 beam 组
  ///
  /// 这个方法会基于 beam 的 number 和 type (begin, continue, end) 属性
  /// 将相关的 beam 元素连接起来，形成完整的 beam 组
  static List<Beam> mergeBeams(List<Beam> individualBeams, String measureNumber) {
    if (individualBeams.isEmpty) return [];

    // 按 beam number 分组
    final beamsByNumber = <int, List<Beam>>{};

    for (final beam in individualBeams) {
      beamsByNumber.putIfAbsent(beam.number, () => []).add(beam);
    }

    final result = <Beam>[];

    // 对每个 beam number 分别处理
    beamsByNumber.forEach((number, beams) {
      // 对 beams 按照 noteIndex 排序，确保顺序正确
      beams.sort((a, b) => a.noteIndices.first.compareTo(b.noteIndices.first));

      // 临时存储当前处理的 beam 组
      Beam? currentBeam;
      List<int> currentNoteIndices = [];
      String? currentType;

      // 按顺序处理每个 beam
      for (final beam in beams) {
        // 如果当前 beam 是 begin 或前一个 beam 组已完成，开始新的 beam 组
        if (beam.type == 'begin' || currentBeam == null) {
          // 如果有未完成的 beam 组，先加入结果
          if (currentBeam != null && currentNoteIndices.isNotEmpty) {
            result.add(Beam(
              number: currentBeam.number,
              type: currentType ?? 'unknown',
              measureNumber: measureNumber,
              noteIndices: List.from(currentNoteIndices),
            ));
          }

          // 开始新的 beam 组
          currentBeam = beam;
          currentType = beam.type;
          currentNoteIndices = List.from(beam.noteIndices);
        }
        // 如果是 continue 或 end，添加到当前 beam 组
        else if (beam.type == 'continue' || beam.type == 'end') {
          currentNoteIndices.addAll(beam.noteIndices);

          // 如果是 end，完成当前 beam 组
          if (beam.type == 'end') {
            result.add(Beam(
              number: currentBeam.number,
              type: currentBeam.type, // 保持原始的 begin 类型
              measureNumber: measureNumber,
              noteIndices: List.from(currentNoteIndices),
            ));

            // 重置状态
            currentBeam = null;
            currentNoteIndices = [];
            currentType = null;
          }
        }
        // 对于单独的 forward hook 或 backward hook
        else if (beam.type == 'forward hook' || beam.type == 'backward hook') {
          // 这些通常是独立的，直接添加到结果
          result.add(beam);
        }
      }

      // 处理可能剩余的未完成 beam 组
      if (currentBeam != null && currentNoteIndices.isNotEmpty) {
        result.add(Beam(
          number: currentBeam.number,
          type: currentType ?? 'unknown',
          measureNumber: measureNumber,
          noteIndices: List.from(currentNoteIndices),
        ));
      }
    });

    return result;
  }
}
