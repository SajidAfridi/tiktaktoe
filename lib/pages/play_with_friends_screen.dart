import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiktaktoe/classes/online_player_class.dart';
import '../classes/game_logic.dart';
import '../classes/multiplayer_service.dart';
import '../classes/one_tap_register_class.dart';

class MultiplayerScreen extends StatefulWidget {
  final Room room;
  final bool isHost;

  const MultiplayerScreen(
      {super.key, required this.room, required this.isHost});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  var gameBoard = GameLogic.initializeGameBoard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            if (widget.isHost)
              Text(
                'Room code: ${widget.room.code.toString()}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(4),
              child: OnlyOnePointerRecognizerWidget(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final rowIndex = index ~/ 3;
                    final colIndex = index % 3;
                    final cellValue = gameBoard[rowIndex][colIndex];
                    return buildGridCell(rowIndex, colIndex, cellValue);
                  },
                  itemCount: 9,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Your symbol: ${widget.isHost ? 'X' : 'O'}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTap(String index) async {
    final multiplayerService =
        Provider.of<MultiplayerService>(context, listen: false);
    final rowIndex = int.parse(index.split(',')[0]);
    final colIndex = int.parse(index.split(',')[1]);
    //check and return the turn value from the room
    int turn = multiplayerService.getRoomTurn(widget.room.code);
    bool isPlayerTurn = multiplayerService.isPlayerTurn(turn, widget.isHost ? 'X' : 'O');
    if ((gameBoard[rowIndex][colIndex] == '')&&(isPlayerTurn)) {
      multiplayerService.sendMove(
          widget.room.code, widget.isHost ? 'X' : 'O', index);
      gameBoard[rowIndex][colIndex] = widget.isHost ? 'X' : 'O';
      setState(() {
        multiplayerService.roomUpdates?.listen((room) {
          print('Room updated: $room');
          setState(() {
            gameBoard = room.moves.fold<List<List<String>>>(
              List.generate(3, (_) => List.filled(3, '')),
                  (board, move) {
                final moveParts = move.move.split(',');
                final rowIndex = int.parse(moveParts[0]);
                final colIndex = int.parse(moveParts[1]);
                board[rowIndex][colIndex] = move.symbol;
                return board;
              },
            );
          });
        });
      });
    }else{
      //show snack bar with appropriate message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('It is not your turn'),
        duration: Duration(seconds: 2),
      ));
    }

  }

  Widget buildGridCell(int rowIndex, int colIndex, String cellValue) {
    return GestureDetector(
      onTap: () {
        print('Cell tapped: $rowIndex,$colIndex');
        _handleTap('$rowIndex,$colIndex');
      },
      child: Card(child: iconDecider(cellValue)),
    );
  }

  Widget iconDecider(String value) {
    //bool isWinningMove = value.endsWith('_win');
    if (value.replaceAll('_win', '') == 'X') {
      return FadeOutUp(
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.green,
            boxShadow: const [],
          ),
          child: Image.asset(
            'assets/images/cross.png',
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (value.replaceAll('_win', '') == 'O') {
      return FadeOutUp(
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [],
          ),
          child: Image.asset(
            'assets/images/circle_1.png',
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return FadeOutUp(
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [],
          ),
          child: const Center(child: Text('')),
        ),
      );
    }
  }
  void updateGameBoard(List<List<String>> moves) {
    setState(() {
      gameBoard = moves;
    });
  }

}
