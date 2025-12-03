import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum ContainerAlignment {
  center,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  left,
  right,
  top,
  bottom,
}

class ContainerComponent extends PositionComponent {
  final Color color;
  final double borderRadius;
  final ContainerAlignment alignment;

  ContainerComponent({
    required Vector2 position,
    required Vector2 size,
    this.color = Colors.white,
    this.borderRadius = 0,
    this.alignment = ContainerAlignment.center,
    int priority = 0,
    List<Component>? children,
  }) : super(
         position: position,
         size: size,
         priority: priority,
         children: children ?? [],
       );

  @override
  void onMount() {
    super.onMount();
    for (final child in children) {
      if (child is PositionComponent) {
        child.position = _getAlignedPosition(child.size);
      }
    }
  }

  Vector2 _getAlignedPosition(Vector2 childSize) {
    switch (alignment) {
      case ContainerAlignment.center:
        return Vector2((size.x - childSize.x) / 2, (size.y - childSize.y) / 2);
      case ContainerAlignment.topLeft:
        return Vector2(0, 0);
      case ContainerAlignment.topRight:
        return Vector2(size.x - childSize.x, 0);
      case ContainerAlignment.bottomLeft:
        return Vector2(0, size.y - childSize.y);
      case ContainerAlignment.bottomRight:
        return Vector2(size.x - childSize.x, size.y - childSize.y);
      case ContainerAlignment.left:
        return Vector2(0, (size.y - childSize.y) / 2);
      case ContainerAlignment.right:
        return Vector2(size.x - childSize.x, (size.y - childSize.y) / 2);
      case ContainerAlignment.top:
        return Vector2((size.x - childSize.x) / 2, 0);
      case ContainerAlignment.bottom:
        return Vector2((size.x - childSize.x) / 2, size.y - childSize.y);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = color;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    if (borderRadius > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
        paint,
      );
    } else {
      canvas.drawRect(rect, paint);
    }
  }
}
