// Хранит состояние отдельной панели docking-интерфейса.
//
// DockPanelState описывает саму панель и ее положение
// внутри docking-группы.
//
// Размер и сторона закрепления не принадлежат панели,
// поскольку несколько панелей одной группы используют
// общий контейнер и общий размер.

/// Состояние отдельной панели docking-интерфейса.
class DockPanelState {
  /// Создает состояние панели.
  const DockPanelState({
    required this.id,
    this.active = true,
    this.visible = true,
    this.index = 0,
  });

  /// Уникальный идентификатор панели.
  ///
  /// Например:
  /// `inspector`, `layers`, `properties`.
  final String id;

  /// Отоборажает активна ли вкладка
  final bool active;
    
  /// Определяет, отображается ли панель.
  final bool visible;

  /// Индекс панели среди вкладок своей docking-группы.
  ///
  /// Индексация начинается с `0`.
  ///
  /// При добавлении панели в группу индекс определяется
  /// текущим расположением панели среди остальных панелей.
  ///
  /// Если панель является единственной в группе,
  /// ее индекс равен `0`, но визуальная вкладка не отображается.
  final int index;

  /// Создает копию состояния панели с измененными параметрами.
  DockPanelState copyWith({
    String? id,
    bool? active,
    bool? visible,
    int? index,
  }) {
    return DockPanelState(
      id: id ?? this.id,
      active: active ?? this.active,
      visible: visible ?? this.visible,
      index: index ?? this.index,
    );
  }
}