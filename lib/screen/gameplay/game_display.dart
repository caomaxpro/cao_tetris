import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_svg/svg.dart';
import 'package:flame_svg/svg_component.dart';
import 'package:flutter/material.dart';
import 'package:tetris_game/screen/gameplay/components/button.dart';
import 'package:tetris_game/screen/gameplay/components/svg.dart';
import 'package:tetris_game/screen/gameplay/components/tetris_pieces.dart';
import 'package:tetris_game/screen/bloc/bloc_bloc.dart';
import 'package:tetris_game/screen/gameplay/game_screen.dart';
import 'package:tetris_game/screen/gameplay/models.dart';
import 'package:tetris_game/screen/gameplay/playfield/effect_queue.dart';
import 'package:tetris_game/screen/gameplay/playfield/hold.dart';
import 'package:tetris_game/screen/gameplay/playfield/mini_playfield.dart';
import 'package:tetris_game/screen/gameplay/playfield/playfield.dart';
import 'package:tetris_game/screen/gameplay/playfield/preview.dart';
import 'package:tetris_game/screen/gameplay/playfield/score.dart';

class GameDisplayComponent extends Component
    with
        HasCollisionDetection,
        CollisionCallbacks,
        TapCallbacks,
        FlameBlocReader<BlocBloc, BlocState>,
        FlameBlocListenable<BlocBloc, BlocState> {
  double screenWidth;
  double screenHeight;
  double statusBarHeight;
  final BlocBloc blocBloc;

  int numRows = 22;
  int numCols = 10;
  double cellSize = 20;

  GameDisplayComponent({
    this.screenWidth = 0,
    this.screenHeight = 0,
    this.statusBarHeight = 0,
    this.numCols = 22,
    this.numRows = 10,
    this.cellSize = 20,
    required this.blocBloc,
  });

  bool isBattleMode = false;

  TetrisPiece? heldPiece;
  List<TetrisPiece> previewPieces = [];
  Timer? moveTimer;

  HoldComponent? holdComponent;
  PlayfieldComponent? playField;
  PreviewComponent? previewComponent;
  MiniPlayfieldComponent? miniPlayfieldComponent;

  int score = 0;
  ScoreComponent? scoreComponent;

  int level = 1;
  int linesCleared = 0;
  int linesPerLevel = 10;

  BlocGameInfo? gameInfo;

  // Attack effect timer
  EffectQueue effectQueue = EffectQueue();

  @override
  void update(double dt) {
    super.update(dt);
    moveTimer?.update(dt);
    effectQueue.update(dt);
  }

  // @override
  // void onTapDown(TapDownEvent event) {
  //   moveTimer?.stop();
  //   // rotatePiece();
  //   super.onTapDown(event);
  // }

  /* 
    next pieces logic
    + first create three pieces first
    + next piece to drop is the first piece in the list
    + remove the first piece when dropping piece locked
   */
  List<TetrisPieceType> generateShuffledBag() {
    final bag = List<TetrisPieceType>.from(TetrisPieceType.values);
    bag.shuffle();
    return bag;
  }

  void generatePreviewPiece() {
    // debugPrint('[Bag added] ${previewPieces.map((e) => e.type).toList()}');

    while (previewPieces.length < 14) {
      final bag = generateShuffledBag();
      for (final type in bag) {
        previewPieces.add(createTetrisPiece(type));
      }
    }
    if (previewPieces.length == 7) {
      final bag = generateShuffledBag();
      for (final type in bag) {
        previewPieces.add(createTetrisPiece(type));
      }
    }
  }

  // Lấy next piece để chơi, cập nhật preview
  TetrisPiece getNextPiece() {
    generatePreviewPiece();
    final nextPiece = previewPieces.first;
    previewPieces.removeAt(0);
    return nextPiece;
  }

  String? _lastPlayfieldMatrixStr;

  @override
  void onNewState(BlocState state) {
    debugPrint("[Game Display from game display]: $state");

    if (state is BlocGameInfo) {
      final matrixStr = playfieldMatrixToString(state.gamePlay.playfieldMatrix);
      if (_lastPlayfieldMatrixStr == null ||
          _lastPlayfieldMatrixStr != matrixStr) {
        _lastPlayfieldMatrixStr = matrixStr;
        _initMiniPlayfield();
      }
    }
  }

  // Chuyển ma trận sang chuỗi để so sánh

  void startAutoMove(int dx, int dy, PlayfieldComponent playField) {
    moveTimer?.onTick = () =>
        playField.currentPieceComponent!.movePiece(dx, dy);
    moveTimer?.start();
  }

  void stopAutoMove() {
    debugPrint("[stopAutoMove]: stop!!");
    moveTimer?.onTick = () {};
    moveTimer?.stop();
  }

  void debugPrintBlocState() {
    final state = blocBloc.state;
    debugPrint('[BlocBloc State]: ${state.runtimeType}');
    debugPrint('[BlocBloc State]: $state');

    // If you want to print more details for BlocGameInfo:
    if (state is BlocGameInfo) {
      debugPrint('GameMode: ${state.gameMode}');
      debugPrint('GamePlayStyle: ${state.gamePlayStyle}');
      debugPrint('RoomId: ${state.roomId}');
      debugPrint('Player: ${state.player}');
      debugPrint('Opponent: ${state.opponent}');
      debugPrint('Message: ${state.message}');
      debugPrint('GamePlay: ${state.gamePlay}');
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    moveTimer = Timer(
      0.08, // interval
      repeat: true,
      onTick: () {},
    );

    if (blocBloc.state is BlocGameInfo) {
      debugPrintBlocState();

      final info = blocBloc.state as BlocGameInfo;

      if (info.gameMode == GameMode.single &&
          info.gamePlayStyle != GamePlayStyle.zen) {
        _initScore();
      }

      if (info.gameMode == GameMode.multi &&
          info.gamePlayStyle == GamePlayStyle.battle) {
        // debugPrint('BlocGameInfo: $info');
        // debugPrint('GameMode: ${info.gameMode}');
        // debugPrint('GamePlayStyle: ${info.gamePlayStyle}');
        // debugPrint('RoomId: ${info.roomId}');
        // debugPrint('Player: ${info.player}');
        // debugPrint('Opponent: ${info.opponent}');
        _initMiniPlayfield();
      }
    }

    await _initPlayfield();
    await _initMoveButtons();
    await _initPreviewAndHold();
    // await _initBackground();

    await _initRotateButtons();
    await _initSwapAndDropButtons();
  }

  Future<void> _initMiniPlayfield() async {
    final info = blocBloc.state;
    if (info is! BlocGameInfo) return;

    if (miniPlayfieldComponent == null) {
      debugPrint("[Game Display]: Rendering mini map");
      miniPlayfieldComponent = MiniPlayfieldComponent(
        numRows: 20,
        numCols: 10,
        cellSize: 90 / 10,
        matrix: info.gamePlay.playfieldMatrix,
        position: Vector2(screenWidth - 115, 220 - cellSize * 2),
      );
      await add(miniPlayfieldComponent!);
      return;
    }

    // If miniPlayfield component does exist, just update matrix :V
    miniPlayfieldComponent!.matrix = info.gamePlay.playfieldMatrix;
  }

  Future<void> _initScore() async {
    scoreComponent = ScoreComponent(
      position: Vector2(screenWidth - 115, 175 - cellSize * 2),
      size: Vector2(100, 80),
      score: score,
    );
    await add(scoreComponent!);
  }

  Future<void> _initPlayfield() async {
    playField = PlayfieldComponent(
      position: Vector2(cellSize * 2, 240),
      size: Vector2(numRows * cellSize, numCols * cellSize),
    );
    await add(playField!);
    heldPiece = null;
    generatePreviewPiece();
  }

  Future<void> _initPreviewAndHold() async {
    holdComponent = HoldComponent(
      position: Vector2(
        screenWidth - 115,
        220 -
            cellSize * 2 +
            (scoreComponent?.size.y ?? 0) +
            (miniPlayfieldComponent?.size.y ?? 0) +
            10,
      ),
      size: Vector2(90, 90),
      heldPiece: heldPiece,
    );
    previewComponent = PreviewComponent(
      position: Vector2(
        screenWidth - 115,
        220 -
            cellSize * 2 +
            (scoreComponent?.size.y ?? 0) +
            (miniPlayfieldComponent?.size.y ?? 0) +
            holdComponent!.size.y +
            20,
      ),
      size: Vector2(90, 235),
      nextPieces: previewPieces,
    );
    await add(previewComponent!);
    await add(holdComponent!);
  }

  bool _shouldDisplayScore(GameMode gameMode, GamePlayStyle gamePlayStyle) {
    // Chỉ hiển thị score cho single mode, không phải zen
    if (gameMode == GameMode.single && gamePlayStyle != GamePlayStyle.zen) {
      return true;
    }
    // Không hiển thị score cho chế độ battle
    return false;
  }

  Future<void> _initMoveButtons() async {
    SpriteComponent leftIcon = SpriteComponent(
      sprite: await Sprite.load("left.png"),
      size: Vector2(10, 10),
      position: Vector2.all(0),
    );

    await add(
      GameButton(
        label: "",
        position: Vector2(20, screenHeight - 120),
        width: 60,
        height: 50,
        spriteIcon: leftIcon,
        onPressed: () {
          debugPrint("[On Pressed]");
          startAutoMove(-1, 0, playField!);
        },
        onReleased: () => stopAutoMove(),
      ),
    );

    SpriteComponent downIcon = SpriteComponent(
      sprite: await Sprite.load("down.png"),
      size: Vector2(24, 24),
      position: Vector2.all(0),
    );

    await add(
      GameButton(
        label: "",
        position: Vector2(80, screenHeight - 60),
        width: 60,
        height: 50,
        spriteIcon: downIcon,
        onPressed: () => startAutoMove(0, 1, playField!),
        onReleased: () => stopAutoMove(),
      ),
    );

    SpriteComponent rightIcon = SpriteComponent(
      sprite: await Sprite.load("right.png"),
      size: Vector2(24, 24),
      position: Vector2.all(0),
    );

    await add(
      GameButton(
        label: "",
        position: Vector2(140, screenHeight - 120),
        width: 60,
        height: 50,
        spriteIcon: rightIcon,
        onPressed: () => startAutoMove(1, 0, playField!),
        onReleased: () {
          debugPrint("[On Released]: stop");
          stopAutoMove();
        },
      ),
    );
  }

  Future<void> _initRotateButtons() async {
    SpriteComponent rotateLeftIcon = SpriteComponent(
      sprite: await Sprite.load("rotate_left.png"),
      size: Vector2(24, 24),
      position: Vector2.all(0),
    );

    await add(
      GameButton(
        label: "",
        position: Vector2(screenWidth - 160, screenHeight - 120),
        width: 60,
        height: 50,
        spriteIcon: rotateLeftIcon,
        onPressed: () {
          playField!.currentPieceComponent!.rotatePiece(isRight: false);
          effectQueue.addEffect(
            EffectItem(
              text: "Combo x2",
              duration: 2,
              delay: 0,
              startTime:
                  effectQueue.globalTime +
                  0.1 * effectQueue.queue.length, // delay cho mỗi effect
              from: Offset(60.0 + 22.0 + 10.0, 100.0),
              to: Offset(screenWidth / 2 - 50, 100.0),
            ),
          );
        },
      ),
    );

    SpriteComponent rotateRightIcon = SpriteComponent(
      sprite: await Sprite.load("rotate_right.png"),
      size: Vector2(24, 24),
      position: Vector2.all(0),
    );

    await add(
      GameButton(
        label: "",
        position: Vector2(screenWidth - 80, screenHeight - 120),
        width: 60,
        height: 50,
        spriteIcon: rotateRightIcon,
        onPressed: () {
          playField!.currentPieceComponent!.rotatePiece(isRight: true);
          effectQueue.addEffect(
            EffectItem(
              text: "Combo x1",
              duration: 2,
              delay: 0,
              startTime:
                  effectQueue.globalTime +
                  0.1 * effectQueue.queue.length, // delay cho mỗi effect
              from: Offset(60.0 + 22.0 + 10.0, 100.0),
              to: Offset(screenWidth / 2 - 50, 100.0),
            ),
          );
        },
      ),
    );
  }

  Future<void> _initSwapAndDropButtons() async {
    SpriteComponent swapIcon = SpriteComponent(
      sprite: await Sprite.load("swap.png"),
      size: Vector2(24, 24),
      position: Vector2.all(0),
    );
    await add(
      GameButton(
        label: "",
        position: Vector2(screenWidth - 160, screenHeight - 60),
        width: 60,
        height: 50,
        spriteIcon: swapIcon,
        onPressed: () {
          if (playField!.currentPieceComponent!.piece != null) {
            playField!.currentPieceComponent!.holdPiece();
          }
        },
      ),
    );

    SpriteComponent dropIcon = SpriteComponent(
      sprite: await Sprite.load("drop.png"),
      size: Vector2(24, 24),
      position: Vector2.all(0),
    );

    await add(
      GameButton(
        label: "",
        position: Vector2(screenWidth - 80, screenHeight - 60),
        width: 60,
        height: 50,
        spriteIcon: dropIcon,
        onPressed: () {
          playField!.currentPieceComponent!.hardDrop();
          effectQueue.addEffect(
            EffectItem(
              text: "Attack!",
              duration: 2,
              delay: 0,
              startTime:
                  effectQueue.globalTime +
                  0.1 * effectQueue.queue.length, // delay cho mỗi effect
              from: Offset(60.0 + 22.0 + 10.0, 100.0),
              to: Offset(screenWidth / 2 - 50, 100.0),
            ),
          );
        },
      ),
    );
  }

  void _drawPlayer(
    Canvas canvas,
    Offset avatarPos,
    String name, {
    Color color = Colors.green,
  }) {
    // Vẽ avatar hình tròn
    final avatarRadius = 22.0;
    final playerPaint = Paint()..color = color;
    canvas.drawCircle(avatarPos, avatarRadius, playerPaint);

    // Vẽ tên dưới avatar
    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(color: Colors.black, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // Căn giữa text dưới avatar
    final textOffset = Offset(
      avatarPos.dx - textPainter.width / 2,
      avatarPos.dy + avatarRadius + 6,
    );
    textPainter.paint(canvas, textOffset);
  }

  void _drawGameBar(Canvas canvas) {
    // Vẽ thanh trạng thái game phía trên
    final barHeight = 60.0;
    final barPaint = Paint()..color = Colors.grey.withOpacity(0.2);
    canvas.drawRect(Rect.fromLTWH(0, 0, screenWidth, barHeight), barPaint);

    // Vẽ text trạng thái
    final statusText = TextPainter(
      text: TextSpan(
        text: 'TETRIS BATTLE',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    statusText.paint(
      canvas,
      Offset((screenWidth - statusText.width) / 2, barHeight / 2 - 16 / 2),
    );
  }

  @override
  void render(Canvas canvas) {
    // Vẽ background hoặc các thành phần custom nếu cần
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight), bgPaint);

    // Vẽ 2 hình tròn
    // final circlePaint1 = Paint()..color = Colors.red;
    // final circlePaint2 = Paint()..color = Colors.blue;
    // canvas.drawCircle(Offset(50, 110), 30, circlePaint1); // hình tròn đỏ
    // canvas.drawCircle(Offset(250, 110), 30, circlePaint2); // hình tròn xanh

    _drawGameBar(canvas);
    _drawPlayer(canvas, Offset(60, 110), 'You', color: Colors.green);
    effectQueue.draw(canvas);
    _drawPlayer(
      canvas,
      Offset(screenWidth - 70, 110),
      'Opponent',
      color: Colors.orange,
    );

    super.render(canvas);
    super.render(canvas);
  }
}
