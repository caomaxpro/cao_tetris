import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tetris_game/screen/gameplay/components/tile.dart';

Future<void> generateTestCaseTiles(
  List<List<int>> testCase,
  double cellSize,
  Component parent, {
  double yOffset = 200,
  double xOffset = 60,
  Color color = Colors.green,
  bool isLocked = true,
  bool isDisable = false,
  List<TileComponent>? tileList,
}) async {
  for (int row = 0; row < testCase.length; row++) {
    for (int col = 0; col < testCase[row].length; col++) {
      if (testCase[row][col] != 0) {
        final tile = TileComponent(
          position: Vector2(col * cellSize + xOffset, row * cellSize + yOffset),
          color: color,
          tileSize: cellSize,
          isLocked: isLocked,
          isDisable: isDisable,
        );
        await parent.add(tile);
        tileList?.add(tile);
      }
    }
  }
}
