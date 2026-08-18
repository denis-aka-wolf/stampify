// Тестовая панель

import 'package:flutter/material.dart';

import '../../core/document/element.dart';
import '../document_controller.dart';

/// Панель шаблон.
///
/// Layers рассчитан на размещение внутри docking-панели.
class LayersPanel extends StatefulWidget{
  /// Создает Inspector документа.
  const LayersPanel({
    super.key,
    required this.element,
    required this.controller,
  });

  /// Выбранный элемент документа.
  final StampifyElement? element;

  /// Контроллер документа.
  final DocumentController controller;

  @override
  State<LayersPanel> createState() => _LayersPanelState();
}

/// Состояние Inspector.
class _LayersPanelState extends State<LayersPanel> {

  /// Идентификатор элемента, для которого отображаются поля.
  // ignore: unused_field
  String? _elementId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              'Layers',
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
          'Тестовая панель Layers',
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

          _buildSectionTitle(
            context,
            'Пинг-понг',
          ),

          const SizedBox(height: 12),
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