// Отображает одну docking-группу.
//
// DockGroupWidget отвечает за визуальное представление
// DockGroupState.
//
// Группа содержит одну или несколько docking-панелей.
//
// Если в группе находится одна панель, вкладка не отображается.
//
// Если панелей несколько, отображается панель вкладок,
// а содержимое определяется активной панелью.
//
// Виджет не изменяет состояние docking-интерфейса напрямую.
// Изменения выполняются через DockingController.

import 'package:flutter/material.dart';
import 'package:stampify/editor/docking/widgets/dock_panel_registry.dart';

import '../dock_area_state.dart';
import '../dock_group_state.dart';
import '../dock_panel_state.dart';
import '../dock_position.dart';
import '../docking_controller.dart';

/// Визуальное представление docking-группы.
class DockGroupWidget extends StatelessWidget {
  /// Создает docking-группу.
  const DockGroupWidget({
    super.key,
    required this.area,
    required this.group,
    required this.controller, 
    required this.registry,
  });

  /// Область, которой принадлежит группа.
  final DockAreaState area;

  /// Состояние docking-группы.
  final DockGroupState group;

  /// Контроллер docking-интерфейса.
  final DockingController controller;

  /// Реестр визуальных docking-панелей.
  final DockPanelRegistry registry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: Column(
        children: [
          if (group.hasTabs) _buildTabBar(),
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  /// Возвращает ширину группы.
  ///
  /// Для top и bottom размер группы определяется
  /// DockGroupState.size.
  ///
  /// Для left и right ширина определяется
  /// DockAreaState.size.
  double? get _width {
    switch (area.position) {
      case DockPosition.left:
      case DockPosition.right:
        return area.size;

      case DockPosition.top:
      case DockPosition.bottom:
        return group.size == 0 ? null : group.size;
    }
  }

  /// Возвращает высоту группы.
  ///
  /// Для left и right размер группы определяется
  /// DockGroupState.size.
  ///
  /// Для top и bottom высота определяется
  /// DockAreaState.size.
  double? get _height {
    switch (area.position) {
      case DockPosition.left:
      case DockPosition.right:
        return group.size == 0 ? null : group.size;

      case DockPosition.top:
      case DockPosition.bottom:
        return area.size;
    }
  }

  /// Создает панель вкладок группы.
  Widget _buildTabBar() {
    return SizedBox(
      height: 32,
      child: Row(
        children: group.panels.map((panel) {
          return InkWell(
            onTap: () {
              controller.setActivePanel(
                position: area.position,
                groupIndex: group.index,
                panelId: panel.id,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Center(
                child: Text(panel.id),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Создает содержимое активной панели.
  Widget _buildContent(BuildContext context) {
    final activePanel = group.panels.cast<DockPanelState?>().firstWhere(
      (panel) => panel?.active == true,
      orElse: () => null,
    );

    if (activePanel == null) {
      return const SizedBox.shrink();
    }

    final builder = registry.getBuilder(
      activePanel.id,
    );

    if (builder == null) {
      return Center(
        child: Text(
          'Панель "${activePanel.id}" не зарегистрирована.',
        ),
      );
    }

    return builder(context);
  }
}