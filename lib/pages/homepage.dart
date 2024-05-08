import 'package:action_slider/action_slider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:tiktaktoe/classes/game_logic.dart';
import 'dart:math';
import '../classes/one_tap_register_class.dart';
import '../widgets/who_vs_who_widget.dart';

class MyHomePage extends StatefulWidget {
  final bool isEasyMode;
  final bool isMediumMode;
  final bool isHardMode;

  const MyHomePage({
    super.key,
    required this.isEasyMode,
    required this.isMediumMode,
    required this.isHardMode,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late List<List<String>> gameBoard;
  late bool isPlayer1;
  bool isProcessingMove = false;

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
            const SizedBox(height: 16),
            const RoundInfoWidget(isHost: true,),
            const SizedBox(
              height: 16,
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
                    final rowIndex = index ~/ 3;
                    final colIndex = index % 3;
                    final cellValue = gameBoard[rowIndex][colIndex];
                    return buildGridCell(rowIndex, colIndex, cellValue);
                  },
                  itemCount: 9,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
                width: MediaQuery.of(context).size.width * 0.70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child: ActionSlider.standard(
                  action: (controller) {
                    controller.reset();
                    resetGame();
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 30,
                  ),
                  toggleColor: Colors.blue,
                  child: const Text(
                    'Reset Game',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
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
        if (cellValue.isEmpty && !isProcessingMove) {
          setState(() {
            isProcessingMove = true;
            if (isPlayer1) {
              gameBoard[rowIndex][colIndex] = 'X';
              isPlayer1 = false;
            }
          });
          if (isBoardFull()) {
            checkWin();
          }
          aiMove();
          checkWin();
        } else {
          checkWin();
        }
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
      String who = winner == 'X' ? 'You' : 'AI';
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
      isProcessingMove = false;
    });
  }

  aiMove() {
    int countEmptyCells() {
      int count = 0;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (gameBoard[i][j] == '') {
            count++;
          }
        }
      }
      return count;
    }

    if (widget.isEasyMode) {
      Random random = Random();
      int emptyCells = countEmptyCells();
      int randomIndex = random.nextInt(emptyCells);
      int count = 0;
      outerLoop:
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (gameBoard[i][j].isEmpty) {
            if (count == randomIndex) {
              gameBoard[i][j] = 'O';
              break outerLoop;
            }
            count++;
          }
        }
      }
      isProcessingMove = false;
      isPlayer1 = true;
    } else if (widget.isMediumMode) {
      int emptyCells = countEmptyCells();
      List<int> availableMoves = [];
      for (int i = 0; i < 9; i++) {
        int row = i ~/ 3;
        int col = i % 3;
        if (gameBoard[row][col].isEmpty) {
          availableMoves.add(i);
        }
      }

      // Check for winning moves
      for (int move in availableMoves) {
        int row = move ~/ 3;
        int col = move % 3;
        gameBoard[row][col] = 'O';
        if (GameLogic().checkWinningMove(gameBoard, 'O',)) {
          isPlayer1 = true;
          return;
        }
        gameBoard[row][col] = '';
      }

      // Check for blocking moves
      for (int move in availableMoves) {
        int row = move ~/ 3;
        int col = move % 3;
        gameBoard[row][col] = 'X';
        if (GameLogic().checkWinningMove(
          gameBoard,
          'X',
        )) {
          gameBoard[row][col] = 'O';
          isProcessingMove = false;
          isPlayer1 = true;
          return;
        }
        gameBoard[row][col] = '';
      }

      // If no winning or blocking moves, choose a random move
      Random random = Random();
      int randomIndex = random.nextInt(emptyCells);
      int count = 0;

      outerLoop:
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (gameBoard[i][j].isEmpty) {
            if (count == randomIndex) {
              gameBoard[i][j] = 'O';
              break outerLoop;
            }
            count++;
          }
        }
      }
      isProcessingMove = false;
      // Update the turn
      isPlayer1 = true;
    } else if (widget.isHardMode) {
      int bestScore = -9999;
      int bestRow = -1;
      int bestCol = -1;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (gameBoard[i][j].isEmpty) {
            gameBoard[i][j] = 'O';
            int score = minimax(gameBoard, 0, false);
            gameBoard[i][j] = '';
            if (score > bestScore) {
              bestScore = score;
              bestRow = i;
              bestCol = j;
            }
          }
        }
      }
      // Make the AI move
      gameBoard[bestRow][bestCol] = 'O';
      isProcessingMove = false;
      // Update the turn
      isPlayer1 = true;
    }
  }

  int minimax(List<List<String>> board, int depth, bool isMaximizing) {
    int score = evaluate(board);
    if (score == 10) {
      return score - depth;
    }
    if (score == -10) {
      return score + depth;
    }
    if (!isMovesLeft()) {
      return 0;
    }

    if (isMaximizing) {
      int bestScore = -9999;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j].isEmpty) {
            board[i][j] = 'O';
            int currentScore = minimax(board, depth + 1, !isMaximizing);
            board[i][j] = '';
            bestScore = max(bestScore, currentScore);
          }
        }
      }
      return bestScore;
    } else {
      int bestScore = 9999;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j].isEmpty) {
            board[i][j] = 'X';
            int currentScore = minimax(board, depth + 1, !isMaximizing);
            board[i][j] = '';
            bestScore = min(bestScore, currentScore);
          }
        }
      }
      return bestScore;
    }
  }

  int evaluate(List<List<String>> board) {
    for (int row = 0; row < 3; row++) {
      if (board[row][0] == board[row][1] && board[row][1] == board[row][2]) {
        if (board[row][0] == 'O') {
          return 10;
        } else if (board[row][0] == 'X') {
          return -10;
        }
      }
    }

    for (int col = 0; col < 3; col++) {
      if (board[0][col] == board[1][col] && board[1][col] == board[2][col]) {
        if (board[0][col] == 'O') {
          return 10;
        } else if (board[0][col] == 'X') {
          return -10;
        }
      }
    }

    if (board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
      if (board[0][0] == 'O') {
        return 10;
      } else if (board[0][0] == 'X') {
        return -10;
      }
    }

    if (board[0][2] == board[1][1] && board[1][1] == board[2][0]) {
      if (board[0][2] == 'O') {
        return 10;
      } else if (board[0][2] == 'X') {
        return -10;
      }
    }

    return 0;
  }

  bool isMovesLeft() {
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (gameBoard[row][col].isEmpty) {
          return true;
        }
      }
    }
    return false;
  }
}
