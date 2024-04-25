List<Room> rooms = [];

class Room{
  final Player player1;
  final Player player2;
  final int code;
  final int turn;

  Room({
    required this.player1,
    required this.player2,
    required this.code,
    required this.turn,
  });

}
class Player {
  final String symbol;
  final String move;

  Player({
    required this.symbol,
    required this.move,
  });
}
