// Содержит корневой виджет приложения Stampify.
//
// Здесь находится базовая конфигурация MaterialApp,
// тема приложения и корневой экран редактора.

import 'package:flutter/material.dart';
import 'package:stampify/core/document/rect.dart';

import 'core/document/document.dart';
import 'core/document/page_format.dart';
import 'core/document/element.dart';
import 'editor/document_canvas.dart';
import 'editor/document_controller.dart';

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

  @override
  void initState(){
    super.initState();
    final document = _StampifyDocument();
    _controller = DocumentController(document: document);
    _controller.addListener(_onDocumentChanged);
  }

  /// Освобождает ресурсы контроллера при удалении экрана.
  @override
  void dispose(){
    _controller.removeListener(_onDocumentChanged);
    _controller.dispose();
    super.dispose();
  }
  
  /// Обновляет интерфейс после изменения документа.
  void _onDocumentChanged(){
    setState((){});
  }
  
  /// Строит интерфейс редактора документов.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stampify'),
      ),
      body: DocumentCanvas(
        document: _controller.document,
        controller: _controller
      ),
    );
  }
}

// Возвращает сформированный StampifyDocument
StampifyDocument _StampifyDocument(){
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