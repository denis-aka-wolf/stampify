// Хранит зарегистрированные визуальные панели
// docking-интерфейса.
//
// DockPanelRegistry связывает идентификатор панели
// с функцией, создающей соответствующий Flutter-виджет.
//
// Реестр отделяет состояние docking-интерфейса
// от конкретных Flutter-виджетов.
//
// DockingController не знает о зарегистрированных
// виджетах и работает только с идентификаторами панелей.

import 'package:flutter/widgets.dart';

/// Создает визуальное содержимое docking-панели.
typedef DockPanelBuilder = Widget Function(BuildContext context);

/// Реестр визуальных docking-панелей.
class DockPanelRegistry {
  /// Создает пустой реестр панелей.
  DockPanelRegistry();

  final Map<String, DockPanelBuilder> _builders = {};

  /// Регистрирует визуальную панель.
  ///
  /// [id] должен соответствовать идентификатору
  /// в [DockPanelState].
  void register(
    String id,
    DockPanelBuilder builder,
  ) {
    _builders[id] = builder;
  }

  /// Удаляет панель из реестра.
  ///
  /// Удаление из реестра не удаляет панель
  /// из DockLayoutState.
  void unregister(String id) {
    _builders.remove(id);
  }

  /// Проверяет, зарегистрирована ли панель.
  bool contains(String id) {
    return _builders.containsKey(id);
  }

  /// Возвращает builder панели.
  ///
  /// Если панель не зарегистрирована, возвращает `null`.
  DockPanelBuilder? getBuilder(String id) {
    return _builders[id];
  }

  /// Удаляет все зарегистрированные панели.
  void clear() {
    _builders.clear();
  }
}