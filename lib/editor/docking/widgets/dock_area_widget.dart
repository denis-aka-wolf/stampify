// Отображает одну docking-область.
//
// DockAreaWidget отвечает за визуальное представление
// DockAreaState и содержащихся в ней docking-групп.
//
// Для левой и правой областей группы располагаются
// вертикально.
//
// Для верхней и нижней областей группы располагаются
// горизонтально.
//
// Виджет не изменяет состояние docking-интерфейса.
// Все изменения выполняются через DockingController.

import 'package:flutter/material.dart';

import '../dock_area_state.dart';
import '../dock_group_state.dart';
import '../dock_position.dart';
import '../docking_controller.dart';
import 'dock_group_widget.dart';
import 'dock_panel_registry.dart';

/// Визуальное представление одной docking-области.
class DockAreaWidget extends StatelessWidget {
  /// Создает docking-область.
  const DockAreaWidget({
    super.key,
    required this.area,
    required this.controller,
    required this.registry,
  });

  /// Состояние отображаемой docking-области.
  final DockAreaState area;

  /// Контроллер docking-интерфейса.
  final DockingController controller;

  /// Реестр визуальных docking-панелей.
  final DockPanelRegistry registry;

  /// Определяет, располагаются ли группы вертикально.
  bool get _isVertical {
    return area.position == DockPosition.left ||
        area.position == DockPosition.right;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: _isVertical
          ? Column(
              children: _buildGroups(),
            )
          : Row(
              children: _buildGroups(),
            ),
    );
  }

  /// Создает визуальные виджеты групп области.
  ///
  /// Группы с заданным размером получают фиксированный размер.
  /// Группы с размером `0` занимают оставшееся пространство.
  List<Widget> _buildGroups() {
    final fixedSize = area.groups
        .where((group) => group.size > 0)
        .fold<double>(
          0,
          (total, group) => total + group.size,
        );

    final zeroSizeGroups = area.groups
        .where((group) => group.size <= 0)
        .length;

    return area.groups.map((group) {
      if (group.size > 0) {
        return _buildGroup(group);
      }

      if (zeroSizeGroups == 0) {
        return _buildGroup(group);
      }

      return Expanded(
        child: _buildGroup(group),
      );
    }).toList();
  }

  /// Создает визуальное представление одной группы.
  Widget _buildGroup(DockGroupState group) {
    return DockGroupWidget(
      area: area,
      group: group,
      controller: controller,
      registry: registry,
    );
  }
}