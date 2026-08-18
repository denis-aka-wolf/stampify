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

import '../../core/document/element.dart';
import '../document_controller.dart';

/// Панель свойств выбранного элемента.
///
/// Inspector рассчитан на размещение внутри docking-панели.
/// Поэтому элементы управления располагаются вертикально.
class InspectorPanel extends StatefulWidget{
  /// Создает Inspector документа.
  const InspectorPanel({
    super.key,
    required this.element,
    required this.controller,
  });

  /// Выбранный элемент документа.
  final StampifyElement? element;

  /// Контроллер документа.
  final DocumentController controller;

  @override
  State<InspectorPanel> createState() => _InspectorPanelState();
}

/// Состояние Inspector.
class _InspectorPanelState extends State<InspectorPanel> {
  late final TextEditingController _xController;
  late final TextEditingController _yController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;

  /// Идентификатор элемента, для которого отображаются поля.
  String? _elementId;

  @override
  void initState() {
    super.initState();

    _xController = TextEditingController();
    _yController = TextEditingController();
    _widthController = TextEditingController();
    _heightController = TextEditingController();

    _updateControllers();
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _widthController.dispose();
    _heightController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(InspectorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.element?.id != widget.element?.id ||
        oldWidget.element?.rect != widget.element?.rect) {
      _updateControllers();
    }
  }

  /// Синхронизирует поля с выбранным элементом.
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

  /// Очищает поля.
  void _clearControllers() {
    _xController.clear();
    _yController.clear();
    _widthController.clear();
    _heightController.clear();
  }

  /// Форматирует значение.
  String _format(double value) {
    return value.toStringAsFixed(2);
  }

  /// Применяет значение поля к элементу.
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
          rect: rect.copyWith(
            x: value,
          ),
        );
        break;

      case 'y':
        widget.controller.updateElementRect(
          elementId: element.id,
          rect: rect.copyWith(
            y: value,
          ),
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

  /// Создает числовое поле.
  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required String type,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'mm',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onSubmitted: (_) {
        _applyValue(
          controller: controller,
          type: type,
        );
      },
    );
  }

  /// Строит Inspector.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(
            child: widget.element == null
                ? _buildEmptyState(context)
                : _buildProperties(context),
          ),
        ],
      ),
    );
  }

  /// Заголовок Inspector.
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          children: [
            Text(
              'Inspector',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Состояние Inspector без выбранного элемента.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Выберите элемент',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  /// Свойства выбранного элемента.
  Widget _buildProperties(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle(
            context,
            'Положение',
          ),

          const SizedBox(height: 12),

          _buildNumberField(
            label: 'X',
            controller: _xController,
            type: 'x',
          ),

          const SizedBox(height: 12),

          _buildNumberField(
            label: 'Y',
            controller: _yController,
            type: 'y',
          ),

          const SizedBox(height: 24),

          _buildSectionTitle(
            context,
            'Размер',
          ),

          const SizedBox(height: 12),

          _buildNumberField(
            label: 'Width',
            controller: _widthController,
            type: 'width',
          ),

          const SizedBox(height: 12),

          _buildNumberField(
            label: 'Height',
            controller: _heightController,
            type: 'height',
          ),
        ],
      ),
    );
  }

  /// Заголовок секции Inspector.
  Widget _buildSectionTitle(
    BuildContext context,
    String title,
  ) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge,
    );
  }
}