// Описывает физические форматы страниц Stampify.
// Все размеры задаются в миллиметрах.
//
// Этот класс является источником физических размеров страницы
// для редактора документа и PDF-рендера.

class PageFormat {
  /// Создает описание физического формата страницы.
  ///
  /// [widthMm] — ширина страницы в миллиметрах.
  /// [heightMm] — высота страницы в миллиметрах.
  const PageFormat({
    required this.widthMm,
    required this.heightMm,
  });

  /// Ширина страницы в миллиметрах.
  final double widthMm;

  /// Высота страницы в миллиметрах.
  final double heightMm;

  /// Формат A4: 210 × 297 мм.
  static const a4 = PageFormat(
    widthMm: 210,
    heightMm: 297,
  );

  /// Формат A5: 148 × 210 мм.
  static const a5 = PageFormat(
    widthMm: 148,
    heightMm: 210,
  );

  /// Формат A3: 297 × 420 мм.
  static const a3 = PageFormat(
    widthMm: 297,
    heightMm: 420,
  );
}