import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tetris_game/screen/gameplay/components/tetris_pieces.dart';
import 'package:tetris_game/screen/gameplay/components/tile.dart';
import 'package:tetris_game/screen/gameplay/game_screen.dart';
import 'package:tetris_game/screen/gameplay/game_world.dart';

class GhostPieceComponent extends Component with HasGameReference<GameWorld> {
  TetrisPiece? piece;
  Vector2 position = Vector2.zero();
  List<TileComponent> tiles = [];

  void updateGhost(TetrisPiece sourcePiece, Vector2 ghostPosition) {
    piece = sourcePiece.clone();
    piece!.rotationIndex = sourcePiece.rotationIndex;
    position = ghostPosition.clone();

    final cellSize = game.cellSize;
    final shape = piece!.shape;
    int tileIndex = 0;

    for (int r = 0; r < shape.length; r++) {
      for (int c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 1) {
          final tileY = (position.y + r) * cellSize;
          final tileX = (position.x + c) * cellSize;

          if (tileIndex < tiles.length) {
            // Update existing tile
            tiles[tileIndex].position.setValues(tileX, tileY);
            tiles[tileIndex].color = Colors.grey.withOpacity(0.4);
          } else {
            // Add new tile if needed
            final tile = TileComponent(
              position: Vector2(tileX, tileY),
              color: Colors.grey.withOpacity(0.4),
              tileSize: cellSize,
              isLocked: false,
              isDisable: false,
            );
            if (parent != null) {
              parent!.add(tile);
            }
            tiles.add(tile);
          }
          tileIndex++;
        }
      }
    }

    // Remove excess tiles
    while (tiles.length > tileIndex) {
      tiles.removeLast().removeFromParent();
    }
  }

  void removeGhost() {
    for (final tile in tiles) {
      tile.removeFromParent();
    }
    tiles.clear();
    piece = null;
  }
}
