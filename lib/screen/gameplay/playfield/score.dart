import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tetris_game/screen/gameplay/components/container.dart';
import 'package:tetris_game/screen/gameplay/components/text.dart';

class ScoreComponent extends PositionComponent {
  int score;

  ScoreComponent({
    required Vector2 position,
    required Vector2 size,
    required this.score,
    int priority = 0,
  }) : super(position: position, size: size, priority: priority);

  void updateScore(int newScore) {
    score = newScore;
    final scoreText = children.whereType<CustomTextComponent>().last;
    scoreText.text = '$score';
  }

  @override
  Future<void> onLoad() async {
    // Container background
    add(
      ContainerComponent(
        position: Vector2.zero(),
        size: size,
        color: Colors.black.withOpacity(0.7),
        borderRadius: 12,
      ),
    );

    // "SCORE" text
    add(
      CustomTextComponent(
        text: 'SCORE',
        position: Vector2(size.x / 2, 12),
        fontSize: 18,
        color: Colors.white,
        anchor: Anchor.topCenter,
      ),
    );

    // Score value
    add(
      CustomTextComponent(
        text: '$score',
        position: Vector2(size.x / 2, size.y / 2 + 2),
        fontSize: 20,
        color: Colors.yellowAccent,
        anchor: Anchor.topCenter,
      ),
    );
  }
}
