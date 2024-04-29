import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiktaktoe/classes/online_player_class.dart';
import '../classes/game_logic.dart';
import '../classes/multiplayer_service.dart';
import '../classes/one_tap_register_class.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MultiplayerScreen extends StatefulWidget {
  final Room room;
  final bool isHost;

  const MultiplayerScreen(
      {super.key, required this.room, required this.isHost});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  late IO.Socket socket;
  var gameBoard = GameLogic.initializeGameBoard();

  @override
  void initState() {
    super.initState();
    socket = IO.io(
        "https://spiny-trite-breeze.glitch.me/",
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setTimeout(10000)
            .build());
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
            Consumer(
                builder: (context, MultiplayerService multiplayerService, _) {
              return StreamBuilder<Room>(
                stream: multiplayerService.roomUpdates,
                builder: (context, snapshot) {
                  socket.on(
                      'roomUpdate',
                      (data) =>
                          print('Room updated i mean braodcasted: $data'));
                  // print the list of moves from the room.moves in neat order
                  print('List of moves: ${snapshot.data?.moves}');
                  if (snapshot.hasData) {
                    final room = snapshot.data!;
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
                  }
                  return const SizedBox();
                },
              );
            }),
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
    if ((gameBoard[rowIndex][colIndex] == '')) {
      // Create a new movement object (unchanged)
      final newMovement =
          Movement(symbol: widget.isHost ? 'X' : 'O', move: index);

      // Send the move to the server (unchanged)
      multiplayerService.sendMove(widget.room.code, newMovement);
      // Update the local game board using a separate function for clarity
      //await updateGameBoardFromRoomUpdates(multiplayerService);
    } else {
      // Show snack bar with appropriate message (unchanged)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('It is not your turn'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  // Future<void> updateGameBoardFromRoomUpdates(MultiplayerService service) async {
  //   // Listen for room updates and update the board
  //   service.roomUpdates?.listen((room) {
  //     print('Room updated: $room');
  //     setState(() {
  //       gameBoard = room.moves.fold<List<List<String>>>(
  //         List.generate(3, (_) => List.filled(3, '')),
  //             (board, move) {
  //           final moveParts = move.move.split(',');
  //           final rowIndex = int.parse(moveParts[0]);
  //           final colIndex = int.parse(moveParts[1]);
  //           board[rowIndex][colIndex] = move.symbol;
  //           return board;
  //         },
  //       );
  //     });
  //   });
  // }

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
}
