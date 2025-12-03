import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tetris_game/screen/gameplay/components/container.dart';
import 'package:tetris_game/screen/gameplay/components/text.dart';
import 'package:tetris_game/screen/gameplay/components/tetris_pieces.dart';
import 'package:tetris_game/screen/gameplay/components/tile.dart';
import 'package:tetris_game/screen/gameplay/playfield/hold.dart';

// Preview container for next 3 tetrominoes
class PreviewComponent extends PositionComponent {
  List<TetrisPiece> nextPieces;

  PreviewComponent({
    required Vector2 position,
    required Vector2 size,
    required this.nextPieces,
    int priority = 0,
  }) : super(position: position, size: size, priority: priority);

  void updatePreview(List<TetrisPiece> newNextPieces) {
    nextPieces = newNextPieces;
  }

  @override
  void render(Canvas canvas) {
    // Vẽ background
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.7);
    final borderRadius = 12.0;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      bgPaint,
    );

    // Vẽ chữ "NEXT"
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'NEXT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, 12));

    // Vẽ 3 tetromino preview
    final double titleHeight = 18;
    final double spaceAfterTitle = 20;
    final previewBoxHeight = (size.y - (titleHeight + spaceAfterTitle)) / 3;
    final previewBoxSize = Vector2(size.x * 0.7, previewBoxHeight * 0.7);

    for (int i = 0; i < nextPieces.length && i < 3; i++) {
      final previewPos = Offset(
        (size.x - previewBoxSize.x) / 2,
        titleHeight +
            spaceAfterTitle +
            i * previewBoxHeight +
            (previewBoxHeight - previewBoxSize.y) / 2,
      );
      // Tự vẽ tetromino lên canvas tại vị trí previewPos
      _renderTetromino(canvas, nextPieces[i], previewPos, previewBoxSize);
    }
  }

  void _renderTetromino(
    Canvas canvas,
    TetrisPiece piece,
    Offset pos,
    Vector2 boxSize,
  ) {
    final shape = piece.shape;
    final color = piece.color;
    final cellSize = boxSize.x / 4.2;
    final tileSize = cellSize * 1; // scale xuống 20%
    final offset = (cellSize - tileSize) / 2;

    // Tính bounding box của tetromino (chỉ các ô có giá trị 1)
    int minRow = 4, maxRow = -1, minCol = 4, maxCol = -1;
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (r < shape.length && c < shape[r].length && shape[r][c] == 1) {
          if (r < minRow) minRow = r;
          if (r > maxRow) maxRow = r;
          if (c < minCol) minCol = c;
          if (c > maxCol) maxCol = c;
        }
      }
    }
    final pieceWidth = (maxCol - minCol + 1) * cellSize;
    final pieceHeight = (maxRow - minRow + 1) * cellSize;

    // Căn giữa tetromino trong box
    final dx = pos.dx + (boxSize.x - pieceWidth) / 2 - minCol * cellSize;
    final dy = pos.dy + (boxSize.y - pieceHeight) / 2 - minRow * cellSize;

    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (r < shape.length && c < shape[r].length && shape[r][c] == 1) {
          final x = dx + c * cellSize + offset;
          final y = dy + r * cellSize + offset;
          final tileRect = Rect.fromLTWH(x, y, tileSize, tileSize);
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
