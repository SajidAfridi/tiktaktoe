import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tiktaktoe/pages/homepage.dart';

class AIModeScreen extends StatefulWidget {
  const AIModeScreen({super.key});

  @override
  State<AIModeScreen> createState() => _SelectDifficultyScreenState();
}

class _SelectDifficultyScreenState extends State<AIModeScreen> {
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
                  'Select Mode to continue',
                  style: TextStyle(
                    fontFamily: 'PermanentMarker',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                buildButton('Easy', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyHomePage(
                        isEasyMode: true,
                        isMediumMode: false,
                        isHardMode: false,
                      ),
                    ),
                  );
                }),
                const SizedBox(
                  height: 20,
                ),
                buildButton('Medium', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyHomePage(
                        isEasyMode: false,
                        isMediumMode: true,
                        isHardMode: false,
                      ),
                    ),
                  );
                }),
                const SizedBox(
                  height: 20,
                ),
                buildButton('Hard', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyHomePage(
                        isEasyMode: false,
                        isMediumMode: false,
                        isHardMode: true,
                      ),
                    ),
                  );
                }),
                const SizedBox(
                  height: 20,
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

  Widget buildButton(String text, voidCallback) {
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
          splashColor: colorDecider(text),
          leading: Container(
            height: 80,
            width: 60,
            decoration: BoxDecoration(
              color: colorDecider(text),
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
                maxLines: 3,
                maxFontSize: 30,
                minFontSize: 22,
                style: const TextStyle(
                  fontFamily: 'PermanentMarker',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color colorDecider(String difficultyText) {
    switch (difficultyText) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      case 'Play With\nFriends':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}
