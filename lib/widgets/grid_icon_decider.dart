import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
Widget iconDecider(String value) {
  //bool isWinningMove = value.endsWith('_win');
  if (value.replaceAll('_win', '') == 'X') {
    return FadeOutUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          color: Colors.transparent,
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
          borderRadius: BorderRadius.circular(15.r),
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
          color:emptyGridItemColor,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: const [],
        ),
        child: const Center(child: Text('')),
      ),
    );
  }
}
