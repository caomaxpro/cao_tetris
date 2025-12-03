import 'package:flame/components.dart';

final Map<String, List<Vector2>> wallKickDataJLSTZ = {
  "0-1": [
    // 0 -> R
    Vector2(0, 0),
    Vector2(-1, 0),
    Vector2(-1, 1),
    Vector2(0, -2),
    Vector2(-1, -2),
  ],
  "1-0": [
    // R -> 0
    Vector2(0, 0),
    Vector2(1, 0),
    Vector2(1, -1),
    Vector2(0, 2),
    Vector2(1, 2),
  ],
  "1-2": [
    // R -> 2
    Vector2(0, 0),
    Vector2(1, 0),
    Vector2(1, -1),
    Vector2(0, 2),
    Vector2(1, 2),
  ],
  "2-1": [
    // 2 -> R
    Vector2(0, 0),
    Vector2(-1, 0),
    Vector2(-1, 1),
    Vector2(0, -2),
    Vector2(-1, -2),
  ],
  "2-3": [
    // 2 -> L
    Vector2(0, 0),
    Vector2(1, 0),
    Vector2(1, 1),
    Vector2(0, -2),
    Vector2(1, -2),
  ],
  "3-2": [
    // L -> 2
    Vector2(0, 0),
    Vector2(-1, 0),
    Vector2(-1, -1),
    Vector2(0, 2),
    Vector2(-1, 2),
  ],
  "3-0": [
    // L -> 0
    Vector2(0, 0),
    Vector2(-1, 0),
    Vector2(-1, -1),
    Vector2(0, 2),
    Vector2(-1, 2),
  ],
  "0-3": [
    // 0 -> L
    Vector2(0, 0),
    Vector2(1, 0),
    Vector2(1, 1),
    Vector2(0, -2),
    Vector2(1, -2),
  ],
};

final Map<String, List<Vector2>> wallKickDataI = {
  "0-1": [
    Vector2(0, 0),
    Vector2(-2, 0),
    Vector2(1, 0),
    Vector2(-2, -1),
    Vector2(1, 2),
  ],
  "1-0": [
    Vector2(0, 0),
    Vector2(2, 0),
    Vector2(-1, 0),
    Vector2(2, 1),
    Vector2(-1, -2),
  ],
  "1-2": [
    Vector2(0, 0),
    Vector2(-1, 0),
    Vector2(2, 0),
    Vector2(-1, 2),
    Vector2(2, -1),
  ],
  "2-1": [
    Vector2(0, 0),
    Vector2(1, 0),
    Vector2(-2, 0),
    Vector2(1, -2),
    Vector2(-2, 1),
  ],
  "2-3": [
    Vector2(0, 0),
    Vector2(2, 0),
    Vector2(-1, 0),
    Vector2(2, 1),
    Vector2(-1, -2),
  ],
  "3-2": [
    Vector2(0, 0),
    Vector2(-2, 0),
    Vector2(1, 0),
    Vector2(-2, -1),
    Vector2(1, 2),
  ],
  "3-0": [
    Vector2(0, 0),
    Vector2(1, 0),
    Vector2(-2, 0),
    Vector2(1, -2),
    Vector2(-2, 1),
  ],
  "0-3": [
    Vector2(0, 0),
    Vector2(-1, 0),
    Vector2(2, 0),
    Vector2(-1, 2),
    Vector2(2, -1),
  ],
};

// svgs
