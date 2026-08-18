// Отображает полный docking-интерфейс редактора.
//
// DockLayout является корневым визуальным контейнером
// docking-системы.
//
// Виджет получает DockingController и отображает четыре
// docking-области:
//
// - left;
// - right;
// - top;
// - bottom.
//
// Сам виджет не изменяет DockLayoutState напрямую.
// Все изменения выполняются через DockingController.

import 'package:flutter/material.dart';

import '../dock_layout_state.dart';
import '../docking_controller.dart';
import 'dock_area_widget.dart';
import 'dock_panel_registry.dart';

/// Корневой виджет docking-интерфейса.
class DockLayout extends StatelessWidget {
  /// Создает корневой docking-интерфейс.
  const DockLayout({
    super.key,
    required this.controller,
    required this.registry,
    required this.child,
  });

  /// Контроллер docking-интерфейса.
  final DockingController controller;

  /// Реестр визуальных docking-панелей.
  final DockPanelRegistry registry;

  /// Основное содержимое редактора.
  ///
  /// Например, холст документа.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final layout = controller.layout;

        return Column(
          children: [
            _buildTopArea(layout),
            Expanded(
              child: _buildCenter(
                layout,
              ),
            ),
            _buildBottomArea(layout),
          ],
        );
      },
    );
  }

  /// Создает верхнюю docking-область.
  Widget _buildTopArea(DockLayoutState layout) {
    if (layout.top.groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: layout.top.size,
      child: DockAreaWidget(
        area: layout.top,
        controller: controller,
        registry: registry,
      ),
    );
  }

  /// Создает нижнюю docking-область.
  Widget _buildBottomArea(DockLayoutState layout) {
    if (layout.bottom.groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: layout.bottom.size,
      child: DockAreaWidget(
        area: layout.bottom,
        controller: controller,
        registry: registry,
      ),
    );
  }

  /// Создает центральную область редактора.
  Widget _buildCenter(DockLayoutState layout) {
    return Row(
      children: [
        _buildLeftArea(layout),
        Expanded(
          child: child,
        ),
        _buildRightArea(layout),
      ],
    );
  }

  /// Создает левую docking-область.
  Widget _buildLeftArea(DockLayoutState layout) {
    if (layout.left.groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: layout.left.size,
      child: DockAreaWidget(
        area: layout.left,
        controller: controller,
        registry: registry,
      ),
    );
  }

  /// Создает правую docking-область.
  Widget _buildRightArea(DockLayoutState layout) {
    if (layout.right.groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: layout.right.size,
      child: DockAreaWidget(
        area: layout.right,
        controller: controller,
        registry: registry,
      ),
    );
  }
}