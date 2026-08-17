// Хранит состояние одной docking-группы.
//
// DockGroupState объединяет панели, находящиеся в одном
// docking-контейнере.
//
// Группа имеет сторону размещения, индекс среди групп
// этой стороны и собственный размер.
//
// Все панели внутри группы используют один и тот же
// визуальный контейнер и поэтому имеют общий размер.

import 'dock_panel_state.dart';

/// Состояние docking-группы.
class DockGroupState {
  /// Создает docking-группу.
  const DockGroupState({
    required this.index,
    required this.size,
    required this.isExpanded,
    required this.panels,
  });
  
  /// Индекс группы среди групп на той же стороне.
  ///
  /// Например:
  ///
  /// `left, index = 0` — верхняя группа.
  ///
  /// `left, index = 1` — следующая группа ниже.
  final int index;

  /// Размер группы по оси, перпендикулярной основной оси области.
  ///
  /// Для left и right определяет высоту группы.
  ///
  /// Для top и bottom определяет ширину группы.
  ///
  /// Значение `0` означает, что группа занимает
  /// всё доступное пространство по этой оси.
  final double size;

  /// Группа развернута
  final bool isExpanded;
  
  /// Панели, находящиеся внутри группы.
  ///
  /// Порядок панелей определяется их [DockPanelState.index].
  final List<DockPanelState> panels;

  /// Возвращает количество панелей в группе.
  int get panelCount => panels.length;

  /// Определяет, нужно ли отображать вкладки.
  ///
  /// Если панель всего одна, визуальный TabBar не требуется.
  bool get hasTabs => panels.length > 1;

  /// Создает копию группы с измененными параметрами.
  DockGroupState copyWith({
    int? index,
    double? size,
    bool? isExpanded,
    List<DockPanelState>? panels,
  }) {
    return DockGroupState(
      index: index ?? this.index,
      size: size ?? this.size,
      isExpanded: isExpanded ?? this.isExpanded,
      panels: panels ?? this.panels,
    );
  }
}