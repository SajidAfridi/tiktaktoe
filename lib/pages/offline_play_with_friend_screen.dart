import 'package:flutter/material.dart';
import 'package:action_slider/action_slider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../classes/one_tap_register_class.dart';
import '../constants/colors.dart';
import '../widgets/grid_icon_decider.dart';
import '../widgets/turn_indicator_widget.dart';
import '../widgets/who_vs_who_widget.dart';

class YouVsFriendScreen extends StatefulWidget {
  const YouVsFriendScreen({
    super.key,
  });

  @override
  State<YouVsFriendScreen> createState() => _YouVsFriendScreenState();
}

class _YouVsFriendScreenState extends State<YouVsFriendScreen>
    with TickerProviderStateMixin {
  late List<List<String>> gameBoard;
  late bool isPlayer1;
  bool isAvailableToMakeMove = true;

  @override
  void initState() {
    super.initState();
    initializeBoard();
    isPlayer1 = true;
  }

  void initializeBoard() {
    gameBoard = List<List<String>>.generate(
      3,
      (_) => List<String>.filled(
        3,
        '',
      ),
    );
  }

  bool isSnackBarVisible = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff3c0384).withOpacity(0.5),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const RoundInfoForFriendsOffline(),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.maxFinite,
                      child: TurnIndicator(
                        turnMessage:
                            isPlayer1 ? 'Player 1 Turn' : 'Player 2 Turn',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: gridContainerBackgroundColor,
                ),
                padding: const EdgeInsets.all(4),
                child: OnlyOnePointerRecognizerWidget(
                  child: GridView.builder(
                    padding: EdgeInsets.all(6.r),
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
              SizedBox(
                height: 40.h,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                  color: toggleBackgroundColor,
                ),
                child: ActionSlider.standard(
                  action: (controller) {
                    controller.reset();
                    resetGame();
                  },
                  backgroundColor: Colors.white,
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                  toggleColor: toggleColor,
                  child: Text(
                    'Slide to reset',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.sp,
                      // fontFamily: 'PermanentMarker',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGridCell(int rowIndex, int colIndex, String cellValue) {
    return GestureDetector(
      onTap: () {
        if(isAvailableToMakeMove)
          {
            if (cellValue.isEmpty) {
              setState(() {
                if (isPlayer1) {
                  gameBoard[rowIndex][colIndex] = 'X';
                } else {
                  gameBoard[rowIndex][colIndex] = 'O';
                }
                isPlayer1 = !isPlayer1;
              });
            }
        checkWin();
          }
      },
      child: Card(child: iconDecider(cellValue)),
    );
  }

  void checkWin() {
    String winner = '';
    if (gameBoard[0][0] == gameBoard[0][1] &&
        gameBoard[0][0] == gameBoard[0][2] &&
        gameBoard[0][0].isNotEmpty) {
      winner = gameBoard[0][0];
      animateWin(0, 0, 0, 1, 0, 2);
    } else if (gameBoard[1][0] == gameBoard[1][1] &&
        gameBoard[1][0] == gameBoard[1][2] &&
        gameBoard[1][0].isNotEmpty) {
      winner = gameBoard[1][0];
      animateWin(1, 0, 1, 1, 1, 2);
    } else if (gameBoard[2][0] == gameBoard[2][1] &&
        gameBoard[2][0] == gameBoard[2][2] &&
        gameBoard[2][0].isNotEmpty) {
      winner = gameBoard[2][0];
      animateWin(2, 0, 2, 1, 2, 2);
    } else if (gameBoard[0][0] == gameBoard[1][0] &&
        gameBoard[0][0] == gameBoard[2][0] &&
        gameBoard[0][0].isNotEmpty) {
      winner = gameBoard[0][0];
      animateWin(0, 0, 1, 0, 2, 0);
    } else if (gameBoard[0][1] == gameBoard[1][1] &&
        gameBoard[0][1] == gameBoard[2][1] &&
        gameBoard[0][1].isNotEmpty) {
      winner = gameBoard[0][1];
      animateWin(0, 1, 1, 1, 2, 1);
    } else if (gameBoard[0][2] == gameBoard[1][2] &&
        gameBoard[0][2] == gameBoard[2][2] &&
        gameBoard[0][2].isNotEmpty) {
      winner = gameBoard[0][2];
      animateWin(0, 2, 1, 2, 2, 2);
    } else if (gameBoard[0][0] == gameBoard[1][1] &&
        gameBoard[0][0] == gameBoard[2][2] &&
        gameBoard[0][0].isNotEmpty) {
      winner = gameBoard[0][0];
      animateWin(0, 0, 1, 1, 2, 2);
    } else if (gameBoard[0][2] == gameBoard[1][1] &&
        gameBoard[0][2] == gameBoard[2][0] &&
        gameBoard[0][2].isNotEmpty) {
      winner = gameBoard[0][2];
      animateWin(0, 2, 1, 1, 2, 0);
    }

    if (winner.isNotEmpty) {
      String who = winner == 'X' ? 'Player 1' : 'Player 2';
      AwesomeDialog(
          context: context,
          onDismissCallback: (value) {
            isAvailableToMakeMove = false;
          },
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: '$who Won!',
          desc: 'Play Again',
          headerAnimationLoop: false,
          btnOkOnPress: () {
            resetGame();
          }).show();
    } else if (isBoardFull()) {
      AwesomeDialog(
          context: context,
          onDismissCallback: (value) {
            isAvailableToMakeMove = false;
          },
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Draw',
          desc: 'Play again',
          btnOkOnPress: () {
            resetGame();
          }).show();
    }
  }
  void animateWin(int row1, int col1, int row2, int col2, int row3, int col3) {
    gameBoard[row1][col1] += '_win';
    gameBoard[row2][col2] += '_win';
    gameBoard[row3][col3] += '_win';
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
  void resetGame() {
    setState(() {
      initializeBoard();
      isPlayer1 = true;
      isAvailableToMakeMove = true;
    });
  }
}
