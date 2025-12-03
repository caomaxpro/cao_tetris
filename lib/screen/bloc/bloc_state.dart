// ignore_for_file: must_be_immutable

part of 'bloc_bloc.dart';

@immutable
sealed class BlocState {}

final class BlocInitial extends BlocState {}

enum GameMode { single, multi }

enum GamePlayStyle {
  classic, // Chơi truyền thống
  sprint, // Đua thời gian (clear x lines nhanh nhất)
  ultra, // Đạt điểm cao nhất trong thời gian giới hạn
  marathon, // Chơi đến khi thua, tăng dần tốc độ
  zen, // Chơi không giới hạn, không thua
  battle, // PvP, gửi rác cho đối thủ
}

final class BlocGameInfo extends BlocState {
  GameMode gameMode;
  GamePlayStyle gamePlayStyle;
  String roomId;
  Player player;
  Player opponent;
  GameMessage message;
  GamePlay gamePlay;
  GameSettings gameSettings;

  BlocGameInfo({
    GameMode? gameMode,
    GamePlayStyle? gamePlayStyle,
    String? roomId,
    Player? player,
    Player? opponent,
    GamePlay? gamePlay,
    GameSettings? gameSettings,
    GameMessage? message,
  }) : gameMode = gameMode ?? GameMode.multi,
       gamePlayStyle = gamePlayStyle ?? GamePlayStyle.battle,
       roomId = roomId ?? '',
       player = player ?? Player(id: Uuid().v4(), name: "You"),
       opponent = opponent ?? Player(id: '', name: ''),
       gamePlay = gamePlay ?? GamePlay(),
       gameSettings = gameSettings ?? GameSettings(),
       message =
           message ?? GameMessage(type: GameMessageType.none.name, payload: {});

  BlocGameInfo copyWith({
    GameMode? gameMode,
    GamePlayStyle? gamePlayStyle,
    String? roomId,
    Player? player,
    Player? opponent,
    GamePlay? gamePlay,
    GameSettings? gameSettings,
    GameMessage? message,
  }) {
    return BlocGameInfo(
      gameMode: gameMode ?? this.gameMode,
      gamePlayStyle: gamePlayStyle ?? this.gamePlayStyle,
      roomId: roomId ?? this.roomId,
      player: player ?? this.player,
      opponent: opponent ?? this.opponent,
      gamePlay: gamePlay ?? this.gamePlay,
      gameSettings: gameSettings ?? this.gameSettings,
      message: message ?? this.message,
    );
  }
}
