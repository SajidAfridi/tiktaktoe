// import 'dart:math';
//
// class AIPlayer {
//   String playerSymbol;
//   String opponentSymbol;
//
//   AIPlayer(this.playerSymbol, this.opponentSymbol);
//
//   // Method to make a move using the Minimax algorithm
//   int makeMove(List<List<String>> board) {
//     int bestScore = -1000;
//     int bestMove = -1;
//
//     for (int i = 0; i < 9; i++) {
//       int row = i ~/ 3;
//       int col = i % 3;
//
//       if (board[row][col] == '') {
//         board[row][col] = playerSymbol;
//
//         int score = minimax(board, 0, false);
//
//         board[row][col] = '';
//
//         if (score > bestScore) {
//           bestScore = score;
//           bestMove = i;
//         }
//       }
//     }
//
//     return bestMove;
//   }
//   // Minimax algorithm implementation
//   int minimax(List<List<String>> board, int depth, bool isMaximizingPlayer) {
//     if (checkWinner(playerSymbol,board)) {
//       return 10 - depth;
//     } else if (checkWinner(opponentSymbol,board)) {
//       return depth - 10;
//     } else if (isBoardFull(board)) {
//       return 0;
//     }
//
//     int bestScore = isMaximizingPlayer ? -1000 : 1000;
//
//     for (int i = 0; i < 9; i++) {
//       int row = i ~/ 3;
//       int col = i % 3;
//
//       if (board[row][col] == '') {
//         board[row][col] = isMaximizingPlayer ? playerSymbol : opponentSymbol;
//
//         int score = minimax(board, depth + 1, !isMaximizingPlayer);
//
//         board[row][col] = '';
//
//         if (isMaximizingPlayer) {
//           bestScore = max(score, bestScore);
//         } else {
//           bestScore = min(score, bestScore);
//         }
//       }
//     }
//
//     return bestScore;
//   }
//
//   bool checkWinner(String playerSymbol, List<List<String>> board) {
//     // Check rows
//     for (int row = 0; row < 3; row++) {
//       if (board[row][0] == playerSymbol &&
//           board[row][1] == playerSymbol &&
//           board[row][2] == playerSymbol) {
//         return true;
//       }
//     }
//
//     // Check columns
//     for (int col = 0; col < 3; col++) {
//       if (board[0][col] == playerSymbol &&
//           board[1][col] == playerSymbol &&
//           board[2][col] == playerSymbol) {
//         return true;
//       }
//     }
//
//     // Check diagonals
//     if (board[0][0] == playerSymbol &&
//         board[1][1] == playerSymbol &&
//         board[2][2] == playerSymbol) {
//       return true;
//     }
//
//     if (board[0][2] == playerSymbol &&
//         board[1][1] == playerSymbol &&
//         board[2][0] == playerSymbol) {
//       return true;
//     }
//
//     return false;
//   }
//
//   bool isBoardFull(List<List<String>> board) {
//     for (int row = 0; row < 3; row++) {
//       for (int col = 0; col < 3; col++) {
//         if (board[row][col] == '') {
//           return false;
//         }
//       }
//     }
//     return true;
//   }
// }
