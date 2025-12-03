import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:tetris_game/screen/multi_mode/models.dart';
import 'package:tetris_game/websocket/websocket.dart';
import 'package:uuid/uuid.dart';

import '../multi_mode/models.dart';

part 'bloc_event.dart';
part 'bloc_state.dart';

class BlocBloc extends Bloc<BlocEvent, BlocState> {
  WebSocketService? wsService;
  Player? player;
  Player? opponent;
  String? roomId;

  BlocBloc() : super(BlocGameInfo()) {
    on<BlocConnect>((event, emit) {
      wsService = WebSocketService('ws://192.168.12.102:3000');
      wsService!.listen((message) {
        debugPrint('Received message: $message');
        add(BlocReceiveMessage(message));
      });
      emit(BlocGameInfo());
    });

    on<BlocDisconnect>((event, emit) {
      wsService!.dispose();
      emit(BlocInitial());
    });

    on<BlocSendMessage>((event, emit) {
      wsService!.send(event.message);
    });

    on<BlocReceiveMessage>((event, emit) {
      debugPrint("[BlocReceiveMessage]: update state");
      final msg = GameMessage.fromJson(event.message);

      emit((state as BlocGameInfo).copyWith(message: msg));

      // if (state is BlocGameInfo) {
      //   emit((state as BlocGameInfo).copyWith(message: msg));
      // } else {
      //   emit(BlocGameInfo(message: msg));
      // }
    });

    on<BlocUpdateGameState>((event, emit) {
      if (state is BlocGameInfo) {
        emit(
          (state as BlocGameInfo).copyWith(
            gameMode: event.gameMode,
            gamePlayStyle: event.gamePlayStyle,
            roomId: event.roomId,
            player: event.player,
            opponent: event.opponent,
            message: event.message,
            gamePlay: event.gamePlay,
            gameSettings: event.gameSettings,
          ),
        );
      } else {
        emit(
          BlocGameInfo(
            gameMode: event.gameMode,
            gamePlayStyle: event.gamePlayStyle,
            roomId: event.roomId ?? '',
            player: event.player ?? Player(id: '', name: ''),
            opponent: event.opponent ?? Player(id: '', name: ''),
            message:
                event.message ??
                GameMessage(type: GameMessageType.none.name, payload: {}),
            gamePlay: event.gamePlay ?? GamePlay(),
            gameSettings: event.gameSettings ?? GameSettings(),
          ),
        );
      }
    });
  }

  @override
  Future<void> close() {
    wsService?.dispose();
    return super.close();
  }
}
