// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tetris_game/screen/gameplay/components/tetris_pieces.dart';
import 'package:tetris_game/screen/gameplay/models.dart';

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

  Player copyWith({String? id, String? name}) {
    return Player(id: id ?? this.id, name: name ?? this.name);
  }
}

class GameSettings {
  double musicVolume;
  double soundVolume;
  bool isMusicEnabled;
  bool isSoundEnabled;

  GameSettings({
    this.musicVolume = 1.0,
    this.soundVolume = 1.0,
    this.isMusicEnabled = true,
    this.isSoundEnabled = true,
  });
}

class GamePlay {
  int combo;
  String comboName;
  int garbageLines;
  List<List<TileData?>> playfieldMatrix;
  List<TetrisPiece> tetrominoQueue;

  GamePlay({
    this.combo = 0,
    this.comboName = "",
    this.garbageLines = 0,
    List<List<TileData?>>? playfieldMatrix,
    List<TetrisPiece>? tetrominoQueue,
  }) : playfieldMatrix =
           playfieldMatrix ??
           List.generate(20, (_) => List.generate(10, (_) => null)),
       tetrominoQueue = tetrominoQueue ?? [];

  GamePlay copyWith({
    int? combo,
    String? comboName,
    int? garbageLines,
    List<List<TileData?>>? playfieldMatrix,
    List<TetrisPiece>? tetrominoQueue,
  }) {
    return GamePlay(
      combo: combo ?? this.combo,
      comboName: comboName ?? this.comboName,
      garbageLines: garbageLines ?? this.garbageLines,
      playfieldMatrix: playfieldMatrix ?? this.playfieldMatrix,
      tetrominoQueue: tetrominoQueue ?? this.tetrominoQueue,
    );
  }
}

enum GameMessageType {
  none,
  find_game,
  accept_request,
  decline_request,
  control_game,
}

// all communication between 2 players
enum GameControl { attack, gameover, surrender, add_to_queue }

// filter response from server
class GameMessage {
  final String type;
  final Map<String, dynamic> payload;

  GameMessage({required this.type, required this.payload});

  factory GameMessage.fromJson(dynamic json) {
    if (json is String) json = jsonDecode(json);
    debugPrint('GameMessage.fromJson: $json');
    return GameMessage(type: json['type'], payload: json['payload'] ?? {});
  }

  Map<String, dynamic> toJson() => {'type': type, 'payload': payload};

  @override
  String toString() => jsonEncode(toJson());
}
