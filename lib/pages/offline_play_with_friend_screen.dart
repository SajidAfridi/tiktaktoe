import 'package:flutter/material.dart';
import 'package:action_slider/action_slider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../classes/one_tap_register_class.dart';
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16.h),
            const RoundInfoWidget(
              isHost: true,
            ),
            SizedBox(height: 16.h),
            Container(
              width: MediaQuery.of(context).size.width * 0.80,
              alignment: Alignment.center,
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.grey[300],
              ),
              child: Text(
                isPlayer1 ? 'X -- Turn' : 'O -- Turn',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 6.h,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
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
            SizedBox(
              height: 30.h,
            ),
            Container(
                width: MediaQuery.of(context).size.width * 0.70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                  color: Colors.white,
                ),
                child: ActionSlider.standard(
                  action: (controller) {
                    controller.reset();
                    resetGame();
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                  toggleColor: Colors.blue,
                  child: Text(
                    'Reset Game',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.sp,
                      fontFamily: 'PermanentMarker',
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget buildGridCell(int rowIndex, int colIndex, String cellValue) {
    return GestureDetector(
      onTap: () {
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
    } else if (value.replaceAll('_win', '') == 'O') {
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
      String who = winner == 'X' ? 'X' : 'O';
      AwesomeDialog(
          context: context,
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
    });
  }
}
