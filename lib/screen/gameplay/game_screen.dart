// ignore_for_file: deprecated_member_use, unnecessary_brace_in_string_interps, unnecessary_overrides, unnecessary_this

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tetris_game/screen/bloc/bloc_bloc.dart';
import 'package:tetris_game/screen/gameplay/game_display.dart';
import 'package:tetris_game/screen/gameplay/game_world.dart';
import 'package:tetris_game/screen/multi_mode/models.dart';

double iconSize = 24;

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final blocBloc = context.read<BlocBloc>();
    // debugPrint('BlocBloc instance: $blocBloc');
    // debugPrint('BlocBloc state: ${blocBloc.state}');

    final GameWorld gameWorld = GameWorld(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      statusBarHeight: statusBarHeight,
      blocBloc: blocBloc,
    );

    return Scaffold(body: GameWidget(game: gameWorld));
  }
}
