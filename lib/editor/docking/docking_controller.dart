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

  /// Создает новую docking-группу в указанной области.
  ///
  /// Группа добавляется в конец списка групп.
  ///
  /// Индекс группы определяется автоматически и всегда
  /// соответствует ее положению в списке.
  void createGroup({
    required DockPosition position,
    double size = 0,
    bool isExpanded = true,
  }) {
    final area = _layout.getArea(position);

    final groups = List<DockGroupState>.from(area.groups);

    groups.add(
      DockGroupState(
        index: groups.length,
        size: size,
        isExpanded: isExpanded,
        panels: const [],
      ),
    );

    _updateArea(
      position,
      _copyAreaWithGroups(area, groups),
    );
  }

  /// Удаляет docking-группу из указанной области.
  ///
  /// После удаления индексы остальных групп
  /// пересчитываются автоматически.
  void removeGroup({
    required DockPosition position,
    required int groupIndex,
  }) {
    final area = _layout.getArea(position);

    final groups = List<DockGroupState>.from(area.groups);

    groups.removeWhere(
      (group) => group.index == groupIndex,
    );

    _reindexGroups(groups);

    _updateArea(
      position,
      _copyAreaWithGroups(area, groups),
    );
  }

  /// Добавляет панель в docking-область.
  ///
  /// Если [groupIndex] не указан, создается новая группа.
  ///
  /// Если [groupIndex] указан и группа существует,
  /// панель добавляется в эту группу как новая вкладка.
  void addPanel({
    required DockPosition position,
    required String panelId,
    int? groupIndex,
  }) {
    final area = _layout.getArea(position);

    final groups = List<DockGroupState>.from(area.groups);

    if (groupIndex == null) {
      groups.add(
        DockGroupState(
          index: groups.length,
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
      final groupPosition = groups.indexWhere(
        (group) => group.index == groupIndex,
      );

      if (groupPosition == -1) {
        throw ArgumentError(
          'Docking group $groupIndex does not exist.',
        );
      }

      final group = groups[groupPosition];

      final panels = List<DockPanelState>.from(
        group.panels,
      );

      panels.add(
        DockPanelState(
          id: panelId,
          active: false,
          visible: true,
          index: panels.length,
        ),
      );

      groups[groupPosition] = group.copyWith(
        panels: panels,
      );
    }

    _reindexGroups(groups);

    _updateArea(
      position,
      _copyAreaWithGroups(area, groups),
    );
  }

  /// Удаляет панель из docking-интерфейса.
  ///
  /// Панель ищется во всех docking-группах указанной области.
  ///
  /// После удаления индексы остальных панелей
  /// пересчитываются автоматически.
  ///
  /// Если после удаления группа становится пустой,
  /// группа также удаляется.
  void removePanel({
    required DockPosition position,
    required String panelId,
  }) {
    final area = _layout.getArea(position);

    final groups = List<DockGroupState>.from(area.groups);

    for (var groupIndex = 0; groupIndex < groups.length; groupIndex++) {
      final group = groups[groupIndex];

      final containsPanel = group.panels.any(
        (panel) => panel.id == panelId,
      );

      if (!containsPanel) {
        continue;
      }

      final panels = List<DockPanelState>.from(group.panels);
      
      // Определим первую панель чтобы ее сделать активной
      final removedPanel = group.panels.firstWhere(
        (panel) => panel.id == panelId,
      );

      panels.removeWhere(
        (panel) => panel.id == panelId,
      );

      // Делаем активной первую панель
      if (removedPanel.active && panels.isNotEmpty) {
        panels[0] = panels[0].copyWith(
          active: true,
        );
      }

      // Перестроим индексы панелей
      _reindexPanels(panels);

      if (panels.isEmpty) {
        groups.removeAt(groupIndex);
        _reindexGroups(groups);
      } else {
        groups[groupIndex] = group.copyWith(
          panels: panels,
        );
      }

      _updateArea(
        position,
        _copyAreaWithGroups(area, groups),
      );

      return;
    }
  }

  /// Перемещает панель между docking-группами.
  ///
  /// Панель может перемещаться:
  /// - внутри одной группы;
  /// - между группами одной области;
  /// - между разными docking-областями.
  ///
  /// [fromPosition] и [fromGroupIndex] определяют исходное положение.
  ///
  /// [toPosition] и [toGroupIndex] определяют новую группу.
  ///
  /// Если [toGroupIndex] не существует, будет создана новая группа.
  ///
  /// После перемещения панель становится активной
  /// в новой docking-группе.
  void movePanel({
    required DockPosition fromPosition,
    required int fromGroupIndex,
    required String panelId,
    required DockPosition toPosition,
    required int toGroupIndex,
  }) {
    final sourceArea = _layout.getArea(fromPosition);

    final sourceGroups = List<DockGroupState>.from(
      sourceArea.groups,
    );

    final sourceGroupPosition = sourceGroups.indexWhere(
      (group) => group.index == fromGroupIndex,
    );

    if (sourceGroupPosition == -1) {
      throw ArgumentError(
        'Source docking group $fromGroupIndex does not exist.',
      );
    }

    final sourceGroup = sourceGroups[sourceGroupPosition];

    final panelPosition = sourceGroup.panels.indexWhere(
      (panel) => panel.id == panelId,
    );

    if (panelPosition == -1) {
      throw ArgumentError(
        'Panel "$panelId" does not exist in source docking group '
        '$fromGroupIndex.',
      );
    }

    final panel = sourceGroup.panels[panelPosition];

    // ------------------------------------------------------------
    // Если панель перемещается внутри той же самой группы.
    // ------------------------------------------------------------

    if (fromPosition == toPosition &&
        fromGroupIndex == toGroupIndex) {
      return;
    }

    // ------------------------------------------------------------
    // Перемещение внутри одной docking-области.
    // ------------------------------------------------------------

    if (fromPosition == toPosition) {
      final groups = List<DockGroupState>.from(
        sourceGroups,
      );

      final targetGroupPosition = groups.indexWhere(
        (group) => group.index == toGroupIndex,
      );

      if (targetGroupPosition == -1) {
        throw ArgumentError(
          'Target docking group $toGroupIndex does not exist.',
        );
      }

      final targetGroup = groups[targetGroupPosition];

      // Удаляем панель из исходной группы.
      final sourcePanels = List<DockPanelState>.from(
        sourceGroup.panels,
      );

      sourcePanels.removeAt(panelPosition);

      _reindexPanels(sourcePanels);

      if (panel.active && sourcePanels.isNotEmpty) {
        sourcePanels[0] = sourcePanels[0].copyWith(
          active: true,
        );
      }

      // Добавляем панель в целевую группу.
      final targetPanels = List<DockPanelState>.from(
        targetGroup.panels,
      );

      targetPanels.add(
        panel.copyWith(
          active: true,
          index: targetPanels.length,
        ),
      );

      groups[targetGroupPosition] = targetGroup.copyWith(
        panels: targetPanels,
      );

      // Если исходная группа опустела,
      // удаляем ее.
      if (sourcePanels.isEmpty) {
        groups.removeAt(sourceGroupPosition);

        // Если исходная группа находилась
        // перед целевой группой, ее индекс изменился.
        if (sourceGroupPosition < targetGroupPosition) {
          final newTargetPosition = targetGroupPosition - 1;

          groups[newTargetPosition] = groups[newTargetPosition].copyWith(
            panels: targetPanels,
          );
        }
      } else {
        // Исходная группа всё ещё существует.
        //
        // После удаления панели она получает
        // обновленный список вкладок.
        final updatedSourcePosition = groups.indexWhere(
          (group) => group.index == sourceGroup.index,
        );

        if (updatedSourcePosition != -1) {
          groups[updatedSourcePosition] =
              groups[updatedSourcePosition].copyWith(
            panels: sourcePanels,
          );
        }
      }

      _reindexGroups(groups);

      _updateArea(
        fromPosition,
        _copyAreaWithGroups(
          sourceArea,
          groups,
        ),
      );

      return;
    }

    // ------------------------------------------------------------
    // Перемещение между разными docking-областями.
    // ------------------------------------------------------------

    final targetArea = _layout.getArea(toPosition);

    final targetGroups = List<DockGroupState>.from(
      targetArea.groups,
    );

    final targetGroupPosition = targetGroups.indexWhere(
      (group) => group.index == toGroupIndex,
    );

    // Удаляем панель из исходной области.
    final sourcePanels = List<DockPanelState>.from(
      sourceGroup.panels,
    );

    sourcePanels.removeAt(panelPosition);

    _reindexPanels(sourcePanels);

    // Установим активную панель
    if (panel.active && sourcePanels.isNotEmpty) {
      sourcePanels[0] = sourcePanels[0].copyWith(
        active: true,
      );
    }
    if (sourcePanels.isEmpty) {
      sourceGroups.removeAt(sourceGroupPosition);
    } else {
      sourceGroups[sourceGroupPosition] = sourceGroup.copyWith(
        panels: sourcePanels,
      );
    }

    _reindexGroups(sourceGroups);

    // Если целевой группы нет, создаём новую.
    if (targetGroupPosition == -1) {
      targetGroups.add(
        DockGroupState(
          index: targetGroups.length,
          size: 0,
          isExpanded: true,
          panels: [
            panel.copyWith(
              active: true,
              index: 0,
            ),
          ],
        ),
      );
    } else {
      final targetGroup = targetGroups[targetGroupPosition];

      final targetPanels = List<DockPanelState>.from(
        targetGroup.panels,
      );

      // Все существующие панели перестают быть активными.
      final inactivePanels = targetPanels.map(
        (targetPanel) {
          return targetPanel.copyWith(
            active: false,
          );
        },
      ).toList();

      inactivePanels.add(
        panel.copyWith(
          active: true,
          index: inactivePanels.length,
        ),
      );

      targetGroups[targetGroupPosition] = targetGroup.copyWith(
        panels: inactivePanels,
      );
    }

    _reindexGroups(targetGroups);

    // Сначала заменяем исходную область.
    _layout = _replaceArea(
      _layout,
      fromPosition,
      _copyAreaWithGroups(
        sourceArea,
        sourceGroups,
      ),
    );

    // Затем заменяем целевую область.
    _layout = _replaceArea(
      _layout,
      toPosition,
      _copyAreaWithGroups(
        targetArea,
        targetGroups,
      ),
    );

    notifyListeners();
  }

  /// Делает указанную панель активной в своей docking-группе.
  ///
  /// Все остальные панели этой группы становятся неактивными.
  ///
  /// Активной может быть только одна панель группы.
  void setActivePanel({
    required DockPosition position,
    required int groupIndex,
    required String panelId,
  }) {
    final area = _layout.getArea(position);

    final groups = List<DockGroupState>.from(area.groups);

    final groupPosition = groups.indexWhere(
      (group) => group.index == groupIndex,
    );

    if (groupPosition == -1) {
      throw ArgumentError(
        'Docking group $groupIndex does not exist.',
      );
    }

    final group = groups[groupPosition];

    final panelPosition = group.panels.indexWhere(
      (panel) => panel.id == panelId,
    );

    if (panelPosition == -1) {
      throw ArgumentError(
        'Panel "$panelId" does not exist in docking group $groupIndex.',
      );
    }

    final panels = group.panels.map((panel) {
      return panel.copyWith(
        active: panel.id == panelId,
      );
    }).toList();

    groups[groupPosition] = group.copyWith(
      panels: panels,
    );

    _updateArea(
      position,
      _copyAreaWithGroups(area, groups),
    );
  }

  /// Заменяет область в текущем layout и уведомляет интерфейс
  /// об изменении состояния.
  void _updateArea(
    DockPosition position,
    DockAreaState area,
  ) {
    _layout = _replaceArea(
      _layout,
      position,
      area,
    );

    notifyListeners();
  }

  /// Пересчитывает индексы docking-групп.
  ///
  /// Индексы всегда идут последовательно:
  ///
  /// 0, 1, 2, 3 ...
  void _reindexGroups(List<DockGroupState> groups) {
    for (var i = 0; i < groups.length; i++) {
      final group = groups[i];

      groups[i] = group.copyWith(
        index: i,
      );
    }
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

  /// Пересчитывает индексы панелей внутри docking-группы.
  ///
  /// Индексы всегда идут последовательно:
  ///
  /// 0, 1, 2, 3 ...
  void _reindexPanels(List<DockPanelState> panels) {
    for (var i = 0; i < panels.length; i++) {
      final panel = panels[i];

      panels[i] = panel.copyWith(
        index: i,
      );
    }
  }
}