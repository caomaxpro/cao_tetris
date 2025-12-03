// ignore_for_file: unnecessary_null_comparison, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tetris_game/components/app_bar.dart';
import 'package:tetris_game/screen/bloc/bloc_bloc.dart';
import 'package:tetris_game/screen/gameplay/game_screen.dart';
import 'package:tetris_game/screen/multi_mode/match_request_dialog.dart';
import 'package:tetris_game/screen/multi_mode/models.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class MultiScreen extends StatefulWidget {
  const MultiScreen({super.key});

  @override
  State<MultiScreen> createState() => _MultiScreenState();
}

class _MultiScreenState extends State<MultiScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedMode = 'versus';
  bool isTestField = false;
  bool isNameSaved = true;

  late BlocBloc bloc;

  // Getter tiện lợi cho BlocGameInfo
  BlocGameInfo? get gameInfo =>
      bloc.state is BlocGameInfo ? bloc.state as BlocGameInfo : null;

  void handleMatchRequest(dynamic data, bool accept) {
    if (gameInfo == null) {
      debugPrint('Bloc state is not BlocGameInfo');
      return;
    }
    final player = gameInfo!.player;
    final room_id = data["room_id"];
    final ticket = Ticket(
      type: GameMessageType.accept_request.name,
      payload: {'room_id': room_id, 'player_id': player.id, 'accept': accept},
    );
    bloc.add(BlocSendMessage(ticket.toString()));
  }

  void handleFindGame() {
    if (gameInfo == null) {
      debugPrint('Bloc state is not BlocGameInfo');
      return;
    }
    final player = gameInfo!.player;
    debugPrint('Player info: id=${player.id}, name=${player.name}');

    final ticket = Ticket(
      type: GameMessageType.find_game.name,
      payload: {
        'player_id': player.id,
        'player_name': player.name == "" ? "You" : player.name,
        'mode': _selectedMode,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    debugPrint('Sending ticket: ${ticket.toString()}');
    bloc.add(BlocSendMessage(ticket.toString()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<BlocBloc>();
    bloc.add(BlocConnect());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BlocBloc, BlocState>(
      listenWhen: (previous, current) {
        if (previous is BlocGameInfo && current is BlocGameInfo) {
          return previous.message != current.message;
        }
        return false;
      },
      listener: (context, state) {
        if (state is BlocGameInfo) {
          final result = state.message;
          final type = result.type;
          final payload = result.payload;

          switch (type) {
            case "request_accept_match":
              showDialog(
                context: context,
                builder: (context) => MatchRequestDialog(
                  opponentName: "Player",
                  onAccept: () {
                    Navigator.of(context).pop();
                    handleMatchRequest(payload, true);
                  },
                  onDecline: () {
                    Navigator.of(context).pop();
                    handleMatchRequest(payload, false);
                  },
                ),
              );
              break;
            case "accept_request":
              debugPrint("[Accept Request]: connect 2 players successfully");

              final p2 = payload["opponent"];
              final id = p2["id"];
              final name = p2["name"];
              final roomId = payload["room_id"];

              if (gameInfo != null) {
                final prevState = gameInfo!;
                debugPrint(
                  'PrevState: roomId=${prevState.roomId}, player=${prevState.player}, opponent=${prevState.opponent}',
                );
                // if the opponent accepts the request then update opponent info immediately and join the game
                bloc.add(
                  BlocUpdateGameState(
                    gameMode: GameMode.multi,
                    gamePlayStyle: GamePlayStyle.battle,
                    roomId: roomId ?? prevState.roomId,
                    opponent: Player(id: id, name: name),
                  ),
                );
              }

              // debugPrint(
              //   "[Accept Request]: ${gameInfo!.roomId}, ${gameInfo!.player}, ${gameInfo!.opponent}",
              // );

              // if everything is on set => navigate user to game screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => GameScreen()),
              );
              break;

            case "decline_request":
              // distroy the temp room and move player back to lobby and continue to wait for other opponents..
              break;

            case "gameover":
              break;

            case "error":
              // Xử lý lỗi
              break;
            default:
              break;
          }
        }
      },
      child: Scaffold(
        appBar: buildAppBar(context: context, title: 'Battle Mode'),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Player Name:', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  if (!isNameSaved)
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                        ),
                        onChanged: (value) {},
                      ),
                    ),
                  if (!isNameSaved)
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        final String name = _nameController.text.trim();
                        if (name.isNotEmpty && gameInfo != null) {
                          final Player player = Player(
                            id: gameInfo!.player.id,
                            name: name,
                          );
                          bloc.add(BlocUpdateGameState(player: player));
                          setState(() {
                            isNameSaved = true;
                          });
                        }
                      },
                    ),
                  if (isNameSaved)
                    Text(
                      gameInfo?.player.name ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (isNameSaved)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          isNameSaved = false;
                          _nameController.text = gameInfo?.player.name ?? '';
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Game Mode:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              const Text(
                'Battle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    handleFindGame();
                    final player =
                        gameInfo?.player ?? Player(id: '', name: 'You');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Finding game for ${player.name == "" ? "You" : player.name} ($_selectedMode)...',
                        ),
                      ),
                    );
                  },
                  child: const Text('Find Game'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
