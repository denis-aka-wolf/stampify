// Хранит состояние одной docking-области.
//
// DockAreaState объединяет группы, расположенные
// в одной позиции DockPosition.
//
// Область определяет общий размер соответствующей
// стороны редактора:
//
// - ширину для left и right;
// - высоту для top и bottom.
//
// Дополнительно область определяет приоритеты,
// закрепление и содержащиеся в ней группы.

import 'dock_position.dart';
import 'dock_group_state.dart';

/// Состояние docking-области.
class DockAreaState {
  /// Создает docking-область.
  const DockAreaState({
    required this.position,
    required this.size,
    required this.axisStartPriority,
    required this.axisEndPriority,
    required this.pin,
    required this.groups,
  });

  /// Сторона редактора, на которой находится область.
  final DockPosition position;

  /// Размер области - ширина для левой и правой
  /// либо высота для верхней и нижней панелей
  final double size;

  /// Является ли область лидером в начале
  /// Для левой/правой панели: axisStartPriority — это верх.
  /// Для верхней/нижней панели: axisStartPriority — это лево.
  final bool axisStartPriority;

  /// Является ли область лидером в начале
  /// Для левой/правой панели: axisEndPriority — это низ.
  /// Для верхней/нижней панели: axisEndPriority — это право.
  final bool axisEndPriority;

  /// Определяет, закреплена ли docking-область.
  final bool pin;

  /// Группы, находящиеся внутри области.
  ///
  /// Порядок групп определяется их [DockGroupState.index].
  final List<DockGroupState> groups;

  /// Возвращает количество групп в области.
  int get groupCount => groups.length;

  /// Возвращает общее количество панелей во всех группах.
  int get panelCount {
    return groups.fold(
      0,
      (count, group) => count + group.panels.length,
    );
  }
}