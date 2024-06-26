import 'package:flutter/material.dart';

class GameLogic {
  static List<List<String>> initializeGameBoard() {
    var gameBoard =
    List<List<String>>.generate(3, (_) => List<String>.filled(3, ''));
    return gameBoard;
  }
  static void checkWin(List<List<String>> gameBoard,context) {
    String winner = '';
    if (gameBoard[0][0] == gameBoard[0][1] &&
        gameBoard[0][0] == gameBoard[0][2] &&
        gameBoard[0][0].isNotEmpty) {
      winner = gameBoard[0][0];
     // animateWin(0, 0, 0, 1, 0, 2);
    } else if (gameBoard[1][0] == gameBoard[1][1] &&
        gameBoard[1][0] == gameBoard[1][2] &&
        gameBoard[1][0].isNotEmpty) {
      winner = gameBoard[1][0];
      //animateWin(1, 0, 1, 1, 1, 2);
    } else if (gameBoard[2][0] == gameBoard[2][1] &&
        gameBoard[2][0] == gameBoard[2][2] &&
        gameBoard[2][0].isNotEmpty) {
      winner = gameBoard[2][0];
     // animateWin(2, 0, 2, 1, 2, 2);
    } else if (gameBoard[0][0] == gameBoard[1][0] &&
        gameBoard[0][0] == gameBoard[2][0] &&
        gameBoard[0][0].isNotEmpty) {
      winner = gameBoard[0][0];
     // animateWin(0, 0, 1, 0, 2, 0);
    } else if (gameBoard[0][1] == gameBoard[1][1] &&
        gameBoard[0][1] == gameBoard[2][1] &&
        gameBoard[0][1].isNotEmpty) {
      winner = gameBoard[0][1];
     // animateWin(0, 1, 1, 1, 2, 1);
    } else if (gameBoard[0][2] == gameBoard[1][2] &&
        gameBoard[0][2] == gameBoard[2][2] &&
        gameBoard[0][2].isNotEmpty) {
      winner = gameBoard[0][2];
    //  animateWin(0, 2, 1, 2, 2, 2);
    } else if (gameBoard[0][0] == gameBoard[1][1] &&
        gameBoard[0][0] == gameBoard[2][2] &&
        gameBoard[0][0].isNotEmpty) {
      winner = gameBoard[0][0];
     // animateWin(0, 0, 1, 1, 2, 2);
    } else if (gameBoard[0][2] == gameBoard[1][1] &&
        gameBoard[0][2] == gameBoard[2][0] &&
        gameBoard[0][2].isNotEmpty) {
      winner = gameBoard[0][2];
     // animateWin(0, 2, 1, 1, 2, 0);
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
                // resetGame();
                Navigator.pop(context);
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    } else if (isBoardFull(gameBoard)) {
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
               // resetGame();
                Navigator.pop(context);
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }
  }

  static bool isBoardFull(List<List<String>> board) {
    for (var row in board) {
      for (var cell in row) {
        if (cell.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  bool checkWinningMove(gameBoard, String player) {
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
  static List<List<String>> updateGameBoard(
      List<List<String>> gameBoard, int rowIndex, int colIndex, String player) {
    gameBoard[rowIndex][colIndex] = player;
    return gameBoard;
  }
}