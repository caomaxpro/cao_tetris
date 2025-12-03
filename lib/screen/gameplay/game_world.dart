import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/timer.dart';
import 'package:flame/input.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:collection/collection.dart';
import 'package:tetris_game/screen/gameplay/components/button.dart';
import 'package:tetris_game/screen/gameplay/components/svg.dart';
import 'package:tetris_game/screen/gameplay/components/tetris_pieces.dart';
import 'package:tetris_game/screen/gameplay/components/tile.dart';
import 'package:tetris_game/data.dart';
import 'package:tetris_game/helper.dart';
import 'package:tetris_game/screen/bloc/bloc_bloc.dart';
import 'package:tetris_game/screen/gameplay/game_display.dart';
import 'package:tetris_game/screen/gameplay/game_screen.dart';
import 'package:tetris_game/screen/gameplay/game_world.dart';
import 'package:tetris_game/screen/gameplay/playfield/current_piece.dart';
import 'package:tetris_game/screen/gameplay/playfield/hold.dart';
import 'package:tetris_game/screen/gameplay/playfield/playfield.dart';
import 'package:tetris_game/screen/gameplay/playfield/preview.dart';
import 'package:tetris_game/screen/gameplay/playfield/score.dart';
import 'package:tetris_game/screen/multi_mode/models.dart';
import 'package:tetris_game/test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GameWorld extends FlameGame {
  double screenWidth;
  double screenHeight;
  double statusBarHeight;
  final BlocBloc blocBloc;

  int numRows = 20;
  int numCols = 10;
  double cellSize = 22;

  GameWorld({
    this.screenWidth = 0,
    this.screenHeight = 0,
    this.statusBarHeight = 0,
    required this.blocBloc,
  });

  late GameDisplayComponent gameDisplay;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    gameDisplay = GameDisplayComponent(
      screenHeight: screenHeight,
      screenWidth: screenWidth,
      statusBarHeight: statusBarHeight,
      numCols: numCols,
      numRows: numRows,
      cellSize: cellSize,
      blocBloc: blocBloc,
    );

    await add(
      FlameBlocProvider<BlocBloc, BlocState>.value(
        value: blocBloc,
        children: [gameDisplay],
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight), bgPaint);
    super.render(canvas);
  }
}
