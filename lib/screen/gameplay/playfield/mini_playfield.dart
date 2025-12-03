import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tetris_game/screen/gameplay/models.dart';

class MiniPlayfieldComponent extends PositionComponent {
  final int numRows;
  final int numCols;
  final double cellSize;
  List<List<TileData?>> matrix;

  MiniPlayfieldComponent({
    this.numRows = 4,
    this.numCols = 4,
    this.cellSize = 16,
    required this.matrix,
    Vector2? position,
  }) : super(
         position: position ?? Vector2.zero(),
         size: Vector2(numCols * cellSize, numRows * cellSize),
       );

  @override
  void render(Canvas canvas) {
    // debugPrint("[Mini Playfield Render]: ${playfieldMatrixToString(matrix)}");

    // Vẽ background bo góc
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.7);
    final borderRadius = 12.0;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      bgPaint,
    );

    // Padding để grid nằm gọn trong background
    final padding = 6.0;
    final innerX = padding;
    final innerY = padding;
    final innerW = size.x - 2 * padding;
    final innerH = size.y - 2 * padding;

    // Tính lại cellSize cho grid nhỏ hơn
    final gridCellSize = innerW / numCols;

    // Tính kích thước thực của grid
    final gridWidth = gridCellSize * numCols;
    final gridHeight = gridCellSize * numRows;

    // Offset để căn giữa grid trong background
    final offsetX = innerX + (innerW - gridWidth) / 2;
    final offsetY = innerY + (innerH - gridHeight) / 2;

    // Vẽ grid
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1;
    for (int r = 0; r <= numRows; r++) {
      final y = offsetY + r * gridCellSize;
      canvas.drawLine(
        Offset(offsetX, y),
        Offset(offsetX + gridWidth, y),
        gridPaint,
      );
    }
    for (int c = 0; c <= numCols; c++) {
      final x = offsetX + c * gridCellSize;
      canvas.drawLine(
        Offset(x, offsetY),
        Offset(x, offsetY + gridHeight),
        gridPaint,
      );
    }

    // Tính scale và căn giữa các tile trong grid
    final tileSize = gridCellSize * 0.8;
    final tileOffset = (gridCellSize - tileSize) / 2;

    // Tìm bounding box của các tile (nếu muốn căn giữa cả khối)
    int minRow = numRows, maxRow = -1, minCol = numCols, maxCol = -1;
    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        if (matrix[r][c] != null) {
          if (r < minRow) minRow = r;
          if (r > maxRow) maxRow = r;
          if (c < minCol) minCol = c;
          if (c > maxCol) maxCol = c;
        }
      }
    }

    // Vẽ các tile đúng vị trí matrix
    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        final tile = matrix[r][c];
        if (tile != null) {
          final x = offsetX + c * gridCellSize + tileOffset;
          final y = offsetY + r * gridCellSize + tileOffset;
          final tileRect = Rect.fromLTWH(x, y, tileSize, tileSize);
          final tilePaint = Paint()..color = tile.color;
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
