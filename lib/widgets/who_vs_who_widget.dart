import 'package:flutter/material.dart';

class RoundInfoWidget extends StatelessWidget {
  const RoundInfoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              radius: 50,
              backgroundImage: AssetImage('assets/images/cross.png'),
            ),
            SizedBox(height: 8),
            Text(
              'You',
              style: TextStyle(
                fontFamily: 'PermanentMarker',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Text(
              "VS",
              style: TextStyle(
                fontFamily: 'PermanentMarker',
                color: Colors.red,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 50,
              backgroundImage: AssetImage('assets/images/circle.png'),
            ),
            SizedBox(height: 8),
            Text(
              'AI',
              style: TextStyle(
                fontFamily: 'PermanentMarker',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
