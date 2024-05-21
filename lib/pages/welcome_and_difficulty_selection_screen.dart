import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            padding: EdgeInsets.symmetric(
              horizontal: 50.w,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  'Tic Tak Toe',
                  style: TextStyle(
                    fontFamily: 'PermanentMarker',
                    fontSize: 40.h,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(
                  height: 20.h,
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
                SizedBox(
                  height: 40.h,
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
                SizedBox(
                  height: 20.h,
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
                SizedBox(
                  height: 20.h,
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
                SizedBox(
                  height: 20.h,
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
      height: 120.h,
      child: ElevatedButton(
        onPressed: voidCallback,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ),
        child: ListTile(
          leading: Container(
            height: 50.h,
            width: 50.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Icon(
              Icons.circle_outlined,
              color: Colors.white,
            ),
          ),
          title: Row(
            children: [
              SizedBox(
                width: 10.w,
              ),
              Text(
                text,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 23.sp,
                  fontFamily: 'PermanentMarker',
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
