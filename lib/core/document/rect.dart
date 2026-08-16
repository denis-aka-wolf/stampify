// Описывает геометрию элементов документа Stampify.
//
// StampifyRect хранит положение и размеры элемента
// в физических миллиметрах.
//
// Этот класс является общей геометрической моделью для текста,
// изображений, таблиц, фигур и других элементов документа.

/// Представляет положение и размер элемента документа.
///
/// Все значения задаются в миллиметрах относительно
/// верхнего левого угла страницы.
class StampifyRect {
  /// Создает геометрию элемента.
  const StampifyRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Координаты края элемента и размер в миллиметрах.
  final double x,y, width, height;

  /// Возвращает правую координату элемента в миллиметрах.
  double get right => x + width;

  /// Возвращает нижнюю координату элемента в миллиметрах.
  double get bottom => y + height;

  /// Создает копию геометрии с измененными значениями.
  ///
  /// Значения, которые не переданы, сохраняют исходные значения.
  StampifyRect copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return StampifyRect(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}