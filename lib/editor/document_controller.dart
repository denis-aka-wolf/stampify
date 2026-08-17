// Отвечает за изменение состояния документа во время редактирования.
//
// DocumentController является промежуточным слоем между пользовательским
// интерфейсом редактора и моделью StampifyDocument.
//
// Здесь будут находиться операции добавления, удаления, перемещения,
// изменения размеров и других свойств элементов документа.
//
// Контроллер не отвечает за отображение документа. Его задача заключается
// только в изменении модели и уведомлении интерфейса об этих изменениях.

import 'package:flutter/foundation.dart';

import '../core/document/document.dart';
import '../core/document/element.dart';
import '../core/document/rect.dart';

/// Управляет состоянием документа во время его редактирования.
///
/// Контроллер хранит текущую версию [StampifyDocument] и предоставляет
/// операции для изменения элементов документа.
///
/// Для уведомления интерфейса используется [ChangeNotifier].
class DocumentController extends ChangeNotifier {
  /// Создает контроллер с начальным документом.
  DocumentController({
    required this._document,
  });

  /// Текущая версия документа.
  StampifyDocument _document;

  /// Возвращает текущую версию документа.
  StampifyDocument get document => _document;

  /// Перемещает элемент документа в указанную позицию.
  ///
  /// [elementId] — идентификатор перемещаемого элемента.
  ///
  /// [x] — новая координата по горизонтали в миллиметрах.
  ///
  /// [y] — новая координата по вертикали в миллиметрах.
  void moveElement({
    required String elementId,
    required double x,
    required double y,
  }) {
    final elementIndex = _document.elements.indexWhere(
      (element) => element.id == elementId,
    );

    if (elementIndex == -1) {
      return;
    }

    final element = _document.elements[elementIndex];

    final maxX = _document.widthMm - element.rect.width;
    final maxY = _document.heightMm - element.rect.height;

    final clampedX = x.clamp(0.0, maxX);
    final clampedY = y.clamp(0.0, maxY);

    updateElementRect(
      elementId: elementId,
      rect: element.rect.copyWith(
        x: clampedX,
        y: clampedY,
      ),
    );
  }

  /// Изменяет размер элемента.
  ///
  /// [width] и [height] задаются в миллиметрах.
  ///
  /// Элемент не может стать меньше [minWidth] × [minHeight]
  /// и не может выйти за пределы страницы.
  void resizeElement({
    required String elementId,
    required double width,
    required double height,
    double minWidth = 10,
    double minHeight = 5,
  }) {
    final elementIndex = _document.elements.indexWhere(
      (element) => element.id == elementId,
    );

    if (elementIndex == -1) {
      return;
    }

    final element = _document.elements[elementIndex];

    final maxWidth = _document.widthMm - element.rect.x;
    final maxHeight = _document.heightMm - element.rect.y;

    final clampedWidth = width.clamp(
      minWidth,
      maxWidth < minWidth ? minWidth : maxWidth,
    );

    final clampedHeight = height.clamp(
      minHeight,
      maxHeight < minHeight ? minHeight : maxHeight,
    );

    updateElementRect(
      elementId: elementId,
      rect: element.rect.copyWith(
        width: clampedWidth,
        height: clampedHeight,
      ),
    );
  }

  /// Полностью заменяет геометрию элемента.
  ///
  /// [elementId] — идентификатор элемента.
  /// [rect] — новая позиция и размер элемента.
  void updateElementRect({
    required String elementId,
    required StampifyRect rect,
  }) {
    final elementIndex = _document.elements.indexWhere(
      (element) => element.id == elementId,
    );

    if (elementIndex == -1) {
      return;
    }

    final updatedElement = _copyElementWithRect(
      _document.elements[elementIndex],
      rect,
    );

    _updateElement(
      elementIndex,
      updatedElement,
    );
  }

  /// Создает копию элемента с новой геометрией.
  ///
  /// Остальные свойства элемента сохраняются без изменений.
  StampifyElement _copyElementWithRect(
    StampifyElement element,
    StampifyRect rect,
  ) {
    if (element is TextElement) {
      return TextElement(
        id: element.id,
        rect: rect,
        text: element.text,
        fontSize: element.fontSize,
        fontWeight: element.fontWeight,
        textAlign: element.textAlign,
      );
    }

    return element;
  }

  /// Заменяет элемент документа и уведомляет интерфейс об изменении.
  void _updateElement(
    int elementIndex,
    StampifyElement element,
  ) {
    final elements = List<StampifyElement>.from(
      _document.elements,
    );

    elements[elementIndex] = element;

    _document = StampifyDocument(
      pageFormat: _document.pageFormat,
      orientation: _document.orientation,
      elements: elements,
    );

    notifyListeners();
  }
}