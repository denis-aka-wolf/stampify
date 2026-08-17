// Управляет состоянием docking-интерфейса.
//
// DockingController является единой точкой изменения
// DockLayoutState.
//
// Контроллер изменяет области, группы и панели,
// а после каждого изменения уведомляет интерфейс.
//
// Сам контроллер не отвечает за визуальное отображение
// docking-интерфейса.

import 'package:flutter/foundation.dart';

import 'dock_area_state.dart';
import 'dock_group_state.dart';
import 'dock_layout_state.dart';
import 'dock_panel_state.dart';
import 'dock_position.dart';

/// Контроллер docking-интерфейса.
class DockingController extends ChangeNotifier {
  /// Создает контроллер с начальным состоянием layout.
  DockingController({
    required DockLayoutState initialLayout,
  }) : _layout = initialLayout;

  DockLayoutState _layout;

  /// Текущее состояние docking-интерфейса.
  DockLayoutState get layout => _layout;

  /// Возвращает docking-область по ее позиции.
  DockAreaState getArea(DockPosition position) {
    return _layout.getArea(position);
  }

  /// Заменяет текущее состояние docking-интерфейса.
  ///
  /// Используется контроллером при применении нового layout.
  void setLayout(DockLayoutState layout) {
    _layout = layout;
    notifyListeners();
  }

  /// Добавляет панель в docking-область.
  ///
  /// Если группа с указанным индексом существует,
  /// панель добавляется в нее.
  ///
  /// Если группы не существует, создается новая группа.
  ///
  /// Индекс панели автоматически определяется контроллером.
  void addPanel({
    required DockPosition position,
    required String panelId,
    int? groupIndex,
  }) {
    final area = _layout.getArea(position);

    final groups = List<DockGroupState>.from(area.groups);

    final targetGroupIndex = groupIndex ?? groups.length;

    final existingGroupIndex = groups.indexWhere(
      (group) => group.index == targetGroupIndex,
    );

    if (existingGroupIndex == -1) {
      groups.add(
        DockGroupState(
          index: targetGroupIndex,
          size: 0,
          isExpanded: true,
          panels: [
            DockPanelState(
              id: panelId,
              active: true,
              visible: true,
              index: 0,
            ),
          ],
        ),
      );
    } else {
      final group = groups[existingGroupIndex];

      final panels = List<DockPanelState>.from(group.panels);

      final nextIndex = panels.length;

      panels.add(
        DockPanelState(
          id: panelId,
          active: false,
          visible: true,
          index: nextIndex,
        ),
      );

      groups[existingGroupIndex] = group.copyWith(
        panels: panels,
      );
    }

    final updatedArea = _copyAreaWithGroups(
      area,
      groups,
    );

    _layout = _replaceArea(
      _layout,
      position,
      updatedArea,
    );

    notifyListeners();
  }

  /// Создает копию docking-области с новым списком групп.
  DockAreaState _copyAreaWithGroups(
    DockAreaState area,
    List<DockGroupState> groups,
  ) {
    return DockAreaState(
      position: area.position,
      size: area.size,
      axisStartPriority: area.axisStartPriority,
      axisEndPriority: area.axisEndPriority,
      pin: area.pin,
      groups: groups,
    );
  }

  /// Заменяет docking-область в текущем layout.
  DockLayoutState _replaceArea(
    DockLayoutState layout,
    DockPosition position,
    DockAreaState area,
  ) {
    switch (position) {
      case DockPosition.left:
        return layout.copyWith(left: area);

      case DockPosition.right:
        return layout.copyWith(right: area);

      case DockPosition.top:
        return layout.copyWith(top: area);

      case DockPosition.bottom:
        return layout.copyWith(bottom: area);
    }
  }
}