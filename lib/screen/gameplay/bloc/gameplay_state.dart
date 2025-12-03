part of 'gameplay_bloc.dart';

@immutable
sealed class GameplayState {}

final class GameplayInitial extends GameplayState {}

// game is running - not the game but the app
final class GameplayRunning extends GameplayState {
  int score;

  // set default value for score
  GameplayRunning({this.score = 0});
}


// ignore_for_file: must_be_immutable

// part of 'bloc_bloc.dart';

// @immutable
// sealed class BlocState {}

// final class BlocInitial extends BlocState {}

// enum GameMode { single, multi }

// enum GamePlayStyle {      
//   classic, // Chơi truyền thống
//   sprint, // Đua thời gian (clear x lines nhanh nhất)
//   ultra, // Đạt điểm cao nhất trong thời gian giới hạn
//   marathon, // Chơi đến khi thua, tăng dần tốc độ
//   zen, // Chơi không giới hạn, không thua
//   battle, // PvP, gửi rác cho đối thủ
// }

// class GameSettings {
//   double musicVolume;
//   double soundVolume;
//   bool isMusicEnabled;
//   bool isSoundEnabled;

//   GameSettings({
//     this.musicVolume = 1.0,
//     this.soundVolume = 1.0,
//     this.isMusicEnabled = true,
//     this.isSoundEnabled = true,
//   });
// }

// final class BlocGameInfo extends BlocState {
//   GameMode gameMode;
//   GamePlayStyle gamePlayStyle;
//   String roomId;
//   Player player;
//   Player opponent;
//   GameMessage message;
//   GamePlay gamePlay;

//   BlocGameInfo({
//     GameMode? gameMode,
//     GamePlayStyle? gamePlayStyle,
//     String? roomId,
//     Player? player,
//     Player? opponent,
//     GamePlay? gamePlay,
//     GameMessage? message,
//   }) : gameMode = gameMode ?? GameMode.single,
//        gamePlayStyle = gamePlayStyle ?? GamePlayStyle.classic,
//        roomId = roomId ?? '',
//        player = player ?? Player(id: Uuid().v4(), name: "You"),
//        opponent = opponent ?? Player(id: '', name: ''),
//        gamePlay = gamePlay ?? GamePlay(),
//        message = message ?? GameMessage(type: '', payload: {});

//   BlocGameInfo copyWith({
//     GameMode? gameMode,
//     GamePlayStyle? gamePlayStyle,
//     String? roomId,
//     Player? player,
//     Player? opponent,
//     GamePlay? gamePlay,
//     GameMessage? message,
//   }) {
//     return BlocGameInfo(
//       gameMode: gameMode ?? this.gameMode,
//       gamePlayStyle: gamePlayStyle ?? this.gamePlayStyle,
//       roomId: roomId ?? this.roomId,
//       player: player ?? this.player,
//       opponent: opponent ?? this.opponent,
//       gamePlay: gamePlay ?? this.gamePlay,
//       message: message ?? this.message,
//     );
//   }
// }
