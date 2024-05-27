import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';

class TurnIndicator extends StatefulWidget {
  final String turnMessage;

  const TurnIndicator({super.key, required this.turnMessage});

  @override
  State<TurnIndicator> createState() => _TurnIndicatorState();
}

class _TurnIndicatorState extends State<TurnIndicator>
    with SingleTickerProviderStateMixin {
  bool isPlayer1 = false;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _colorAnimation2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: primaryColor,
      end: primaryColor.withOpacity(0.6),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _colorAnimation2 = ColorTween(
      begin: secondaryColor,
      end: secondaryColor.withOpacity(0.7),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TurnIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.turnMessage != oldWidget.turnMessage) {
      _colorAnimation = ColorTween(
        begin: primaryColor,
        end: primaryColor.withOpacity(0.6),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _colorAnimation2 = ColorTween(
        begin: secondaryColor,
        end: secondaryColor.withOpacity(0.6),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPurpleOrNot = widget.turnMessage == 'Player 1 Turn' || widget.turnMessage == 'Your\'s Turn' ?true: false;
    return AnimatedBuilder(
      animation: isPurpleOrNot?_colorAnimation:_colorAnimation2,
      builder: (context, child) {
        return Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: 20.h),
          margin: EdgeInsets.symmetric(horizontal: 50.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isPurpleOrNot?_colorAnimation.value!.withOpacity(0.8):_colorAnimation2.value!.withOpacity(0.8),
                isPurpleOrNot?_colorAnimation.value!:_colorAnimation2.value!,
              ],
            ),
          ),
          child: Center(
            child: Text(
              widget.turnMessage,
              style: TextStyle(
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
