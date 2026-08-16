// Отвечает за визуальное отображение и редактирование документа Stampify.
//
// DocumentCanvas преобразует физические координаты документа,
// заданные в миллиметрах, в экранные пиксели.
//
// Canvas отвечает за:
// - отображение страницы;
// - отображение элементов;
// - выбор элементов;
// - перемещение элементов;
// - изменение размеров элементов.
//
// Сам документ остается независимым от размера экрана.

import 'package:flutter/material.dart';

import '../core/document/document.dart';
import '../core/document/element.dart';
import '../core/document/rect.dart';
import 'document_controller.dart';

/// Отображает страницу Stampify и ее элементы.
///
/// Canvas является визуальным представлением документа и отвечает
/// за пользовательское взаимодействие с элементами.
///
/// Координаты элементов хранятся в миллиметрах, а Canvas
/// преобразует их в экранные координаты с учетом текущего масштаба.
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
  /// Идентификатор выбранного элемента.
  String? _selectedElementId;

  /// Позиция указателя в момент начала перемещения.
  Offset? _dragStartPosition;

  /// Начальная позиция элемента в миллиметрах.
  Offset? _dragStartElementPosition;

  /// Геометрия элемента в момент начала изменения размера.
  StampifyRect? _resizeStartRect;

  /// Позиция указателя в момент начала изменения размера.
  Offset? _resizeStartPosition;

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

  /// Создает экранное представление элемента документа.
  Widget _buildElement(
    StampifyElement element,
    double scale,
  ) {
    if (element is TextElement) {
      return _buildTextElement(
        element,
        scale,
      );
    }

    return const SizedBox.shrink();
  }

  /// Создает интерактивное представление текстового элемента.
  Widget _buildTextElement(
    TextElement element,
    double scale,
  ) {
    final isSelected = element.id == _selectedElementId;

    return Positioned(
      left: element.rect.x * scale,
      top: element.rect.y * scale,
      width: element.rect.width * scale,
      height: element.rect.height * scale,
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
              element.rect.x,
              element.rect.y,
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

          widget.controller.moveElement(
            elementId: element.id,
            x: _dragStartElementPosition!.dx + deltaMmX,
            y: _dragStartElementPosition!.dy + deltaMmY,
          );
        },
        onPanEnd: (_) {
          _dragStartPosition = null;
          _dragStartElementPosition = null;
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
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
            if (isSelected) ...[
              _buildResizeHandle(
                element: element,
                scale: scale,
                alignment: Alignment.topLeft,
                cursor: SystemMouseCursors.resizeUpLeft,
                handlePosition: _ResizeHandlePosition.topLeft,
              ),
              _buildResizeHandle(
                element: element,
                scale: scale,
                alignment: Alignment.topRight,
                cursor: SystemMouseCursors.resizeUpRight,
                handlePosition: _ResizeHandlePosition.topRight,
              ),
              _buildResizeHandle(
                element: element,
                scale: scale,
                alignment: Alignment.bottomLeft,
                cursor: SystemMouseCursors.resizeDownLeft,
                handlePosition: _ResizeHandlePosition.bottomLeft,
              ),
              _buildResizeHandle(
                element: element,
                scale: scale,
                alignment: Alignment.bottomRight,
                cursor: SystemMouseCursors.resizeDownRight,
                handlePosition: _ResizeHandlePosition.bottomRight,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Создает один маркер изменения размера элемента.
  Widget _buildResizeHandle({
    required TextElement element,
    required double scale,
    required Alignment alignment,
    required MouseCursor cursor,
    required _ResizeHandlePosition handlePosition,
  }) {
    const handleSize = 10.0;

    return Align(
      alignment: alignment,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          onPanStart: (details) {
            _resizeStartPosition = details.globalPosition;
            _resizeStartRect = element.rect;
          },
          onPanUpdate: (details) {
            if (_resizeStartPosition == null ||
                _resizeStartRect == null) {
              return;
            }

            final delta = details.globalPosition - _resizeStartPosition!;

            final deltaMmX = delta.dx / scale;
            final deltaMmY = delta.dy / scale;

            final rect = _resizeStartRect!;

            var newX = rect.x;
            var newY = rect.y;
            var newWidth = rect.width;
            var newHeight = rect.height;

            switch (handlePosition) {
              case _ResizeHandlePosition.topLeft:
                newX = rect.x + deltaMmX;
                newY = rect.y + deltaMmY;
                newWidth = rect.width - deltaMmX;
                newHeight = rect.height - deltaMmY;
                break;

              case _ResizeHandlePosition.topRight:
                newY = rect.y + deltaMmY;
                newWidth = rect.width + deltaMmX;
                newHeight = rect.height - deltaMmY;
                break;

              case _ResizeHandlePosition.bottomLeft:
                newX = rect.x + deltaMmX;
                newWidth = rect.width - deltaMmX;
                newHeight = rect.height + deltaMmY;
                break;

              case _ResizeHandlePosition.bottomRight:
                newWidth = rect.width + deltaMmX;
                newHeight = rect.height + deltaMmY;
                break;
            }

            if (newWidth < 10) {
              if (handlePosition.isLeft) {
                newX = rect.right - 10;
              }

              newWidth = 10;
            }

            if (newHeight < 5) {
              if (handlePosition.isTop) {
                newY = rect.bottom - 5;
              }

              newHeight = 5;
            }

            widget.controller.moveElement(
              elementId: element.id,
              x: newX,
              y: newY,
            );

            widget.controller.resizeElement(
              elementId: element.id,
              width: newWidth,
              height: newHeight,
            );
          },
          onPanEnd: (_) {
            _resizeStartPosition = null;
            _resizeStartRect = null;
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Определяет положение маркера изменения размера.
enum _ResizeHandlePosition {
  /// Верхний левый угол.
  topLeft,

  /// Верхний правый угол.
  topRight,

  /// Нижний левый угол.
  bottomLeft,

  /// Нижний правый угол.
  bottomRight,
}

/// Предоставляет информацию о положении resize-маркера.
extension on _ResizeHandlePosition {
  /// Возвращает true, если маркер находится слева.
  bool get isLeft {
    return this == _ResizeHandlePosition.topLeft ||
        this == _ResizeHandlePosition.bottomLeft;
  }

  /// Возвращает true, если маркер находится сверху.
  bool get isTop {
    return this == _ResizeHandlePosition.topLeft ||
        this == _ResizeHandlePosition.topRight;
  }
}