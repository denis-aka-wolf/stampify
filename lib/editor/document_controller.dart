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

    final updatedElement = _moveElement(
      element,
      x: x,
      y: y,
    );

    final elements = List<StampifyElement>.from(
      _document.elements,
    );

    elements[elementIndex] = updatedElement;

    _document = StampifyDocument(
      pageFormat: _document.pageFormat,
      orientation: _document.orientation,
      elements: elements,
    );

    notifyListeners();
  }

  /// Создает новую версию элемента с измененными координатами.
  ///
  /// Этот метод сохраняет остальные свойства элемента без изменений.
  StampifyElement _moveElement(
    StampifyElement element, {
    required double x,
    required double y,
  }) {
    if (element is TextElement) {
      return TextElement(
        id: element.id,
        x: x,
        y: y,
        width: element.width,
        height: element.height,
        text: element.text,
        fontSize: element.fontSize,
        fontWeight: element.fontWeight,
        textAlign: element.textAlign,
      );
    }

    return element;
  }
}