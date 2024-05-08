import 'package:flutter/material.dart';

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
          isHost ? 'assets/images/cross.png' : 'assets/images/circle.png',
        ),
        const Center(
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
        buildPlayerColumn(
          'Opponent',
          isHost ? 'assets/images/circle.png' : 'assets/images/cross.png',
        ),
      ],
    );
  }

  Column buildPlayerColumn(name, image) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 50,
          backgroundImage: AssetImage(image),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'PermanentMarker',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
