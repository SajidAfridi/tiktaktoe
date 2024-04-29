class Player {
  final String symbol;
  final String move;
  final String socketId;

  Player({required this.symbol, required this.move, required this.socketId});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      symbol: json['symbol'],
      move: json['move'],
      socketId: json['socketId'],
    );
  }
}

class Movement {
  final String move;
  final String symbol;

  Movement({required this.move, required this.symbol});

  factory Movement.fromJson(Map<String, dynamic> json) {
    return Movement(
      move: json['move'],
      symbol: json['symbol'],
    );
  }
}

class Room {
  List<Movement> moves;
  int code;
  int turn;
  List<Player> players;

  Room(
      {required this.moves,
      required this.code,
      required this.turn,
      required this.players});

  factory Room.fromJson(Map<String, dynamic> json) {
    var movesList = json['moves'] as List;
    List<Movement> moves =
        movesList.map((moveJson) => Movement.fromJson(moveJson)).toList();

    var playersList = json['players'] as List;
    List<Player> players =
        playersList.map((playerJson) => Player.fromJson(playerJson)).toList();

    return Room(
      moves: moves,
      code: json['code'],
      turn: json['turn'],
      players: players,
    );
  }
}
