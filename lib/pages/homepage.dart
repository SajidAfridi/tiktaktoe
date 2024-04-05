import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MyHomePage extends StatefulWidget {
  final bool isEasyMode;
  final bool isMediumMode;
  final bool isHardMode;

  const MyHomePage(
      {super.key,
      required this.isEasyMode,
      required this.isMediumMode,
      required this.isHardMode});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late List<List<String>> gameBoard;
  late bool isPlayer1;
  bool isProcessingMove = false;

  late AnimationController _symbolAnimationController;
  late Animation<double> _symbolAnimation;
  late AnimationController _winAnimationController;

  @override
  void initState() {
    super.initState();
    initializeBoard();
    isPlayer1 = true;
    _symbolAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _symbolAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _symbolAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _winAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _symbolAnimationController.dispose();
    _winAnimationController.dispose();
    super.dispose();
  }

  void initializeBoard() {
    gameBoard =
        List<List<String>>.generate(3, (_) => List<String>.filled(3, ''));
  }

  bool isSnackbarVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      radius: 32,
                      child: Icon(Icons.person, size: 32),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Human Player',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    "VS",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      radius: 32,
                      child: Icon(Icons.android, size: 32),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'AI Player',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
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
            ),
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    resetGame();
                  },
                  style: OutlinedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh,
                      ),
                      SizedBox(width: 20),
                      Text(
                        'Reset Game',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGridCell(int rowIndex, int colIndex, String cellValue) {
    bool isWinningMove = cellValue.endsWith('_win');
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
          aiMove(); // Move this call outside the setState block
          checkWin(); // Move this call outside the setState block
        }
      },
      child: AnimatedBuilder(
        animation: _symbolAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isWinningMove ? 0.9 : 0.8,
            child: Container(
              decoration: BoxDecoration(
                color: isWinningMove ? Colors.green : Colors.grey[200],
              ),
              child: Center(
                child: Text(
                  cellValue.replaceAll('_win', ''),
                  style: const TextStyle(
                    fontSize: 48.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
          title: const Text(
            'Game Over',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '$winner wins!',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.pop(context);
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    } else if (isBoardFull()) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
          title: const Text(
            'Game Over',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'It\'s a draw!',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.pop(context);
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }
  }

  void animateWin(int row1, int col1, int row2, int col2, int row3, int col3) {
    _winAnimationController.reset();
    _winAnimationController.forward();
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

  void aiMove() {
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
        if (checkWinningMove('O')) {
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
        if (checkWinningMove('X')) {
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
    // Find the best move using the Minimax algorithm
  }

  int minimax(List<List<String>> board, int depth, bool isMaximizing) {
    int score = evaluate(board);
    if (score == 10) {
      return score - depth;
    }
    if (score == -10) {
      return score + depth;
    }
    if (!isMovesLeft(board)) {
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

  bool isMovesLeft(List<List<String>> board) {
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (board[row][col].isEmpty) {
          return true;
        }
      }
    }
    return false;
  }

  bool checkWinningMove(String player) {
    // Check rows
    for (int row = 0; row < 3; row++) {
      if (gameBoard[row][0] == player &&
          gameBoard[row][1] == player &&
          gameBoard[row][2] == player) {
        return true;
      }
    }

    // Check columns
    for (int col = 0; col < 3; col++) {
      if (gameBoard[0][col] == player &&
          gameBoard[1][col] == player &&
          gameBoard[2][col] == player) {
        return true;
      }
    }

    // Check diagonals
    if (gameBoard[0][0] == player &&
        gameBoard[1][1] == player &&
        gameBoard[2][2] == player) {
      return true;
    }

    if (gameBoard[2][0] == player &&
        gameBoard[1][1] == player &&
        gameBoard[0][2] == player) {
      return true;
    }

    return false;
  }
}
