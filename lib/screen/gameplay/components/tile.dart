import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

enum TileCollisionSide { left, right, bottom, top, none }

enum TileType { none, wall, stack }

class TileComponent extends PositionComponent with CollisionCallbacks {
  Color color;
  final double tileSize;
  bool isDisable = false;
  bool isLocked = false;
  TileType tileType = TileType.none;

  TileComponent({
    required Vector2 position,
    this.color = Colors.blue,
    this.tileSize = 24,
    this.isDisable = false,
    this.isLocked = false,
    this.tileType = TileType.none,
  }) : super(position: position, size: Vector2(tileSize, tileSize));

  List<TileCollisionSide> lastCollisionSides = [TileCollisionSide.none];

  List<TileCollisionSide> getCollisionSides() => lastCollisionSides;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  List<TileCollisionSide> checkTouchingEdge(TileComponent other) {
    final a = toRect();
    final b = other.toRect();

    final List<TileCollisionSide> collisionSides = [];

    // Chạm cạnh phải của a với cạnh trái của b
    if ((a.right == b.left) && (a.top < b.bottom) && (a.bottom > b.top)) {
      collisionSides.add(TileCollisionSide.right);
    }
    // Chạm cạnh trái của a với cạnh phải của b
    if ((a.left == b.right) && (a.top < b.bottom) && (a.bottom > b.top)) {
      collisionSides.add(TileCollisionSide.left);
    }
    // Chạm cạnh dưới của a với cạnh trên của b
    if ((a.bottom == b.top) && (a.left < b.right) && (a.right > b.left)) {
      collisionSides.add(TileCollisionSide.bottom);
    }
    // Chạm cạnh trên của a với cạnh dưới của b
    if ((a.top == b.bottom) && (a.left < b.right) && (a.right > b.left)) {
      collisionSides.add(TileCollisionSide.top);
    }

    if (collisionSides.isEmpty) {
      return [TileCollisionSide.none];
    }

    return collisionSides; // Không chạm mép
  }

  List<TileCollisionSide> detectCollisionSides(
    Set<Vector2> intersectionPoints,
  ) {
    List<TileCollisionSide> sides = [];
    for (final point in intersectionPoints) {
      if ((point.x - 0).abs() < 1e-2) sides.add(TileCollisionSide.left);
      if ((point.x - tileSize).abs() < 1e-2) sides.add(TileCollisionSide.right);
      if ((point.y - tileSize).abs() < 1e-2) {
        sides.add(TileCollisionSide.bottom);
      }
      if ((point.y - 0).abs() < 1e-2) sides.add(TileCollisionSide.top);
    }
    if (sides.isEmpty) sides.add(TileCollisionSide.none);
    return sides;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // debugPrint("[Tile]: Collision detected");

    if (other is TileComponent) {
      if (isLocked && other.isLocked) return;
      if (!isLocked && !other.isLocked) return;

      List<TileCollisionSide> sides = checkTouchingEdge(other);
      lastCollisionSides = sides;
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(0, 0, tileSize, tileSize), paint);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, tileSize, tileSize),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
