import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:tetris_game/screen/gameplay/components/button.dart';
import 'package:tetris_game/screen/gameplay/game_screen.dart';
import 'package:tetris_game/screen/gameplay/game_world.dart';

class GameOverDialog extends PositionComponent
    with HasGameReference<GameWorld> {
  final int score;
  final VoidCallback onPlayAgain;
  final VoidCallback onMenu;

  GameOverDialog({
    required this.score,
    required this.onPlayAgain,
    required this.onMenu,
    Vector2? position,
    Vector2? size,
  }) : super(
         position: position ?? Vector2(35, 150),
         size: size ?? Vector2(180, 220),
       );

  @override
  Future<void> onLoad() async {
    position.x = (game.screenWidth - (size?.x ?? 180)) / 2;
    position.y = (game.screenHeight - (size?.y ?? 220)) / 2;

    add(
      RectangleComponent(
        position: Vector2.zero(),
        size: size,
        paint: Paint()..color = Colors.black.withOpacity(1),
        priority: priority,
      ),
    );

    final double dialogHeight = size.y;
    final double itemHeight = 36;
    final double spacing = 18;

    // Tính tổng chiều cao các thành phần
    final double totalContentHeight =
        32 + // Game Over text height
        spacing +
        22 + // Score text height
        spacing +
        itemHeight + // Play Again button
        spacing +
        itemHeight; // Menu button

    // Tính vị trí y bắt đầu để canh giữa
    final double startY = (dialogHeight - totalContentHeight) / 2;

    // Các vị trí y cho từng thành phần
    final double gameOverY = startY;
    final double scoreY = gameOverY + 32 + spacing;
    final double playAgainY = scoreY + 22 + spacing;
    final double menuY = playAgainY + itemHeight + spacing;

    add(
      TextComponent(
        text: 'Game Over',
        position: Vector2(size.x / 2, gameOverY),
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 32,
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        priority: priority,
      ),
    );

    add(
      TextComponent(
        text: 'Score: $score',
        position: Vector2(size.x / 2, scoreY),
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        priority: priority,
      ),
    );

    GameButton playButton = GameButton(
      label: 'Play Again',
      position: Vector2(size.x / 2, playAgainY + 20),
      width: 140,
      height: itemHeight,
      color: Colors.greenAccent,
      borderColor: Colors.black,
      borderWidth: 2,
      borderRadius: 8,
      onPressed: onPlayAgain,
      // anchor: Anchor.topCenter,
    );

    GameButton menuButton = GameButton(
      label: 'Menu',
      position: Vector2(size.x / 2, menuY + 20),
      width: 140,
      height: itemHeight,
      color: Colors.orange,
      borderColor: Colors.black,
      borderWidth: 2,
      borderRadius: 8,
      onPressed: onMenu,
      // anchor: Anchor.topCenter,
    );

    playButton.priority = 2;
    playButton.anchor = Anchor.center;

    menuButton.priority = 2;
    menuButton.anchor = Anchor.center;

    add(playButton);
    add(menuButton);
  }
}
