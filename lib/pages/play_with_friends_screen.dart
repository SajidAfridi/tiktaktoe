import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiktaktoe/classes/online_player_class.dart';
import 'package:tiktaktoe/pages/join_or_create_screen.dart';
import 'package:tiktaktoe/pages/welcome_and_difficulty_selection_screen.dart';
import '../classes/game_logic.dart';
import '../classes/multiplayer_service.dart';
import '../classes/one_tap_register_class.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../widgets/who_vs_who_widget.dart';

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
      _roomController.add(room);
    });
    socket.on('Winner', (data) {
      String winner = data.toString(); // Assuming the winner symbol is sent as a string
      checkWin(winner);
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
    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
          return const CreateOrJoinScreen();
        }), (route) => false);
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoundInfoWidget(
                isHost: widget.isHost,
              ),
              const SizedBox(height: 30),
              if (widget.isHost)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.brown
                          .withOpacity(0.5), //Colors.brown.withOpacity(0.5),
                    ),
                    child: Text(
                      'Room Code: ${widget.room.code}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              //stream builder with the stream from the provider
              StreamBuilder<Room>(
                stream: roomUpdates,
                builder: (context, snapshot) {
                  String whoseTurn ='';
                  if (snapshot.data == null) {
                    return const SizedBox(
                    );
                  }
                  if (snapshot.hasData) {
                    whoseTurn = '';
                    String symbol = widget.isHost ? 'X' : 'O';
                    if(snapshot.data!.turn==0&&symbol=='X'){
                      whoseTurn = 'Opponent\'s Turn';
                    }
                    else if(snapshot.data!.turn==1&&symbol=='O'){
                      whoseTurn = 'Opponent\'s Turn';
                    }
                    else{
                      whoseTurn = 'Your\'s Turn';
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      updateGameBoard(snapshot.data!);
                    });
                  }
                  return TurnIndicator(turnMessage: whoseTurn);
                },
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(4),
                child:  OnlyOnePointerRecognizerWidget(
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
            ],
          ),
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
  void updateGameBoard(Room room) {

    setState(() {
      //along the gameBoard we will also update the turn
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
  void checkWin(String winner) {
    String symbol = widget.isHost ? 'X' : 'O'; // Assuming 'X' for host and 'O' for opponent
    String who = '';

    if(winner=="Draw"){
      AwesomeDialog(
        context: context,
        dialogType: DialogType.infoReverse,
        animType: AnimType.bottomSlide,
        title: 'Match Drawn🤦‍♂️!',
        desc: 'Try Again',
        headerAnimationLoop: false,
        btnCancel: ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SelectDifficultyScreen()),
                  (route) => false,
            );
          },
          child: const Text('Back'),
        ),
        btnOkOnPress: () {
          resetGame();
        },
      ).show();
      return;
    }
    else if (winner == symbol) {
      who = 'You Won';
    } else {
      who = 'You Loss';
    }
    AwesomeDialog(
      context: context,
      dialogType: who=='You Won'?DialogType.success:DialogType.error,
      animType: AnimType.bottomSlide,
      title: '$who!',
      desc: 'Play Again',
      headerAnimationLoop: false,
      btnCancel: ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SelectDifficultyScreen()),
                (route) => false,
          );
        },
        child: const Text('Back'),
      ),
      btnOkOnPress: () {
        resetGame();
      },
    ).show();
  }
  void resetGame() {
    final multiplayerService =
        Provider.of<MultiplayerService>(context, listen: false);
    multiplayerService.resetGame(widget.room.code);
  }
}


class TurnIndicator extends StatelessWidget {
  final String turnMessage;

  TurnIndicator({required this.turnMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        turnMessage,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}