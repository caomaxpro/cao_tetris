// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:tetris_game/screen/gameplay/components/tetris_pieces.dart';
import 'package:tetris_game/screen/gameplay/components/tile.dart';
import 'package:tetris_game/data.dart';
import 'package:tetris_game/screen/gameplay/game_display.dart';
import 'package:tetris_game/screen/gameplay/game_world.dart';
import 'package:tetris_game/screen/gameplay/playfield/playfield.dart';

class CurrentPieceComponent extends Component with HasGameReference<GameWorld> {
  TetrisPiece? piece;
  Vector2 position = Vector2.zero();
  CurrentPieceComponent(this.piece, this.position);

  bool canHold = true;

  late GameDisplayComponent gameDisplayComponent;

  List<TileCollisionSide> collisionSides = [];

  @override
  Future<void> onLoad() async {
    gameDisplayComponent = game.gameDisplay;

    await super.onLoad();
    if (piece != null) {
      debugPrint(
        '[CurrentPieceComponent] onLoad: piece=${piece!.type}, position=$position',
      );
    }
  }

  bool isCurrentPieceTile(int gridY, int gridX, List<List<int>> shape) {
    int offsetY = gridY - position.y.toInt();
    int offsetX = gridX - position.x.toInt();
    if (offsetY >= 0 &&
        offsetY < shape.length &&
        offsetX >= 0 &&
        offsetX < shape[0].length) {
      return shape[offsetY][offsetX] == 1;
    }
    return false;
  }

  void holdPiece() {
    final game = gameDisplayComponent;

    if (!canHold || piece == null) return;

    piece!.rotationIndex = 0;

    if (game.heldPiece == null) {
      game.heldPiece = piece!;
      game.playField?.spawnNewPiece();
    } else {
      final temp = piece!;
      piece = game.heldPiece;
      game.heldPiece = temp;
      position = Vector2(3, -1);
      if (piece!.type == TetrisPieceType.O) {
        position = Vector2(4, -1);
      }
    }

    canHold = false;

    if (game.holdComponent != null) {
      game.holdComponent?.updateHeldPiece(game.heldPiece);
    }
  }

  void movePiece(int dx, int dy) {
    debugPrint("[Side Collisions Before Moving]: ${collisionSides.toString()}");

    if ((dx < 0 && collisionSides.contains(TileCollisionSide.left)) ||
        (dx > 0 && collisionSides.contains(TileCollisionSide.right)) ||
        (dy > 0 && collisionSides.contains(TileCollisionSide.bottom))) {
      debugPrint(
        "[Side Collisions Before Moving]: ${collisionSides.toString()}",
      );

      return;
    }

    final game = gameDisplayComponent;

    // debugPrint("movePiece called: dx=$dx, dy=$dy, before position=$position");

    PlayfieldComponent? playfield = game.playField;

    if (piece == null) return;

    final previewPosition = Vector2(position.x + dx, position.y + dy);

    debugPrint("[Preview positions]: $previewPosition");

    position = previewPosition;

    collisionSides = playfield!.checkTileCollisions();

    debugPrint("[Collision Sides]: ${collisionSides.toList()}");

    if (collisionSides.contains(TileCollisionSide.bottom)) {
      playfield.startLockCountdown();
      // playfield.isLockCountdown = true;
      playfield.moves++;
      return;
    }

    playfield.isLockCountdown = false;
    playfield.lockTimer.stop();
    playfield.moves = 0;
    // playfield.moves++;
  }

  void rotatePiece({required bool isRight}) {
    final game = gameDisplayComponent;

    PlayfieldComponent? playfield = game.playField;

    if (playfield == null) return;
    if (piece == null) return;
    final oldRotation = piece!.rotationIndex;
    final oldPosition = position.clone();

    final from = oldRotation;
    final to = isRight ? (from + 1) % 4 : (from - 1 + 4) % 4;

    if (isRight) {
      piece!.rotateRight();
    } else {
      piece!.rotateLeft();
    }

    if (playfield.checkOverlapCollision(position, piece!)) {
      bool kicked = false;
      List<Vector2> offsets = [Vector2(0, 0)];

      if ([
        TetrisPieceType.L,
        TetrisPieceType.J,
        TetrisPieceType.S,
        TetrisPieceType.T,
        TetrisPieceType.Z,
      ].contains(piece!.type)) {
        offsets = wallKickDataJLSTZ["$from-$to"] ?? [Vector2(0, 0)];
      }

      if (piece!.type == TetrisPieceType.I) {
        offsets = wallKickDataI["$from-$to"] ?? [Vector2(0, 0)];
      }

      for (final offset in offsets) {
        final testPosition = oldPosition + offset;
        if (!playfield.checkOverlapCollision(testPosition, piece!)) {
          position = testPosition;
          kicked = true;
          break;
        }
      }

      if (!kicked) {
        piece!.rotationIndex = oldRotation;
        position = oldPosition;
      }
    }

    collisionSides = playfield.checkTileCollisions();

    debugPrint(
      "[Side Collisions After Rotation]: ${collisionSides.toString()}",
    );

    if (collisionSides.contains(TileCollisionSide.none) ||
        collisionSides.contains(TileCollisionSide.left) ||
        collisionSides.contains(TileCollisionSide.right)) {
      playfield.isLockCountdown = false;
      playfield.lockTimer.stop();
      playfield.moves = 0;
    } else if (collisionSides.contains(TileCollisionSide.bottom)) {
      playfield.startLockCountdown();
      playfield.moves++;
    } else {
      playfield.isLockCountdown = true;
      playfield.lockTimer.stop();
      playfield.moves++;
    }
  }

  void hardDrop() {
    final game = gameDisplayComponent;

    if (piece == null) return;

    while (true) {
      final testPosition = Vector2(position.x, position.y + 1);

      if (game.playField!.checkOverlapCollision(testPosition, piece!)) {
        break;
      }
      position.y++;
    }

    game.playField!.forceLockPiece();
  }

  void resetPosition(Vector2 newPosition) {
    position = newPosition.clone();
  }

  void removeCurrentPiece() {
    piece = null;
  }

  void drawCurrentPiece(Canvas canvas, double cellSize) {
    if (piece == null) return;
    final shape = piece!.shape;
    final color = piece!.color;

    for (int r = 0; r < shape.length; r++) {
      for (int c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 1) {
          final tileX = (position.x + c) * cellSize;
          final tileY = (position.y + r) * cellSize;
          final tileRect = Rect.fromLTWH(tileX, tileY, cellSize, cellSize);
          final tilePaint = Paint()..color = color;
          canvas.drawRect(tileRect, tilePaint);

          final borderPaint = Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
          canvas.drawRect(tileRect, borderPaint);
        }
      }
    }
  }
}
