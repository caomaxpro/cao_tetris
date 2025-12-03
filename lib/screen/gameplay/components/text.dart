import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class CustomTextComponent extends TextComponent {
  CustomTextComponent({
    required String text,
    Vector2? position,
    double fontSize = 24,
    Color color = Colors.white,
    int priority = 0,
    Anchor anchor = Anchor.topLeft,
  }) : super(
         text: text,
         position: position ?? Vector2.zero(),
         textRenderer: TextPaint(
           style: TextStyle(fontSize: fontSize, color: color),
         ),
         priority: priority,
         anchor: anchor,
       );
}
