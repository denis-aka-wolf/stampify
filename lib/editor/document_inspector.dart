// Отвечает за отображение и редактирование геометрии выбранного элемента.
//
// DocumentInspector предоставляет числовые поля для изменения
// координат и размеров элемента.
//
// Все значения отображаются и вводятся в миллиметрах.
//
// Inspector не хранит собственное состояние документа.
// Все изменения передаются в DocumentController.

import 'package:flutter/material.dart';

import '../core/document/element.dart';
import '../core/document/rect.dart';
import 'document_controller.dart';

/// Верхняя панель свойств выбранного элемента.
///
/// Позволяет редактировать координаты X и Y, а также ширину и высоту.
///
/// Если элемент не выбран, Inspector отображает сообщение
/// о необходимости выбрать элемент.
class DocumentInspector extends StatefulWidget {
  /// Создает Inspector документа.
  const DocumentInspector({
    super.key,
    required this.element,
    required this.controller,
  });

  /// Выбранный элемент документа.
  final StampifyElement? element;

  /// Контроллер документа.
  final DocumentController controller;

  /// Создает состояние Inspector.
  @override
  State<DocumentInspector> createState() => _DocumentInspectorState();
}

/// Состояние Inspector.
class _DocumentInspectorState extends State<DocumentInspector> {
  late final TextEditingController _xController;
  late final TextEditingController _yController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;

  /// Идентификатор элемента, для которого сейчас отображаются поля.
  String? _elementId;

  /// Создает состояние Inspector.
  @override
  void initState() {
    super.initState();

    _xController = TextEditingController();
    _yController = TextEditingController();
    _widthController = TextEditingController();
    _heightController = TextEditingController();

    _updateControllers();
  }

  /// Освобождает контроллеры текстовых полей.
  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _widthController.dispose();
    _heightController.dispose();

    super.dispose();
  }

  /// Обновляет значения полей на основе текущего элемента.
  @override
  void didUpdateWidget(DocumentInspector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.element?.id != widget.element?.id ||
        oldWidget.element?.rect != widget.element?.rect) {
      _updateControllers();
    }
  }

  /// Синхронизирует текстовые поля с геометрией элемента.
  void _updateControllers() {
    final element = widget.element;

    if (element == null) {
      _elementId = null;
      _clearControllers();
      return;
    }

    _elementId = element.id;

    _xController.text = _format(element.rect.x);
    _yController.text = _format(element.rect.y);
    _widthController.text = _format(element.rect.width);
    _heightController.text = _format(element.rect.height);
  }

  /// Очищает все поля Inspector.
  void _clearControllers() {
    _xController.clear();
    _yController.clear();
    _widthController.clear();
    _heightController.clear();
  }

  /// Форматирует числовое значение для отображения.
  String _format(double value) {
    return value.toStringAsFixed(2);
  }

  /// Применяет значение поля к выбранному элементу.
  void _applyValue({
    required TextEditingController controller,
    required String type,
  }) {
    final element = widget.element;

    if (element == null) {
      return;
    }

    final value = double.tryParse(
      controller.text.replaceAll(',', '.'),
    );

    if (value == null) {
      _updateControllers();
      return;
    }

    final rect = element.rect;

    switch (type) {
      case 'x':
        widget.controller.updateElementRect(
          elementId: element.id,
          rect: rect.copyWith(x: value),
        );
        break;

      case 'y':
        widget.controller.updateElementRect(
          elementId: element.id,
          rect: rect.copyWith(y: value),
        );
        break;

      case 'width':
        widget.controller.resizeElement(
          elementId: element.id,
          width: value,
          height: rect.height,
        );
        break;

      case 'height':
        widget.controller.resizeElement(
          elementId: element.id,
          width: rect.width,
          height: value,
        );
        break;
    }
  }

  /// Создает числовое поле Inspector.
  Widget _buildNumberField({
    required String label,
    required String suffix,
    required TextEditingController controller,
    required String type,
  }) {
    return SizedBox(
      width: 130,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onSubmitted: (_) {
          _applyValue(
            controller: controller,
            type: type,
          );
        },
      ),
    );
  }

  /// Строит Inspector.
  @override
  Widget build(BuildContext context) {
    if (widget.element == null) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        alignment: Alignment.centerLeft,
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Text(
          'Выберите элемент',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Row(
        children: [
          _buildNumberField(
            label: 'X',
            suffix: 'mm',
            controller: _xController,
            type: 'x',
          ),
          const SizedBox(width: 8),
          _buildNumberField(
            label: 'Y',
            suffix: 'mm',
            controller: _yController,
            type: 'y',
          ),
          const SizedBox(width: 8),
          _buildNumberField(
            label: 'Width',
            suffix: 'mm',
            controller: _widthController,
            type: 'width',
          ),
          const SizedBox(width: 8),
          _buildNumberField(
            label: 'Height',
            suffix: 'mm',
            controller: _heightController,
            type: 'height',
          ),
        ],
      ),
    );
  }
}