// Отвечает за визуальное отображение страницы Stampify в редакторе.
//
// DocumentCanvas преобразует физические размеры документа,
// заданные в миллиметрах, в экранные координаты.
//
// Сам документ не зависит от размера экрана или масштаба Canvas.
// Canvas является только визуальным представлением документа.
//
// В дальнейшем этот компонент будет отвечать за:
// - масштабирование страницы;
// - отображение элементов документа;
// - систему координат;
// - выделение элементов;
// - взаимодействие мышью и касанием;
// - перемещение и изменение размеров элементов.

import 'package:flutter/material.dart';

import '../core/document/document.dart';
import '../core/document/element.dart';

/// Отображает физическую страницу Stampify на экране.
///
/// Размер документа хранится в миллиметрах, а [DocumentCanvas]
/// автоматически подбирает масштаб для отображения страницы
/// внутри доступной области интерфейса.
///
/// В дальнейшем Canvas станет основной областью визуального
/// редактора документов.
class DocumentCanvas extends StatelessWidget {
  /// Создает Canvas для отображения указанного документа.
  ///
  /// [document] содержит физический размер страницы,
  /// ее ориентацию и другие параметры документа.
  const DocumentCanvas({
    super.key,
    required this.document,
  });

  /// Документ, который необходимо визуально отобразить.
  final StampifyDocument document;

  /// Строит визуальное представление страницы документа.
  ///
  /// Canvas рассчитывает масштаб на основе доступного пространства
  /// и физических размеров страницы, после чего отображает страницу
  /// с сохранением ее реальных пропорций.
  ///
  /// В будущем здесь будет размещаться слой элементов документа,
  /// например текста, изображений, таблиц и фигур.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 40.0;

        final availableWidth = constraints.maxWidth - padding * 2;
        final availableHeight = constraints.maxHeight - padding * 2;

        final scaleX = availableWidth / document.widthMm;
        final scaleY = availableHeight / document.heightMm;

        final scale = scaleX < scaleY ? scaleX : scaleY;

        final width = document.widthMm * scale;
        final height = document.heightMm * scale;

        return Center(
          child: Container(
            width: width,
            height: height,
            color: Colors.white,
            child: Stack(
              children: [
                for (final element in document.elements)
                  _buildElement(
                    element,
                    scale,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Создает экранное представление отдельного элемента документа.
  ///
  /// [element] содержит физические координаты и размеры в миллиметрах.
  /// [scale] преобразует миллиметры документа в пиксели экрана.
  Widget _buildElement(
    StampifyElement element,
    double scale,
  ) {
    if (element is TextElement) {
      return Positioned(
        left: element.x * scale,
        top: element.y * scale,
        width: element.width * scale,
        height: element.height * scale,
        child: Text(
          element.text,
          textAlign: element.textAlign,
          style: TextStyle(
            fontSize: element.fontSize,
            fontWeight: element.fontWeight,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}