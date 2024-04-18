import 'dart:convert';
import 'package:action_slider/action_slider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:tiktaktoe/classes/game_logic.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../classes/one_tap_register_class.dart';

class MultiplayerScreen extends StatefulWidget {
  final bool isHost;

  const MultiplayerScreen({super.key, required this.isHost});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // const RoundInfoWidget(),
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
                    final cellValue =
                    GameLogic.initializeGameBoard()[rowIndex][colIndex];
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
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child: ActionSlider.standard(
                  action: (controller) {
                    controller.reset();
                    //resetGame();
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildGridCell(int rowIndex, int colIndex, String cellValue) {
    return GestureDetector(
      onTap: () {},
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
          child: const Center(
            child: Text(''),
          ),
        ),
      );
    }
  }
}
// Compare this snippet from lib/classes/game_logic.dart:
