part of 'bloc_bloc.dart';

@immutable
sealed class BlocEvent {}

final class BlocConnect extends BlocEvent {}

final class BlocDisconnect extends BlocEvent {}

final class BlocSendMessage extends BlocEvent {
  final String message;
  BlocSendMessage(this.message);
}

final class BlocReceiveMessage extends BlocEvent {
  final dynamic message;
  BlocReceiveMessage(this.message);
}

final class BlocFindGame extends BlocEvent {
  final String playerId;
  final String playerName;
  final String mode;
  BlocFindGame({
    required this.playerId,
    required this.playerName,
    required this.mode,
  });
}

final class BlocAcceptMatch extends BlocEvent {
  final String roomId;
  final String playerId;
  final bool accept;
  BlocAcceptMatch({
    required this.roomId,
    required this.playerId,
    required this.accept,
  });
}

final class BlocDeclineMatch extends BlocEvent {}

final class BlocThrowTrash extends BlocEvent {
  final String roomId;
  final String playerId;
  final int lines;
  BlocThrowTrash({
    required this.roomId,
    required this.playerId,
    required this.lines,
  });
}

final class BlocUpdateGameState extends BlocEvent {
  final String? roomId;
  final Player? player;
  final Player? opponent;
  final GameMessage? message;
  final GameMode? gameMode;
  final GamePlayStyle? gamePlayStyle;
  final GamePlay? gamePlay;
  final GameSettings? gameSettings;

  BlocUpdateGameState({
    this.roomId,
    this.player,
    this.opponent,
    this.message,
    this.gameMode,
    this.gamePlayStyle,
    this.gamePlay,
    this.gameSettings,
  });
}
