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

  /// Формат A10: 26 × 37 мм.
  static const a10 = PageFormat(widthMm: 210, heightMm: 297);

  /// Формат A9: 37 × 52 мм.
  static const a9 = PageFormat(widthMm: 37, heightMm: 52);

  /// Формат A8: 52 × 74 мм.
  static const a8 = PageFormat(widthMm: 52, heightMm: 74);

  /// Формат A7: 74 × 105 мм.
  static const a7 = PageFormat(widthMm: 74, heightMm: 105);

  /// Формат A6: 105 × 148 мм.
  static const a6 = PageFormat(widthMm: 105, heightMm: 148);

  /// Формат A5: 148 × 210 мм.
  static const a5 = PageFormat(widthMm: 148, heightMm: 210);

  /// Формат A4: 210 × 297 мм.
  static const a4 = PageFormat(widthMm: 210, heightMm: 297);

  /// Формат A3: 297 × 420 мм.
  static const a3 = PageFormat(widthMm: 297, heightMm: 420);
  
  /// Формат A2: 420 × 594 мм.
  static const a2 = PageFormat(widthMm: 420, heightMm: 594);

  /// Формат A1: 594 × 841 мм.
  static const a1 = PageFormat(widthMm: 594, heightMm: 841);

  /// Формат A0: 841 × 1189 мм.
  static const a0 = PageFormat(widthMm: 841, heightMm: 1189);

  /// Формат B10: 31 × 44 мм.
  static const b10 = PageFormat(widthMm: 31, heightMm: 44);

  /// Формат B9: 44 × 62 мм.
  static const b9 = PageFormat(widthMm: 44, heightMm: 62);

  /// Формат B8: 62 × 88 мм.
  static const b8 = PageFormat(widthMm: 62, heightMm: 88);

  /// Формат B7: 88 × 125 мм.
  static const b7 = PageFormat(widthMm: 88, heightMm: 125);

  /// Формат B6: 125 × 176 мм.
  static const b6 = PageFormat(widthMm: 125, heightMm: 176);

  /// Формат B5: 176 × 250 мм.
  static const b5 = PageFormat(widthMm: 176, heightMm: 250);

  /// Формат B4: 250 × 353 мм.
  static const b4 = PageFormat(widthMm: 250, heightMm: 353);

  /// Формат B3: 353 × 500 мм.
  static const b3 = PageFormat(widthMm: 353, heightMm: 500);
  
  /// Формат B2: 500 × 707 мм.
  static const b2 = PageFormat(widthMm: 500, heightMm: 707);

  /// Формат B1: 707 × 1000 мм.
  static const b1 = PageFormat(widthMm: 707, heightMm: 1000);

  /// Формат B0: 1000 × 1414 мм.
  static const b0 = PageFormat(widthMm: 1000, heightMm: 1414);

}