import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin:isPlayer1?const Color(0xffD001FE):const Color(0xffFECB01),
      end: isPlayer1?const Color(0xffD001FE):const Color(0xffFECB01),
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
    if(widget.turnMessage == 'Player 1 Turn'|| widget.turnMessage == 'Your\'s Turn') {
      setState(() {
        isPlayer1 = true;
      });
    }else{
      setState(() {
        isPlayer1 = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical:20.h),
          margin: EdgeInsets.symmetric(horizontal: 50.w,vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _colorAnimation.value!.withOpacity(0.8),
                _colorAnimation.value!,
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
