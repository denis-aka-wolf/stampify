/// Описывает физический размер страницы документа в миллиметрах.
///
/// Используется как источник истины для Canvas и PDF-рендера.
/// Координаты и размеры элементов документа также задаются
/// в миллиметрах, поэтому документ не зависит от разрешения экрана.
class PageFormat {
  final double widthMm;
  final double heightMm;

  const PageFormat({
    required this.widthMm,
    required this.heightMm,
  });

  static const a4 = PageFormat(
    widthMm: 210,
    heightMm: 297,
  );

  static const a5 = PageFormat(
    widthMm: 148,
    heightMm: 210,
  );

  static const a3 = PageFormat(
    widthMm: 297,
    heightMm: 420,
  );
}