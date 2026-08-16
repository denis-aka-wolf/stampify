// Содержит корневой виджет приложения Stampify.
//
// Здесь находится базовая конфигурация MaterialApp,
// тема приложения и корневой экран редактора.

import 'package:flutter/material.dart';

import 'core/document/document.dart';
import 'core/document/page_format.dart';
import 'editor/document_canvas.dart';
import 'core/document/element.dart';

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
class StampifyEditorPage extends StatelessWidget {
  /// Создает главный экран редактора.
  const StampifyEditorPage({super.key});

  /// Строит интерфейс редактора документов.
  @override
  Widget build(BuildContext context) {
    const document = StampifyDocument(
      pageFormat: PageFormat.a4,
      elements: [
        TextElement(
          id: 'title',
          x: 20,
          y: 20,
          width: 100,
          height: 15,
          text: 'Stampify',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        TextElement(
          id: 'subtitle',
          x: 20,
          y: 40,
          width: 150,
          height: 10,
          text: 'Система печати документов',
          fontSize: 12,
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stampify'),
      ),
      body: DocumentCanvas(
        document: document,
      ),
    );
  }
}