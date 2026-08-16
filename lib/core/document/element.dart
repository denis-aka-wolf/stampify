/// Содержит базовые сущности элементов документа Stampify.
///
/// Элементы являются объектами, размещенными непосредственно
/// на странице документа. Каждый элемент имеет положение и размер,
/// заданные в миллиметрах.
///
/// В дальнейшем на основе этого класса будут созданы текстовые блоки,
/// изображения, таблицы, линии, фигуры и другие элементы редактора.
library;
import 'package:flutter/material.dart';

/// Базовый класс для всех элементов документа Stampify.
///
/// Положение и размеры элемента задаются в миллиметрах относительно
/// верхнего левого угла страницы.
///
/// [id] используется для уникальной идентификации элемента внутри
/// документа и в дальнейшем будет необходим для выделения, слоев,
/// редактирования и сохранения документа.
abstract class StampifyElement {
  /// Создает элемент документа.
  const StampifyElement({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Уникальный идентификатор элемента.
  final String id;

  /// Расстояние от левого края страницы в миллиметрах.
  final double x;

  /// Расстояние от верхнего края страницы в миллиметрах.
  final double y;

  /// Ширина элемента в миллиметрах.
  final double width;

  /// Высота элемента в миллиметрах.
  final double height;
}

/// Текстовый элемент документа.
///
/// Хранит текст и параметры его отображения.
/// Текст может содержать динамические переменные Stampify,
/// например `{{number}}`.
class TextElement extends StampifyElement {
  /// Создает текстовый элемент документа.
  const TextElement({
    required super.id,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    required this.text,
    this.fontSize = 12,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
  });

  /// Содержимое текстового элемента.
  ///
  /// В дальнейшем строка может содержать переменные,
  /// например `Счет № {{number}}`.
  final String text;

  /// Размер шрифта в пунктах.
  final double fontSize;

  /// Начертание текста.
  final FontWeight fontWeight;

  /// Выравнивание текста внутри элемента.
  final TextAlign textAlign;
}