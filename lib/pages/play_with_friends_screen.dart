import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiktaktoe/classes/online_player_class.dart';
import 'package:tiktaktoe/pages/welcome_and_difficulty_selection_screen.dart';
import '../classes/game_logic.dart';
import '../classes/multiplayer_service.dart';
import '../classes/one_tap_register_class.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MultiplayerScreen extends StatefulWidget {
  final Room room;
  final bool isHost;

  const MultiplayerScreen({
    super.key,
    required this.room,
    required this.isHost,
  });

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  late IO.Socket socket;
  var gameBoard = GameLogic.initializeGameBoard();
  late StreamController<Room> _roomController;

  @override
  void initState() {
    super.initState();
    socket = IO.io(
        "https://spiny-trite-breeze.glitch.me/",
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setTimeout(10000)
            .build());
    _roomController = StreamController<Room>();
    socket.on('roomUpdate', (data) {
      final room = Room.fromJson(data);
      print('Room updated: $room');
      _roomController.add(room);
    });
  }

  @override
  void dispose() {
    // Close the StreamController when it's no longer needed
    _roomController.close();
    super.dispose();
  }

  // Define roomUpdates stream getter
  Stream<Room> get roomUpdates {
    return _roomController.stream;
  }

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
            //stream builder with the stream from the provider
            StreamBuilder<Room>(
              stream: roomUpdates,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    updateGameBoard(snapshot.data!);
                  });
                }
                return const SizedBox();
              },
            ),
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
                    // Calculate the row and column index based on the index
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
    if ((gameBoard[rowIndex][colIndex] == '')) {
      final newMovement =
      Movement(symbol: widget.isHost ? 'X' : 'O', move: index);

      // Send the move to the server (unchanged)
      multiplayerService.sendMove(widget.room.code, newMovement);

      // Update the game board with the new move
      setState(() {
        gameBoard[rowIndex][colIndex] = newMovement.symbol;
      });

      // Call checkWin after updating the game board
      checkWin(newMovement.symbol, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('It is not your turn'),
        duration: Duration(seconds: 2),
      ));
    }
  }


  Widget buildGridCell(int rowIndex, int colIndex, String cellValue) {
    final symbol = gameBoard[rowIndex][colIndex];
    return GestureDetector(
      onTap: () {
        print('Cell tapped: $rowIndex,$colIndex');
        _handleTap('$rowIndex,$colIndex');
      },
      child: Card(child: iconDecider(symbol)),
    );
  }

  Widget iconDecider(String symbol) {
    if (symbol == 'X') {
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
    } else if (symbol == 'O') {
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

  Widget buildGameBoard(List<List<String>> gameBoard) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(4),
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
    );
  }

  updateGameBoard(Room room) {
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
  }

  void checkWin(String symbol, BuildContext context) {
    String winner = '';
    if (gameBoard[0][0] == gameBoard[0][1] &&
        gameBoard[0][0] == gameBoard[0][2] &&
        gameBoard[0][0].isNotEmpty) {
      winner = gameBoard[0][0];
    } else if (gameBoard[1][0] == gameBoard[1][1] &&
        gameBoard[1][0] == gameBoard[1][2] &&
        gameBoard[1][0].isNotEmpty) {
      winner = gameBoard[1][0];
    } else if (gameBoard[2][0] == gameBoard[2][1] &&
        gameBoard[2][0] == gameBoard[2][2] &&
        gameBoard[2][0].isNotEmpty) {
      winner = gameBoard[2][0];
    } else if (gameBoard[0][0] == gameBoard[1][0] &&
        gameBoard[0][0] == gameBoard[2][0] &&
        gameBoard[0][0].isNotEmpty) {
      winner = gameBoard[0][0];
    } else if (gameBoard[0][1] == gameBoard[1][1] &&
        gameBoard[0][1] == gameBoard[2][1] &&
        gameBoard[0][1].isNotEmpty) {
      winner = gameBoard[0][1];
    } else if (gameBoard[0][2] == gameBoard[1][2] &&
        gameBoard[0][2] == gameBoard[2][2] &&
        gameBoard[0][2].isNotEmpty) {
      winner = gameBoard[0][2];
    } else if (gameBoard[0][0] == gameBoard[1][1] &&
        gameBoard[0][0] == gameBoard[2][2] &&
        gameBoard[0][0].isNotEmpty) {
      winner = gameBoard[0][0];
    } else if (gameBoard[0][2] == gameBoard[1][1] &&
        gameBoard[0][2] == gameBoard[2][0] &&
        gameBoard[0][2].isNotEmpty) {
      winner = gameBoard[0][2];
    }

    if (winner.isNotEmpty) {
      String who = '';
      if (winner == symbol) {
        who = 'You';
      } else {
        who = 'Opponent';
      }
      AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: '$who Won!',
          desc: 'Play Again',
          headerAnimationLoop: false,
          btnCancel: ElevatedButton(
            onPressed: () {
              disconnectSocket();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
                return const SelectDifficultyScreen();
              }), (route) => false);
            },
            child: const Text('Back'),
          ),
          btnOkOnPress: () {
            resetGame();
          }).show();
    } else if (isBoardFull()) {
      AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Draw',
          desc: 'Play again',
          headerAnimationLoop: false,
          btnCancel: ElevatedButton(
            onPressed: () {
              disconnectSocket();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
                return const SelectDifficultyScreen();
              }), (route) => false);
            },
            child: const Text('Back to Home'),
          ),
          btnOkOnPress: () {
            resetGame();
          }).show();
    }
  }

  bool isBoardFull() {
    for (var row in gameBoard) {
      for (var cell in row) {
        if (cell.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void disconnectSocket() {
    socket.disconnect();
  }

  void resetGame() {
    final multiplayerService =
    Provider.of<MultiplayerService>(context, listen: false);
    multiplayerService.resetGame(widget.room.code);
    setState(() {
      gameBoard = GameLogic.initializeGameBoard();
    });
  }
}
