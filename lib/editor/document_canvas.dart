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
import 'document_controller.dart';

/// Отображает физическую страницу Stampify на экране.
///
/// Размер документа хранится в миллиметрах, а [DocumentCanvas]
/// автоматически подбирает масштаб для отображения страницы
/// внутри доступной области интерфейса.
///
/// В дальнейшем Canvas станет основной областью визуального
/// редактора документов.
class DocumentCanvas extends StatefulWidget {
  /// Создает Canvas для указанного документа.
  const DocumentCanvas({
    super.key,
    required this.document,
    required this.controller,
  });

  /// Документ, который необходимо отобразить.
  final StampifyDocument document;

  /// Контроллер, через который изменяется документ.
  final DocumentController controller;

  /// Создает состояние Canvas.
  @override
  State<DocumentCanvas> createState() => _DocumentCanvasState();
}

/// Состояние интерактивного Canvas документа.
class _DocumentCanvasState extends State<DocumentCanvas> {
  /// Идентификатор текущего выбранного элемента.
  String? _selectedElementId;

  /// Начальная позиция элемента перед началом перемещения.
  Offset? _dragStartPosition;

  /// Начальные координаты элемента перед началом перемещения.
  Offset? _dragStartElementPosition;

  /// Строит визуальное представление документа.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 40.0;

        final availableWidth = constraints.maxWidth - padding * 2;
        final availableHeight = constraints.maxHeight - padding * 2;

        final scaleX = availableWidth / widget.document.widthMm;
        final scaleY = availableHeight / widget.document.heightMm;

        final scale = scaleX < scaleY ? scaleX : scaleY;

        final width = widget.document.widthMm * scale;
        final height = widget.document.heightMm * scale;

        return Center(
          child: Container(
            width: width,
            height: height,
            color: Colors.white,
            child: Stack(
              children: [
                for (final element in widget.document.elements)
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
  Widget _buildElement(
    StampifyElement element,
    double scale,
  ) {
    if (element is TextElement) {
      final isSelected = element.id == _selectedElementId;

      return Positioned(
        left: element.x * scale,
        top: element.y * scale,
        width: element.width * scale,
        height: element.height * scale,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedElementId = element.id;
            });
          },
          onPanStart: (details) {
            setState(() {
              _selectedElementId = element.id;
              _dragStartPosition = details.globalPosition;
              _dragStartElementPosition = Offset(
                element.x,
                element.y,
              );
            });
          },
          onPanUpdate: (details) {
            if (_dragStartPosition == null ||
                _dragStartElementPosition == null) {
              return;
            }

            final delta = details.globalPosition - _dragStartPosition!;

            final deltaMmX = delta.dx / scale;
            final deltaMmY = delta.dy / scale;

            final newX = _dragStartElementPosition!.dx + deltaMmX;
            final newY = _dragStartElementPosition!.dy + deltaMmY;

            widget.controller.moveElement(
              elementId: element.id,
              x: newX,
              y: newY,
            );
          },
          onPanEnd: (_) {
            _dragStartPosition = null;
            _dragStartElementPosition = null;
          },
          child: Container(
            decoration: isSelected
                ? BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 1,
                    ),
                  )
                : null,
            child: Text(
              element.text,
              textAlign: element.textAlign,
              style: TextStyle(
                fontSize: element.fontSize,
                fontWeight: element.fontWeight,
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}