import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  bool isLoading = true;

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
      String winner =
          data.toString(); // Assuming the winner symbol is sent as a string
      checkWin(winner);
    });
    socket.on('Successfully Joined', (data) {
      setState(() {
        isLoading = false;
      });
      final materialBanner = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(milliseconds: 600),
        content: AwesomeSnackbarContent(
          titleFontSize: 22.sp,
          messageFontSize: 18.sp,
          title: 'Opponent Join the room!',
          message:
          'You can now start the game.',
          contentType: ContentType.success,
          // to configure for material banner
          inMaterialBanner: true,
        ),
      );
      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(materialBanner)
          .closed
          .then((_) {
        // Navigate to a new screen or perform any other action here
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const CreateOrJoinScreen()),
              (route) => false,
        );
      });
    });
    socket.on('OpponentLeft', (_) {
      final materialBanner = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        content: AwesomeSnackbarContent(
          titleFontSize: 22.sp,
          messageFontSize: 18.sp,
          title: 'Opponent exited the room!',
          message:
          'You will be navigated back to the home screen',
          contentType: ContentType.warning,
          // to configure for material banner
          inMaterialBanner: true,
        ),
      );
      ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(materialBanner)
          .closed
          .then((_) {
        // Navigate to a new screen or perform any other action here
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const CreateOrJoinScreen()),
              (route) => false,
        );
      });
    });
    // Handle the disconnection here, e.g., update UI or navigate to another screen
  }

  @override
  void dispose() {
    socket.emit('message', {
      'type': 'OpponentLeft',
      'code': widget.room.code,
      'turn': 0,
    });
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
        onWillPop(context);
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoundInfoWidget(
                isHost: widget.isHost,
              ),
              SizedBox(height: 30.h),
              if (widget.isHost)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.h,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.brown
                          .withOpacity(0.5), //Colors.brown.withOpacity(0.5),
                    ),
                    child: Text(
                      'Room Code: ${widget.room.code}',
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 16.h),
              //stream builder with the stream from the provider
              StreamBuilder<Room>(
                stream: roomUpdates,
                builder: (context, snapshot) {
                  String whoseTurn = '';
                  if (snapshot.data == null) {
                    return isLoading&&widget.isHost?
                    const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Waiting for Opponent...'),
                          SizedBox(width: 10.0),
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                          ),
                        ],
                      ),
                    )
                        :TurnIndicator(
                        turnMessage: widget.isHost
                            ? 'Your\'s turn'
                            : 'Opponent\'s turn');
                  }
                  if (snapshot.hasData) {
                    whoseTurn = 'Your\'s turn';
                    String symbol = widget.isHost ? 'X' : 'O';
                    if (snapshot.data!.turn == 0 && symbol == 'X') {
                      whoseTurn = 'Opponent\'s Turn';
                    } else if (snapshot.data!.turn == 1 && symbol == 'O') {
                      whoseTurn = 'Opponent\'s Turn';
                    } else {
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
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(4.r),
                child: OnlyOnePointerRecognizerWidget(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
      final materialBanner = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        content: AwesomeSnackbarContent(
          titleFontSize: 22.sp,
          messageFontSize: 18.sp,
          title: 'Invalid Move!',
          message:
          'Please select an empty cell to make a move.',
          contentType: ContentType.warning,
          // to configure for material banner
          inMaterialBanner: true,
        ),
      );
      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(materialBanner)
          .closed
          .then((_) {
        // Navigate to a new screen or perform any other action here
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const CreateOrJoinScreen()),
              (route) => false,
        );
      });
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
            borderRadius: BorderRadius.circular(15.r),
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
            borderRadius: BorderRadius.circular(15.r),
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
            borderRadius: BorderRadius.circular(15.r),
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
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(4.r),
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
    String symbol =
        widget.isHost ? 'X' : 'O'; // Assuming 'X' for host and 'O' for opponent
    String who = '';

    if (winner == "Draw") {
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
              MaterialPageRoute(
                  builder: (context) => const SelectDifficultyScreen()),
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
    } else if (winner == symbol) {
      who = 'You Won';
    } else {
      who = 'You Loss';
    }
    AwesomeDialog(
      context: context,
      dialogType: who == 'You Won' ? DialogType.success : DialogType.error,
      animType: AnimType.bottomSlide,
      title: '$who!',
      desc: 'Play Again',
      headerAnimationLoop: false,
      btnCancel: ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const SelectDifficultyScreen()),
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

  Future<bool> onWillPop(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 20.0, 0.0, 0.0),
              child: Text(
                'Leave Room',
                style: TextStyle(
                  fontSize: 30.0.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Icon(
                Icons.question_mark,
                size: 30.sp,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to leave the room?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateOrJoinScreen()),
                (route) => false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text(
              'Leave',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.red),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class TurnIndicator extends StatefulWidget {
  final String turnMessage;

  const TurnIndicator({super.key, required this.turnMessage});

  @override
  State<TurnIndicator> createState() => _TurnIndicatorState();
}

class _TurnIndicatorState extends State<TurnIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.lightBlue,
      end: Colors.blueAccent,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _colorAnimation.value!.withOpacity(0.8),
                _colorAnimation.value!,
              ],
            ),
          ),
          child: Text(
            widget.turnMessage,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class CustomAlertDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;

  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 16.0),
      title: title,
      content: content,
      actions: actions,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}
