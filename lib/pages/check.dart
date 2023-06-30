// import 'package:flutter/material.dart';
// import 'dart:math';
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
//   late List<List<String>> gameBoard;
//   late bool isPlayer1;
//   late AnimationController _symbolAnimationController;
//   late Animation<double> _symbolAnimation;
//   late AnimationController _winAnimationController;
//   late String ai;
//
//   @override
//   void initState() {
//     super.initState();
//     initializeBoard();
//     isPlayer1 = true;
//     _symbolAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _symbolAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _symbolAnimationController,
//         curve: Curves.easeOut,
//       ),
//     );
//     _winAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//   }
//
//   @override
//   void dispose() {
//     _symbolAnimationController.dispose();
//     _winAnimationController.dispose();
//     super.dispose();
//   }
//
//   void initializeBoard() {
//     gameBoard =
//     List<List<String>>.generate(3, (_) => List<String>.filled(3, ''));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tic Tac Toe'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             GridView.builder(
//               shrinkWrap: true,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//               ),
//               itemBuilder: (context, index) {
//                 final rowIndex = index ~/ 3;
//                 final colIndex = index % 3;
//                 final cellValue = gameBoard[rowIndex][colIndex];
//                 return buildGridCell(rowIndex, colIndex, cellValue);
//               },
//               itemCount: 9,
//             ),
//             ElevatedButton(
//               onPressed: resetGame,
//               child: Text('Reset'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget buildGridCell(int rowIndex, int colIndex, String cellValue) {
//     return GestureDetector(
//       onTap: () {
//         if (cellValue.isEmpty) {
//           setState(() {
//             if (isPlayer1) {
//               gameBoard[rowIndex][colIndex] = 'X';
//               isPlayer1 = false;
//             }
//             checkWin();
//             if (!isPlayer1) {
//               ai.makeMove(gameBoard);
//               checkWin();
//               isPlayer1 = true;
//             }
//           });
//         }
//       },
//       child: AnimatedBuilder(
//         animation: _symbolAnimationController,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: _symbolAnimation.value,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 border: Border.all(
//                   color: Colors.black,
//                   width: 2.0,
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   cellValue,
//                   style: TextStyle(
//                     fontSize: 48.0,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void aiMove() {
//     int bestScore = -9999;
//     int bestRow = -1;
//     int bestCol = -1;
//     for (int i = 0; i < 3; i++) {
//       for (int j = 0; j < 3; j++) {
//         if (gameBoard[i][j].isEmpty) {
//           gameBoard[i][j] = 'O';
//           int score = minimax(gameBoard, 0, false);
//           gameBoard[i][j] = '';
//           if (score > bestScore) {
//             bestScore = score;
//             bestRow = i;
//             bestCol = j;
//           }
//         }
//       }
//     }
//
//     // Make the AI move
//     gameBoard[bestRow][bestCol] = 'O';
//
//     // Update the turn
//     isPlayer1 = true;
//
//     checkWin();
//   }
//
//   int minimax(List<List<String>> board, int depth, bool isMaximizing) {
//     int score = evaluate(board);
//     if (score == 10) {
//       return score - depth;
//     }
//     if (score == -10) {
//       return score + depth;
//     }
//     if (!isMovesLeft(board)) {
//       return 0;
//     }
//
//     if (isMaximizing) {
//       int bestScore = -9999;
//       for (int i = 0; i < 3; i++) {
//         for (int j = 0; j < 3; j++) {
//           if (board[i][j].isEmpty) {
//             board[i][j] = 'O';
//             int currentScore = minimax(board, depth + 1, !isMaximizing);
//             board[i][j] = '';
//             bestScore = max(bestScore, currentScore);
//           }
//         }
//       }
//       return bestScore;
//     } else {
//       int bestScore = 9999;
//       for (int i = 0; i < 3; i++) {
//         for (int j = 0; j < 3; j++) {
//           if (board[i][j].isEmpty) {
//             board[i][j] = 'X';
//             int currentScore = minimax(board, depth + 1, !isMaximizing);
//             board[i][j] = '';
//             bestScore = min(bestScore, currentScore);
//           }
//         }
//       }
//       return bestScore;
//     }
//   }
//
//   int evaluate(List<List<String>> board) {
//     for (int row = 0; row < 3; row++) {
//       if (board[row][0] == board[row][1] && board[row][1] == board[row][2]) {
//         if (board[row][0] == 'O') {
//           return 10;
//         } else if (board[row][0] == 'X') {
//           return -10;
//         }
//       }
//     }
//
//     for (int col = 0; col < 3; col++) {
//       if (board[0][col] == board[1][col] && board[1][col] == board[2][col]) {
//         if (board[0][col] == 'O') {
//           return 10;
//         } else if (board[0][col] == 'X') {
//           return -10;
//         }
//       }
//     }
//
//     if (board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
//       if (board[0][0] == 'O') {
//         return 10;
//       } else if (board[0][0] == 'X') {
//         return -10;
//       }
//     }
//
//     if (board[0][2] == board[1][1] && board[1][1] == board[2][0]) {
//       if (board[0][2] == 'O') {
//         return 10;
//       } else if (board[0][2] == 'X') {
//         return -10;
//       }
//     }
//
//     return 0;
//   }
//
//   bool isMovesLeft(List<List<String>> board) {
//     for (int row = 0; row < 3; row++) {
//       for (int col = 0; col < 3; col++) {
//         if (board[row][col].isEmpty) {
//           return true;
//         }
//       }
//     }
//     return false;
//   }
//
//   void checkWin() {
//     String winner = '';
//     if (gameBoard[0][0] == gameBoard[0][1] &&
//         gameBoard[0][0] == gameBoard[0][2] &&
//         gameBoard[0][0].isNotEmpty) {
//       winner = gameBoard[0][0];
//       animateWin(0, 0, 0, 1, 0, 2);
//     } else if (gameBoard[1][0] == gameBoard[1][1] &&
//         gameBoard[1][0] == gameBoard[1][2] &&
//         gameBoard[1][0].isNotEmpty) {
//       winner = gameBoard[1][0];
//       animateWin(1, 0, 1, 1, 1, 2);
//     } else if (gameBoard[2][0] == gameBoard[2][1] &&
//         gameBoard[2][0] == gameBoard[2][2] &&
//         gameBoard[2][0].isNotEmpty) {
//       winner = gameBoard[2][0];
//       animateWin(2, 0, 2, 1, 2, 2);
//     } else if (gameBoard[0][0] == gameBoard[1][0] &&
//         gameBoard[0][0] == gameBoard[2][0] &&
//         gameBoard[0][0].isNotEmpty) {
//       winner = gameBoard[0][0];
//       animateWin(0, 0, 1, 0, 2, 0);
//     } else if (gameBoard[0][1] == gameBoard[1][1] &&
//         gameBoard[0][1] == gameBoard[2][1] &&
//         gameBoard[0][1].isNotEmpty) {
//       winner = gameBoard[0][1];
//       animateWin(0, 1, 1, 1, 2, 1);
//     } else if (gameBoard[0][2] == gameBoard[1][2] &&
//         gameBoard[0][2] == gameBoard[2][2] &&
//         gameBoard[0][2].isNotEmpty) {
//       winner = gameBoard[0][2];
//       animateWin(0, 2, 1, 2, 2, 2);
//     } else if (gameBoard[0][0] == gameBoard[1][1] &&
//         gameBoard[0][0] == gameBoard[2][2] &&
//         gameBoard[0][0].isNotEmpty) {
//       winner = gameBoard[0][0];
//       animateWin(0, 0, 1, 1, 2, 2);
//     } else if (gameBoard[0][2] == gameBoard[1][1] &&
//         gameBoard[0][2] == gameBoard[2][0] &&
//         gameBoard[0][2].isNotEmpty) {
//       winner = gameBoard[0][2];
//       animateWin(0, 2, 1, 1, 2, 0);
//     }
//
//     if (winner.isNotEmpty) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => AlertDialog(
//           title: Text('Game Over'),
//           content: Text('$winner wins!'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 resetGame();
//                 Navigator.pop(context);
//               },
//               child: Text('Play Again'),
//             ),
//           ],
//         ),
//       );
//     } else if (isBoardFull()) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => AlertDialog(
//           title: Text('Game Over'),
//           content: Text('It\'s a tie!'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 resetGame();
//                 Navigator.pop(context);
//               },
//               child: Text('Play Again'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   void animateWin(int row1, int col1, int row2, int col2, int row3, int col3) {
//     final winAnimation = CurvedAnimation(
//       parent: _winAnimationController,
//       curve: Curves.easeOut,
//     );
//     _winAnimationController.reset();
//     _winAnimationController.forward();
//     gameBoard[row1][col1] += '_win';
//     gameBoard[row2][col2] += '_win';
//     gameBoard[row3][col3] += '_win';
//   }
//
//   bool isBoardFull() {
//     for (var row in gameBoard) {
//       for (var cell in row) {
//         if (cell.isEmpty) {
//           return false;
//         }
//       }
//     }
//     return true;
//   }
//
//   void resetGame() {
//     setState(() {
//       initializeBoard();
//       isPlayer1 = true;
//     });
//   }
//
// }