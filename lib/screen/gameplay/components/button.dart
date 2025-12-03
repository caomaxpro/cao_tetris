import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class GameButton extends PositionComponent with TapCallbacks {
  final String label;
  final double width;
  final double height;
  final Color color;
  final VoidCallback onPressed;
  final VoidCallback onReleased;
  final VoidCallback onLongPressed;

  // Custom border
  final double borderWidth;
  final Color borderColor;
  final double borderRadius;

  // Icon
  final SpriteComponent? spriteIcon;

  GameButton({
    required this.label,
    this.onPressed = _emptyCallback,
    this.onReleased = _emptyCallback,
    this.onLongPressed = _emptyCallback,
    this.width = 100,
    this.height = 40,
    this.color = Colors.blue,
    this.borderWidth = 3,
    this.borderColor = Colors.white,
    this.borderRadius = 10,
    this.spriteIcon,
    Vector2? position,
  }) : super(
         position: position ?? Vector2.zero(),
         size: Vector2(width, height),
       );

  static void _emptyCallback() {}

  @override
  void onTapUp(TapUpEvent event) {
    onReleased();
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    onReleased(); // Gọi onReleased khi tap bị hủy
    super.onTapCancel(event);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
    super.onTapDown(event);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = Rect.fromLTWH(0, 0, width, height);

    // Draw background with border radius
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final paint = Paint()..color = color;
    canvas.drawRRect(rrect, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(rrect, borderPaint);

    // Draw sprite icon if exist
    if (spriteIcon != null) {
      spriteIcon!.position = Vector2(width / 2, height / 2);
      // spriteIcon!.size = Vector2(32, 32); // hoặc tuỳ chỉnh
      spriteIcon!.anchor = Anchor.center;
      spriteIcon!.render(canvas);
    }

    // Draw label (below icon if icon exists)
    if (label.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width);

      double labelY = (height - textPainter.height) / 2;

      textPainter.paint(
        canvas,
        Offset((width - textPainter.width) / 2, labelY),
      );
    }
  }

  // ...các hàm onTap giữ nguyên...
}
