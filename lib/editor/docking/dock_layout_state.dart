// Хранит полное состояние docking-интерфейса.
//
// DockLayoutState является корневой моделью состояния.
// Он объединяет четыре docking-области редактора:
//
// - левую;
// - правую;
// - верхнюю;
// - нижнюю.
//
// Каждая область содержит свои docking-группы,
// а каждая группа содержит панели.
//
// DockLayoutState не отвечает за изменение layout.
// Изменение состояния выполняется через DockingController.

import 'dock_area_state.dart';
import 'dock_position.dart';

/// Полное состояние docking-интерфейса.
class DockLayoutState {
  /// Создает состояние docking-интерфейса.
  const DockLayoutState({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
  });

  /// Левая docking-область.
  final DockAreaState left;

  /// Правая docking-область.
  final DockAreaState right;

  /// Верхняя docking-область.
  final DockAreaState top;

  /// Нижняя docking-область.
  final DockAreaState bottom;

  /// Создает стандартное начальное состояние docking-интерфейса.
  factory DockLayoutState.initial() {
    return DockLayoutState(
      left: DockAreaState(
        position: DockPosition.left,
        size: 320,
        axisStartPriority: true,
        axisEndPriority: true,
        pin: true,
        groups: const [],
      ),
      right: DockAreaState(
        position: DockPosition.right,
        size: 320,
        axisStartPriority: true,
        axisEndPriority: true,
        pin: true,
        groups: const [],
      ),
      top: DockAreaState(
        position: DockPosition.top,
        size: 80,
        axisStartPriority: true,
        axisEndPriority: true,
        pin: true,
        groups: const [],
      ),
      bottom: DockAreaState(
        position: DockPosition.bottom,
        size: 80,
        axisStartPriority: true,
        axisEndPriority: true,
        pin: true,
        groups: const [],
      ),
    );
  }

  /// Возвращает копию состояния с измененными областями.
  DockLayoutState copyWith({
    DockAreaState? left,
    DockAreaState? right,
    DockAreaState? top,
    DockAreaState? bottom,
  }) {
    return DockLayoutState(
      left: left ?? this.left,
      right: right ?? this.right,
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
    );
  }

  /// Возвращает docking-область по ее позиции.
  DockAreaState getArea(DockPosition position) {
    switch (position) {
      case DockPosition.left:
        return left;
      case DockPosition.right:
        return right;
      case DockPosition.top:
        return top;
      case DockPosition.bottom:
        return bottom;
    }
  }
}