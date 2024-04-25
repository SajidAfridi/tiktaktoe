List<Room> rooms = [];

class movement{
  final String symbol;
  final String move;

  movement({
    required this.symbol,
    required this.move,
  });
}


class Room{
  final Player player1;
  final Player player2;
  final int code;
  final int turn;
  final List<movement> moves = [];

  Room({
    required this.player1,
    required this.player2,
    required this.code,
    required this.turn,
  });

  //from json
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      player1: Player(
        symbol: json['player1']['symbol'],
        move: json['player1']['move'],
      ),
      player2: Player(
        symbol: json['player2']['symbol'],
        move: json['player2']['move'],
      ),
      code: json['code'],
      turn: json['turn'],
    );
  }

}
class Player {
  final String symbol;
  final String move;

  Player({
    required this.symbol,
    required this.move,
  });
}
