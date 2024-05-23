import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoundInfoWidget extends StatelessWidget {
  final bool isHost;

  const RoundInfoWidget({
    super.key,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildPlayerColumn(
          'You',
          isHost ? 'assets/images/cross.png' : 'assets/images/circle_1.png',
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 10.h,
            ),
            child: Text(
              "VS",
              style: TextStyle(
                fontFamily: 'PermanentMarker',
                color: Colors.red,
                fontSize: 50.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        buildPlayerColumn(
          'Opponent',
          isHost ? 'assets/images/circle_1.png' : 'assets/images/cross.png',
        ),
      ],
    );
  }

  Column buildPlayerColumn(name, image) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 50.r,
          backgroundImage: AssetImage(image),
        ),
        SizedBox(height: 8.h),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'PermanentMarker',
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
class RoundInfoForFriendsOffline extends StatelessWidget {
  const RoundInfoForFriendsOffline({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildPlayerColumn(
          'Player 1',
         'assets/images/cross.png',
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 10.h,
            ),
            child: Text(
              "VS",
              style: TextStyle(
                color:Colors.red,
                fontSize: 50.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        buildPlayerColumn(
          'Player 2',
         'assets/images/circle_1.png',
        ),
      ],
    );
  }

  Column buildPlayerColumn(name, image) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 50.r,
          backgroundImage: AssetImage(image),
        ),
        SizedBox(height: 8.h),
        Text(
          name,
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
