// Содержит корневой виджет приложения Stampify.
//
// Здесь находится базовая конфигурация MaterialApp,
// тема приложения и корневой экран редактора.

import 'package:flutter/material.dart';

import 'core/core.dart';

import 'editor/document_canvas.dart';
import 'editor/document_controller.dart';

import 'editor/docking/docking.dart';
import 'editor/docking/widgets/dock_widgets.dart';
import 'editor/panels/panels.dart';

/// Корневой виджет приложения Stampify.
///
/// Отвечает за конфигурацию Flutter-приложения и создание
/// начального экрана редактора документов.
class StampifyApp extends StatelessWidget {
  /// Создает корневой виджет приложения.
  const StampifyApp({super.key});

  /// Строит конфигурацию приложения Stampify.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stampify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const StampifyEditorPage(),
    );
  }
}

/// Главный экран редактора документов Stampify.
///
/// Создает тестовый документ A4 и передает его в [DocumentCanvas].
///
/// Позже этот экран станет полноценным редактором с панелями
/// инструментов, инспектором свойств, слоями и областью документа.
class StampifyEditorPage extends StatefulWidget {
  /// Создает главный экран редактора.
  const StampifyEditorPage({super.key});

  /// Создает состояние главного экрана редактора.
  @override
  State<StampifyEditorPage> createState() => _StampifyEditorPageState();
}

/// Состояние главного экрана редактора Stampify.
class _StampifyEditorPageState extends State<StampifyEditorPage> {
  late final DocumentController _controller;
  
  late final DockingController _dockingController;
  late final DockPanelRegistry _panelRegistry;

  /// Идентификатор выбранного элемента.
  String? _selectedElementId;

  @override
  void initState() {
    super.initState();

    final document = _stampifyDocument();

    _controller = DocumentController(
      document: document,
    );

    _controller.addListener(_onDocumentChanged);

    _dockingController = DockingController(
      initialLayout: DockLayoutState.initial(),
    );

    _panelRegistry = DockPanelRegistry();

    _registerDockingPanels();

    _dockingController.addPanel(
      position: DockPosition.right,
      panelId: 'inspector',
    );

    _dockingController.addPanel(
      position: DockPosition.left,
      panelId: 'layers',
    );
  }

  /// Строит интерфейс редактора документов.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stampify'),
      ),
      body: DockLayout(
        controller: _dockingController,
        registry: _panelRegistry,
        child: DocumentCanvas(
          document: _controller.document,
          controller: _controller,
          selectedElementId: _selectedElementId,
          onElementSelected: _selectElement,
        ),
      ),
    );
  }

  /// Освобождает ресурсы контроллера при удалении экрана.
  @override
  void dispose(){
    _controller.removeListener(_onDocumentChanged);
    _controller.dispose();

    _dockingController.dispose();

    super.dispose();
  }
  
  /// Обновляет интерфейс после изменения документа.
  void _onDocumentChanged(){
    setState((){});
  }
  
  /// Выбирает элемент документа.
  void _selectElement(String? elementId) {
    setState(() {
      _selectedElementId = elementId;
    });
  }

  /// Возвращает выбранный элемент документа.
  StampifyElement? _getSelectedElement() {
    final elementId = _selectedElementId;

    if (elementId == null) {
      return null;
    }

    for (final element in _controller.document.elements) {
      if (element.id == elementId) {
        return element;
      }
    }

    return null;
  }

  /// Регистрируем новые докпанели
  void _registerDockingPanels() {
    _panelRegistry.register(
      'inspector',
      (context) {
        return InspectorPanel(
          element: _getSelectedElement(),
          controller: _controller,
        );
      },
    );

    _panelRegistry.register(
      'layers',
      (context) {
        return LayersPanel(
          element: _getSelectedElement(),
          controller: _controller,
        );
      },
    );
  }
}

// Возвращает сформированный StampifyDocument
StampifyDocument _stampifyDocument(){
  return StampifyDocument(
      pageFormat: PageFormat.a4,
      elements: [
        TextElement(
          id: 'title',
          rect: StampifyRect(x: 20, y: 20, width: 100, height: 15),
          text: 'Stampify',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        TextElement(
          id: 'subtitle',
          rect: StampifyRect(x: 20, y: 40, width: 150, height: 10),
          text: 'Система печати документов',
          fontSize: 12,
        ),
      ],
    );
}