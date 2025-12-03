// Tetris piece rotation definitions
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

List<List<List<int>>> iPieces = [
  [
    [1, 1, 1, 1],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ],
  [
    [0, 0, 1, 0],
    [0, 0, 1, 0],
    [0, 0, 1, 0],
    [0, 0, 1, 0],
  ],
  [
    [0, 0, 0, 0],
    [1, 1, 1, 1],
    [0, 0, 0, 0],
  ],
  [
    [0, 1, 0, 0],
    [0, 1, 0, 0],
    [0, 1, 0, 0],
    [0, 1, 0, 0],
  ],
];

List<List<List<int>>> oPieces = [
  [
    [1, 1],
    [1, 1],
  ],
];

List<List<List<int>>> sPieces = [
  [
    [0, 1, 1],
    [1, 1, 0],
    [0, 0, 0],
  ],
  [
    [0, 1, 0],
    [0, 1, 1],
    [0, 0, 1],
  ],
  [
    [0, 0, 0],
    [0, 1, 1],
    [1, 1, 0],
  ],
  [
    [1, 0, 0],
    [1, 1, 0],
    [0, 1, 0],
  ],
];

List<List<List<int>>> zPieces = [
  [
    [1, 1, 0],
    [0, 1, 1],
    [0, 0, 0],
  ],
  [
    [0, 0, 1],
    [0, 1, 1],
    [0, 1, 0],
  ],
  [
    [0, 0, 0],
    [1, 1, 0],
    [0, 1, 1],
  ],
  [
    [0, 1, 0],
    [1, 1, 0],
    [1, 0, 0],
  ],
];

List<List<List<int>>> lPieces = [
  [
    [0, 0, 1],
    [1, 1, 1],
    [0, 0, 0],
  ],
  [
    [0, 1, 0],
    [0, 1, 0],
    [0, 1, 1],
  ],
  [
    [0, 0, 0],
    [1, 1, 1],
    [1, 0, 0],
  ],
  [
    [1, 1, 0],
    [0, 1, 0],
    [0, 1, 0],
  ],
];

List<List<List<int>>> jPieces = [
  [
    [1, 0, 0],
    [1, 1, 1],
    [0, 0, 0],
  ],
  [
    [0, 1, 1],
    [0, 1, 0],
    [0, 1, 0],
  ],
  [
    [0, 0, 0],
    [1, 1, 1],
    [0, 0, 1],
  ],
  [
    [0, 1, 0],
    [0, 1, 0],
    [1, 1, 0],
  ],
];

List<List<List<int>>> tPieces = [
  [
    [0, 1, 0],
    [1, 1, 1],
    [0, 0, 0],
  ],
  [
    [0, 1, 0],
    [0, 1, 1],
    [0, 1, 0],
  ],
  [
    [0, 0, 0],
    [1, 1, 1],
    [0, 1, 0],
  ],
  [
    [0, 1, 0],
    [1, 1, 0],
    [0, 1, 0],
  ],
];

const Map<TetrisPieceType, Color> pieceColors = {
  TetrisPieceType.I: Color(0xFF00CFFF), // light blue
  TetrisPieceType.J: Color.fromRGBO(26, 36, 255, 1), // dark blue
  TetrisPieceType.L: Color(0xFFFFA500), // orange
  TetrisPieceType.O: Color(0xFFFFEB3B), // yellow
  TetrisPieceType.S: Color(0xFF4CAF50), // green
  TetrisPieceType.Z: Color(0xFFF44336), // red
  TetrisPieceType.T: Color(0xFFE040FB), // magenta
};

// Tetris piece class and factory
enum TetrisPieceType { I, O, S, Z, L, J, T }
// enum TetrisPieceType { I }

class TetrisPiece {
  final TetrisPieceType type;
  final List<List<List<int>>> rotations;
  int _rotationIndex = 0;

  TetrisPiece(this.type, this.rotations);

  Color get color => pieceColors[type] ?? Color(0xFF00CFFF);

  List<List<int>> get shape => rotations[_rotationIndex];

  // get real width of piece
  int get width {
    final shape = rotations[_rotationIndex];
    int minCol = shape[0].length, maxCol = -1;
    for (int col = 0; col < shape[0].length; col++) {
      for (int row = 0; row < shape.length; row++) {
        if (shape[row][col] == 1) {
          if (col < minCol) minCol = col;
          if (col > maxCol) maxCol = col;
          break;
        }
      }
    }
    return (maxCol >= minCol) ? (maxCol - minCol + 1) : 0;
  }

  int get height {
    final shape = rotations[_rotationIndex];
    int minRow = shape.length, maxRow = -1;
    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          if (row < minRow) minRow = row;
          if (row > maxRow) maxRow = row;
          break;
        }
      }
    }
    return (maxRow >= minRow) ? (maxRow - minRow + 1) : 0;
  }

  int get get0NLeft {
    int max0 = 10;

    printCurrentPieceShape();

    for (int r = 0; r < shape.length; r++) {
      debugPrint(shape[r].map((e) => e.toString()).join(' '));
      int count = 0;
      for (int c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 1) {
          break;
        }
        if (shape[r][c] == 0) {
          count += 1;
        }
      }
      max0 = min(max0, count);
      debugPrint("[Max To the left]: ${count}");
    }

    return max0;
  }

  int get get0NBottom {
    int max0 = 0;

    for (int i = shape.length - 1; i > 0; i--) {
      if (shape[i].contains(1)) {
        break;
      }

      max0 += 1;
    }

    return max0;
  }

  int get rotationIndex => _rotationIndex;

  set rotationIndex(int value) {
    _rotationIndex = value % rotations.length;
    if (_rotationIndex < 0) _rotationIndex += rotations.length;
  }

  void rotateRight() {
    _rotationIndex = (_rotationIndex + 1) % rotations.length;
  }

  void rotateLeft() {
    _rotationIndex = (_rotationIndex - 1 + rotations.length) % rotations.length;
  }

  void resetRotation() {
    _rotationIndex = 0;
  }

  void printCurrentPieceShape() {
    String result = '';
    for (var row in shape) {
      result += '${row.map((e) => e.toString()).join(' ')}\n';
    }
    debugPrint('Current piece shape:\n$result');
  }

  int get numRotations => rotations.length;
}

TetrisPiece createTetrisPiece(TetrisPieceType type) {
  switch (type) {
    case TetrisPieceType.I:
      return TetrisPiece(type, iPieces);
    case TetrisPieceType.O:
      return TetrisPiece(type, oPieces);
    case TetrisPieceType.S:
      return TetrisPiece(type, sPieces);
    case TetrisPieceType.Z:
      return TetrisPiece(type, zPieces);
    case TetrisPieceType.L:
      return TetrisPiece(type, lPieces);
    case TetrisPieceType.J:
      return TetrisPiece(type, jPieces);
    case TetrisPieceType.T:
      return TetrisPiece(type, tPieces);
  }

  //   switch (type) {
  //     case TetrisPieceType.I:
  //       return TetrisPiece(type, iPieces);
  //     // default:
  //     //   break;
  //   }
}

extension TetrisPieceClone on TetrisPiece {
  TetrisPiece clone() {
    final cloned = TetrisPiece(type, rotations);
    cloned.rotationIndex = rotationIndex;
    return cloned;
  }
}
