import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                Text(
                  'Select Mode to continue',
                  style: TextStyle(
                    fontFamily: 'PermanentMarker',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(
                  height: 40.h,
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
                SizedBox(
                  height: 20.h,
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
                SizedBox(
                  height: 20.h,
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

  Widget buildButton(String text, voidCallback) {
    return SizedBox(
      height: 120.h,
      child: ElevatedButton(
        onPressed: voidCallback,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.h),
            ),
          ),
        ),
        child: ListTile(
          splashColor: colorDecider(text),
          leading: Container(
            height: 80.h,
            width: 60.w,
            decoration: BoxDecoration(
              color: colorDecider(text),
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
                width: 30.w,
              ),
              Text(
                text,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 24.sp,
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
