// Содержит основную модель документа Stampify.
//
// StampifyDocument описывает физические параметры документа,
// на основе которых редактор строит Canvas, а PDF-рендерер
// формирует страницу соответствующего размера.
import 'element.dart';
import 'page_format.dart';
import 'page_orientation.dart';

/// Представляет документ Stampify.
///
/// Документ содержит формат страницы, ориентацию и список элементов,
/// размещенных на странице.
class StampifyDocument {
  /// Создает документ с указанным форматом и ориентацией страницы.
  ///
  /// По умолчанию используется портретная ориентация.
  const StampifyDocument({
    required this.pageFormat,
    this.orientation = PageOrientation.portrait,
    this.elements = const [],
  });

  /// Физический формат страницы документа.
  final PageFormat pageFormat;

  /// Ориентация страницы документа.
  final PageOrientation orientation;

  /// Элементы, размещенные на странице.
  final List<StampifyElement> elements;

  /// Возвращает физическую ширину страницы в миллиметрах
  /// с учетом выбранной ориентации.
  double get widthMm {
    return orientation == PageOrientation.portrait
        ? pageFormat.widthMm
        : pageFormat.heightMm;
  }

  /// Возвращает физическую высоту страницы в миллиметрах
  /// с учетом выбранной ориентации.
  double get heightMm {
    return orientation == PageOrientation.portrait
        ? pageFormat.heightMm
        : pageFormat.widthMm;
  }
}