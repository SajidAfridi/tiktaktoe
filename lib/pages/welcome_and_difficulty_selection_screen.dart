import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tiktaktoe/pages/ai_choices_screen.dart';
import 'package:tiktaktoe/pages/join_or_create_screen.dart';

import 'offline_play_with_friend_screen.dart';

class SelectDifficultyScreen extends StatefulWidget {
  const SelectDifficultyScreen({super.key});

  @override
  State<SelectDifficultyScreen> createState() => _SelectDifficultyScreenState();
}

class _SelectDifficultyScreenState extends State<SelectDifficultyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/bg_image.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Tic Tak Toe',
                  style: TextStyle(
                    fontFamily: 'PermanentMarker',
                    fontSize: 40,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Select Your Opponent\nTo Continue',
                  style: TextStyle(
                    fontFamily: 'PermanentMarker',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 40,
                ),
                buildButton(
                  'Play With AI',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AIModeScreen(),
                      ),
                    );
                  },
                  Colors.green,
                ),
                const SizedBox(
                  height: 20,
                ),
                buildButton(
                  'Play With \nFriend Offline',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const YouVsFriendScreen(),
                      ),
                    );
                  },
                  Colors.blue,
                ),
                const SizedBox(
                  height: 20,
                ),
                buildButton(
                  'Play With\nFriend Online',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateOrJoinScreen(),
                      ),
                    );
                  },
                  Colors.red,
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButton(String text, voidCallback, color) {
    return SizedBox(
      height: 80,
      child: ElevatedButton(
        onPressed: voidCallback,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: ListTile(
          leading: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.circle_outlined,
              color: Colors.white,
            ),
          ),
          title: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              AutoSizeText(
                text,
                maxLines: 2,
                maxFontSize: 30,
                minFontSize: 10,
                style: const TextStyle(
                  fontFamily: 'PermanentMarker',
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  randomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }
}
