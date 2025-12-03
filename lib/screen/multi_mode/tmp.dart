// ignore_for_file: unnecessary_null_comparison, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:tetris_game/screen/multi_mode/match_request_dialog.dart';
import 'package:tetris_game/websocket/websocket.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:flutter/scheduler.dart';

class Ticket {
  final String type; // e.g. 'connection', 'gameState', etc.
  final Map<String, dynamic> payload;

  Ticket({required this.type, required this.payload});

  Map<String, dynamic> toJson() => {'type': type, 'payload': payload};

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class Player {
  String id = "";
  String name = "";

  Player({required this.id, required this.name});

  Map<String, dynamic> toJson() => {"id": id, "name": name};

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class MultiScreen extends StatefulWidget {
  const MultiScreen({Key? key}) : super(key: key);

  @override
  State<MultiScreen> createState() => _MultiScreenState();
}

class _MultiScreenState extends State<MultiScreen> with WidgetsBindingObserver {
  final TextEditingController _nameController = TextEditingController();
  String _selectedMode = 'versus';
  WebSocketService? wsService;

  String roomId = "";
  Player player1 = Player(id: const Uuid().v4(), name: "");
  Player player2 = Player(id: "", name: "");

  bool isTestField = false;

  void setPlayerName(String value) {
    player1.name = value.trim();
  }

  Map<String, dynamic> handleMessage(dynamic message) {
    final data = jsonDecode(message);
    final type = data["type"];
    final payload = data["payload"];

    return {"type": type, "payload": payload};
  }

  void handleMatchRequest(dynamic data, bool accept) {
    final room_id = data["room_id"];
    final player_id = player1.id;

    final ticket = Ticket(
      type: 'accept_request',
      payload: {'room_id': room_id, 'player_id': player_id, 'accept': accept},
    );
    wsService?.send(jsonEncode(ticket.toJson()));
  }

  void handleFindGame() {
    final ticket = Ticket(
      type: 'find_game',
      payload: {
        'player_id': player1.id,
        'player_name': player1.name.trim().isEmpty
            ? player1.id
            : player1.name.trim(),
        'mode': _selectedMode,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    wsService?.send(jsonEncode(ticket.toJson()));
  }

  void handleThrowTrash({required String roomId, required int lines}) {
    final ticket = Ticket(
      type: 'throw_trash',
      payload: {'room_id': roomId, 'player_id': player1.id, 'lines': lines},
    );
    wsService?.send(jsonEncode(ticket.toJson()));
    debugPrint('Sent throw_trash: room_id=$roomId, lines=$lines');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Khởi tạo WebSocket nếu cần
    wsService = WebSocketService('ws://192.168.12.102:3000');
    wsService?.listen((message) {
      final result = handleMessage(message);
      final type = result["type"];
      final payload = result["payload"];

      debugPrint('Type: $type');
      debugPrint('Payload: $payload');

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
                handleMatchRequest(payload, false);
                Navigator.of(context).pop();
              },
            ),
          );
          break;
        case "accept_request":
          // Xử lý khi phòng được tạo thành công
          // Ví dụ: chuyển sang màn hình gameplay hoặc hiển thị thông báo

          // get opponent_info, room_id

          final p2 = payload["opponent"];
          player2.id = p2["id"];
          player2.name = p2["name"];
          setState(() {
            isTestField = true;
          });

          // direct 2 players to their playfield

          break;
        case "decline_request":
          // Xử lý khi đối thủ từ chối
          // Ví dụ: hiển thị thông báo hoặc quay lại lobby

          break;
        case "error":
          // Xử lý lỗi
          // Ví dụ: show SnackBar với thông báo lỗi
          break;
        default:
          // Xử lý các loại message khác nếu cần
          break;
      }
      // Xử lý các loại message khác ở đây
      debugPrint('Received message: $message');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    wsService?.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      wsService?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reconnect logic if needed
    }
  }

  @override
  void activate() {
    // TODO: implement activate
    super.activate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiplayer')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Player Name:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter your name'),
              onChanged: (value) {
                setPlayerName(value);
              },
            ),
            const SizedBox(height: 24),
            const Text('Game Mode:', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: _selectedMode,
              items: const [
                DropdownMenuItem(value: 'versus', child: Text('Versus')),
                DropdownMenuItem(value: 'marathon', child: Text('marathon')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMode = value!;
                });
              },
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement find game logic
                  final name = _nameController.text.trim();
                  final mode = _selectedMode;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Finding game for $name ($mode)...'),
                    ),
                  );

                  handleFindGame();
                },
                child: const Text('Find Game'),
              ),
            ),

            if (isTestField)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Example: send a throw_trash ticket
                    final ticket = Ticket(
                      type: 'throw_trash',
                      payload: {
                        'room_id':
                            'test_room_id', // replace with actual room_id if needed
                        'player_id': player1.id,
                        'lines': 2, // number of lines to throw
                      },
                    );
                    wsService?.send(jsonEncode(ticket.toJson()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test: Throw Lines sent!')),
                    );
                  },
                  child: const Text('Throw Lines'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
