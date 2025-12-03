import 'dart:ui';

import 'package:flame_svg/flame_svg.dart';
import 'package:flame/components.dart';

class GameSvgIcon extends SvgComponent {
  GameSvgIcon({
    required Svg super.svg,
    double size = 24,
    Vector2? position,
    Anchor super.anchor = Anchor.center,
    super.paint,
  }) : super(size: Vector2(size, size), position: position ?? Vector2.zero());
}
