import 'dart:convert';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:tetris_game/screen/gameplay/components/tetris_pieces.dart';
import 'package:tetris_game/screen/gameplay/components/tile.dart';
import 'package:tetris_game/data.dart';
import 'package:tetris_game/helper.dart';
import 'package:tetris_game/screen/bloc/bloc_bloc.dart';
import 'package:tetris_game/screen/gameplay/game_display.dart';
import 'package:tetris_game/screen/gameplay/game_screen.dart';
import 'package:tetris_game/screen/gameplay/game_world.dart';
import 'package:tetris_game/screen/gameplay/gameover_dialog.dart';
import 'package:tetris_game/screen/gameplay/models.dart';
import 'package:tetris_game/screen/gameplay/playfield/ghost_piece.dart';
import 'package:tetris_game/screen/gameplay/playfield/current_piece.dart';
import 'package:tetris_game/screen/multi_mode/models.dart';

class PlayfieldComponent extends PositionComponent
    with
        HasGameReference<GameWorld>,
        FlameBlocReader<BlocBloc, BlocState>,
        FlameBlocListenable<BlocBloc, BlocState> {
  PlayfieldComponent({Vector2? position, Vector2? size})
    : super(
        position: position ?? Vector2(25, 195),
        size: size ?? Vector2(250, 500),
      );

  CurrentPieceComponent? currentPieceComponent;

  late List<List<TileData?>> playfieldMatrix;
  List<TileCollisionSide> collisionSides = [];

  // piece lock system
  late Timer lockTimer;
  int moves = 0;
  double lockInterval = 0.5;
  bool isLockCountdown = false;

  bool isHold = false;
  late Timer gravityTimer;
  late GameOverDialog gameOverDialog;
  late GameDisplayComponent gameDisplayComponent;

  BlocGameInfo? get gameInfo =>
      bloc.state is BlocGameInfo ? bloc.state as BlocGameInfo : null;

  GameMessage? _lastMessage;

  @override
  void onNewState(BlocState state) {
    debugPrint('[FlameBlocListenable] New state: $state');
    if (state is BlocGameInfo) {
      final message = state.message;
      // Chỉ xử lý khi message thay đổi và type hợp lệ
      if (message != _lastMessage &&
          (message.type == "control_game" || message.type == "gameover")) {
        _lastMessage = message;

        debugPrint(
          '[FlameBlocListenable] BlocGameInfo received: ${message.type}',
        );
        final type = message.type;
        final payload = message.payload;

        if (type == "control_game") {
          switch (payload["action"]) {
            case "attack":
              int lines = payload["lines"] ?? 0;
              throwTrashLines(lines);
              break;
            case "update_playfield":
              debugPrint("[Playfield State]: ${payload["playfield"]}");
              final gamePlay = state.gamePlay.copyWith(
                playfieldMatrix: playfieldMatrixFromString(
                  payload["playfield"],
                ),
              );
              bloc.add(BlocUpdateGameState(gamePlay: gamePlay));
              break;
            case "update_piece_queue":
              break;
            default:
              break;
          }
        } else if (type == "gameover") {
          // Xử lý gameover ở đây nếu cần
        }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update gravity timer
    gravityTimer.update(dt);

    // Lock countdown logic
    if (isLockCountdown) {
      lockTimer.update(dt);
      if (moves >= 15 || lockTimer.finished) {
        // debugPrint("lock tetromeno");
        forceLockPiece();
      }
    }
  }

  void handleThrowTrash() {
    if (gameInfo == null) {
      debugPrint('Bloc state is not BlocGameInfo');
      return;
    }
    final player = gameInfo!.player;
    final roomId = gameInfo!.roomId;
    final garbageLines = 0;

    final ticket = {
      'type': GameMessageType.control_game,
      'payload': {
        'action': GameControl.attack,
        'room_id': roomId,
        'player_id': player.id,
        'lines': garbageLines,
      },
    };
    bloc.add(BlocSendMessage(jsonEncode(ticket)));
  }

  Future<void> addGameoverDialog() async {
    final gameDisplay = game.gameDisplay;

    gameOverDialog = GameOverDialog(
      score: gameDisplay.score,
      onPlayAgain: () async {
        game.children.whereType<GameOverDialog>().forEach((dialog) {
          dialog.removeFromParent();
        });

        debugPrint("[Game Over]: Trying to remove the dialog");
        debugPrint("[Game Over]: Removed successfully");
        await clearPlayField();
        await loadPlayField();
      },
      size: Vector2(game.screenWidth, game.screenHeight),
      onMenu: () {},
    );
    gameOverDialog.priority = 2;
    gameOverDialog.x = 0;
    gameOverDialog.y = 0;

    game.add(gameOverDialog);
    game.processLifecycleEvents();
  }

  void forceLockPiece() async {
    // List<TileCollisionSide> collisionSide = checkTileCollisions();

    // if (collisionSide.contains(TileCollisionSide.bottom)) {

    // }

    // Lock piece vào matrix
    final shape = currentPieceComponent!.piece!.shape;
    final color = currentPieceComponent!.piece!.color;
    for (int r = 0; r < shape.length; r++) {
      for (int c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 1) {
          int gridY = currentPieceComponent!.position.y.toInt() + r;
          int gridX = currentPieceComponent!.position.x.toInt() + c;
          if (gridY >= 0 &&
              gridY < game.numRows &&
              gridX >= 0 &&
              gridX < game.numCols) {
            playfieldMatrix[gridY][gridX] = TileData(color: color);
          }
        }
      }
    }

    // Remove current piece tiles
    await clearLine();
    isLockCountdown = false;
    lockTimer.stop();
    moves = 0;
    collisionSides = [];
    spawnNewPiece();

    sendPlayfieldState();
  }

  void printBlocStateContent() {
    final state = bloc.state;
    debugPrint("[Bloc State]: ${state.runtimeType}");
    debugPrint("[Bloc State]: $state");

    if (state is BlocGameInfo) {
      debugPrint("[Bloc State] gameMode: ${state.gameMode}");
      debugPrint("[Bloc State] gamePlayStyle: ${state.gamePlayStyle}");
      debugPrint("[Bloc State] roomId: ${state.roomId}");
      debugPrint("[Bloc State] player: ${state.player}");
      debugPrint("[Bloc State] opponent: ${state.opponent}");
      debugPrint("[Bloc State] message: ${state.message}");
      debugPrint("[Bloc State] gamePlay: ${state.gamePlay}");
      debugPrint(
        "[Bloc State] playfieldMatrix: ${state.gamePlay.playfieldMatrix}",
      );
    }
  }

  void sendPlayfieldState() {
    debugPrint("[To Server]: Sending playfield state to server");
    // printBlocStateContent();

    if (bloc.state is BlocGameInfo) {
      final state = bloc.state as BlocGameInfo;

      //   debugPrint("[To Server]: ${state.gameMode}");

      if (state.gameMode == GameMode.multi) {
        // GamePlay gamePlay = state.gamePlay.copyWith(playfieldMatrix: );

        // debugPrint("[To Server]: Sending playfield state to server");

        Ticket ticket = Ticket(
          type: GameMessageType.control_game.name,
          payload: {
            'action': 'update_playfield',
            'room_id': state.roomId,
            'player_id': state.player.id,
            'opponent_id': state.opponent.id,
            'playfield': playfieldMatrixToString(playfieldMatrix),
          },
        );

        bloc.add(BlocSendMessage(ticket.toString()));
      }
    }
  }

  Future<void> playAgain() async {
    // Implementation here
  }

  void startLockCountdown() {
    if (isLockCountdown) return;
    lockTimer = Timer(lockInterval);
    lockTimer.start();
    isLockCountdown = true;
  }

  int calculateScore(int numLines, int level) {
    switch (numLines) {
      case 1:
        return 100 * level;
      case 2:
        return 300 * level;
      case 3:
        return 500 * level;
      case 4:
        return 800 * level;
      default:
        return 0;
    }
  }

  void handleLineClear(int numLines) {
    final game = gameDisplayComponent;

    game.linesCleared += numLines;
    int scoreGained = calculateScore(numLines, game.level);
    game.score = min(game.score + scoreGained, 999999);
    game.scoreComponent?.updateScore(game.score);

    while (game.linesCleared >= game.level * game.linesPerLevel) {
      game.linesCleared -= game.level * game.linesPerLevel;
      game.level++;
      gravityTimer.limit = max(0.08, 0.8 - 0.07 * (game.level - 1));
    }
  }

  bool checkOverlapCollision(Vector2 testPosition, TetrisPiece piece) {
    final shape = piece.shape;

    for (int r = 0; r < shape.length; r++) {
      for (int c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 1) {
          int gridY = testPosition.y.toInt() + r;
          int gridX = testPosition.x.toInt() + c;

          // Check boundaries
          if (gridX < 0 || gridX >= game.numCols || gridY >= game.numRows) {
            return true;
          }

          // Check stacked tiles in matrix
          if (gridY >= 0 && playfieldMatrix[gridY][gridX] != null) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<void> clearPlayField() async {
    removeAll(children);
    playfieldMatrix = List.generate(
      game.numRows,
      (_) => List.filled(game.numCols, null),
    );
    // wallTiles.clear();

    gravityTimer.stop();
    lockTimer.stop();
  }

  Future<void> loadPlayField() async {
    // stop timers first

    // if (bloc.state is BlocGameInfo) {
    //   _lastMessage = (bloc.state as BlocGameInfo).message;
    // }

    final game = gameDisplayComponent;
    final numRows = game.numRows;
    final numCols = game.numCols;
    final cellSize = game.cellSize;

    // Initialize matrix
    playfieldMatrix = List.generate(numRows, (_) => List.filled(numCols, null));

    game.score = 0;
    game.level = 1;
    game.linesCleared = 0;
    game.linesPerLevel = 10;

    lockTimer = Timer(0);

    // ghostPieceComponent = GhostPieceComponent();
    // add(ghostPieceComponent!);

    await spawnNewPiece();

    gravityTimer = Timer(
      0.8,
      // repeat: true,
      autoStart: false,
      onTick: () {
        debugPrint("[Gravity Timer]: Trigger");
        currentPieceComponent!.movePiece(0, 1);
      },
    );

    // gravityTimer.start();
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    gameDisplayComponent = game.gameDisplay;
    loadPlayField();
  }

  // GhostPieceComponent? ghostPieceComponent;

  bool isGameOver() {
    // Check if newly spawned piece overlaps with existing stack
    // This is checked right after spawning in spawnNewPiece()

    TetrisPiece? piece = currentPieceComponent!.piece;

    if (piece == null) return false;

    return checkOverlapCollision(currentPieceComponent!.position, piece);
  }

  List<TileCollisionSide> checkTileCollisions() {
    TetrisPiece? piece = currentPieceComponent!.piece;

    final shape = piece!.shape;
    List<TileCollisionSide> result = [];

    for (int r = 0; r < shape.length; r++) {
      for (int c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 1) {
          int gridY = currentPieceComponent!.position.y.toInt() + r;
          int gridX = currentPieceComponent!.position.x.toInt() + c;
          List<TileCollisionSide> sides = [];

          // Check left
          int leftX = gridX - 1;
          if (leftX < 0 ||
              (gridY >= 0 &&
                  leftX >= 0 &&
                  leftX < game.numCols &&
                  playfieldMatrix[gridY][leftX] != null &&
                  !currentPieceComponent!.isCurrentPieceTile(
                    gridY,
                    leftX,
                    shape,
                  ))) {
            sides.add(TileCollisionSide.left);
          }

          // Check right
          int rightX = gridX + 1;
          if (rightX >= game.numCols ||
              (gridY >= 0 &&
                  rightX >= 0 &&
                  rightX < game.numCols &&
                  playfieldMatrix[gridY][rightX] != null &&
                  !currentPieceComponent!.isCurrentPieceTile(
                    gridY,
                    rightX,
                    shape,
                  ))) {
            sides.add(TileCollisionSide.right);
          }

          // Check bottom
          int bottomY = gridY + 1;
          if (bottomY >= game.numRows ||
              (bottomY >= 0 &&
                  gridX >= 0 &&
                  gridX < game.numCols &&
                  playfieldMatrix[bottomY][gridX] != null &&
                  !currentPieceComponent!.isCurrentPieceTile(
                    bottomY,
                    gridX,
                    shape,
                  ))) {
            sides.add(TileCollisionSide.bottom);
          }

          if (sides.isEmpty) sides.add(TileCollisionSide.none);
          result += sides;
        }
      }
    }
    // debugPrint("====================================");
    return result;
  }

  // Helper to check if a position is part of currentPiece
  void debugPrintMatrix() {
    for (int r = 0; r < playfieldMatrix.length; r++) {
      String rowStr = playfieldMatrix[r]
          .map((cell) => cell == null ? '.' : '#')
          .join(' ');
      debugPrint('Row $r: $rowStr');
    }
    debugPrint("====================================");
  }

  Future<void> clearLine() async {
    // debugPrintMatrix();

    List<int> rowsToClear = [];
    for (int i = 0; i < playfieldMatrix.length; i++) {
      int filledCount = playfieldMatrix[i].where((cell) => cell != null).length;
      if (filledCount == game.numCols) {
        rowsToClear.add(i);
      }
    }

    // debugPrint("[Rows]: $rowsToClear");

    if (rowsToClear.isEmpty) return;

    for (int r in rowsToClear) {
      playfieldMatrix.removeAt(r);
      playfieldMatrix.insert(0, List.filled(game.numCols, null));
    }

    // debugPrintMatrix();

    handleLineClear(rowsToClear.length);
  }

  void throwTrashLines(int numLines) {
    final cols = game.numCols;
    final trashColor = Colors.grey[800] ?? Colors.grey;
    final rand = Random();

    for (int i = 0; i < numLines; i++) {
      // Remove top line (push everything up)
      playfieldMatrix.removeAt(0);

      // Generate trash line with one random hole
      int holeIndex = rand.nextInt(cols);
      List<TileData?> trashLine = List.generate(
        cols,
        (c) => c == holeIndex ? null : TileData(color: trashColor),
      );

      // Add trash line at the bottom
      playfieldMatrix.add(trashLine);
    }
  }

  Future<void> spawnNewPiece() async {
    final game = gameDisplayComponent;
    collisionSides = [];

    final nextPiece = game.getNextPiece();
    Vector2 startPosition = Vector2(3, -1);
    if (nextPiece.type == TetrisPieceType.O) {
      startPosition = Vector2(4, -1);
    }

    // Remove old current piece component if exists
    if (currentPieceComponent != null) {
      currentPieceComponent!.removeCurrentPiece();
      currentPieceComponent!.removeFromParent();
      currentPieceComponent = null;
    }

    // Create new current piece component and add to parent
    currentPieceComponent = CurrentPieceComponent(nextPiece, startPosition);
    // debugPrint(
    //   '[spawnNewPiece] Created: $currentPieceComponent, piece=${nextPiece.type}, position=$startPosition',
    // );
    add(currentPieceComponent!);

    currentPieceComponent!.canHold = true;

    // Update preview UI
    game.previewComponent?.updatePreview(game.previewPieces);

    // Update ghost piece
    // generateGhostPiece();

    // Check game over
    if (checkOverlapCollision(startPosition, nextPiece)) {
      gravityTimer.stop();
      addGameoverDialog();
    }

    // game.processLifecycleEvents();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _drawBackground(canvas);
    // _drawGrid(canvas);
    _drawWalls(canvas);
    _drawTiles(canvas);
    _drawGhostPiece(canvas);

    currentPieceComponent!.drawCurrentPiece(canvas, game.cellSize);

    _drawLockTimerBar(canvas);
  }

  void _drawBackground(Canvas canvas) {
    final numRows = game.numRows;
    final numCols = game.numCols;
    final cellSize = game.cellSize;
    final bgPaint = Paint()..color = const Color.fromARGB(255, 126, 112, 92);
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        -2 * cellSize,
        cellSize * numCols,
        cellSize * (numRows + 2),
      ),
      bgPaint,
    );

    // Vẽ grid lên background
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int r = 0; r <= numRows + 2; r++) {
      final y = r * cellSize - 2 * cellSize;
      canvas.drawLine(Offset(0, y), Offset(cellSize * numCols, y), gridPaint);
    }
    for (int c = 0; c <= numCols; c++) {
      final x = c * cellSize;
      canvas.drawLine(
        Offset(x, -2 * cellSize),
        Offset(x, cellSize * (numRows + 2) - 2 * cellSize),
        gridPaint,
      );
    }
  }

  void _drawWalls(Canvas canvas) {
    final numRows = game.numRows;
    final numCols = game.numCols;
    final cellSize = game.cellSize;
    final wallPaint = Paint()..color = Colors.blue;
    final wallBorderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int row = 0; row < numRows + 2; row++) {
      final x = -cellSize;
      final y = row * cellSize - cellSize * 2;
      canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), wallPaint);
      canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), wallBorderPaint);
    }
    for (int row = 0; row < numRows + 2; row++) {
      final x = numCols * cellSize;
      final y = row * cellSize - cellSize * 2;
      canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), wallPaint);
      canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), wallBorderPaint);
    }
    for (int col = 0; col < numCols + 2; col++) {
      final x = col * cellSize - cellSize;
      final y = numRows * cellSize;
      canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), wallPaint);
      canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), wallBorderPaint);
    }
  }

  void _drawTiles(Canvas canvas) {
    final numRows = game.numRows;
    final numCols = game.numCols;
    final cellSize = game.cellSize;
    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        final tile = playfieldMatrix[r][c];
        if (tile != null) {
          final tilePaint = Paint()..color = tile.color;
          final x = c * cellSize;
          final y = r * cellSize;
          canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), tilePaint);

          final borderPaint = Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
          canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), borderPaint);
        }
      }
    }
  }

  void _drawGhostPiece(Canvas canvas) {
    if (currentPieceComponent?.piece == null) return;
    final piece = currentPieceComponent!.piece!;
    Vector2 ghostPos = currentPieceComponent!.position.clone();
    while (true) {
      final testPos = Vector2(ghostPos.x, ghostPos.y + 1);
      if (checkOverlapCollision(testPos, piece)) {
        break;
      }
      ghostPos.y++;
    }
    final cellSize = game.cellSize;
    final shape = piece.shape;
    final ghostColor = Colors.grey.withOpacity(0.4);
    for (int r = 0; r < shape.length; r++) {
      for (int c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 1) {
          final tileX = (ghostPos.x + c) * cellSize;
          final tileY = (ghostPos.y + r) * cellSize;
          final tileRect = Rect.fromLTWH(tileX, tileY, cellSize, cellSize);
          final tilePaint = Paint()..color = ghostColor;
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

  void _drawLockTimerBar(Canvas canvas) {
    // if (!isLockCountdown || lockTimer.limit == 0) return;

    // Vị trí và kích thước thanh timer
    final double barWidth = game.cellSize * 12;
    final double barHeight = 15;
    final double barX = -game.cellSize;
    final double barY = -3 * game.cellSize; // phía dưới playfield

    // Tính phần trăm thời gian còn lại
    final double percent = (1 - lockTimer.progress).clamp(0.0, 1.0);

    // Vẽ nền thanh
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.2);
    canvas.drawRect(Rect.fromLTWH(barX, barY, barWidth, barHeight), bgPaint);

    // Vẽ phần timer còn lại
    final timerPaint = Paint()..color = Colors.redAccent;
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth * percent, barHeight),
      timerPaint,
    );
  }
}

// Helper class to store tile data
