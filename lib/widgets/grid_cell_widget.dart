import 'package:flutter/material.dart';
class GridCell extends StatelessWidget {
  final int rowIndex;
  final int colIndex;
  final String cellValue;
  final Function() onTap;
  final Function(ScaleStartDetails) onScaleStart;

  const GridCell({
    Key? key,
    required this.rowIndex,
    required this.colIndex,
    required this.cellValue,
    required this.onTap,
    required this.onScaleStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isWinningMove = cellValue.endsWith('_win');
    return GestureDetector(
      onTap: onTap,
      onScaleStart: onScaleStart,
      child: Transform.scale(
        scale: isWinningMove ? 0.9 : 0.8,
        child: Container(
          decoration: BoxDecoration(
            color: isWinningMove ? Colors.green : Colors.blue,
            borderRadius: isWinningMove
                ? BorderRadius.circular(4)
                : BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              cellValue.replaceAll('_win', ''),
              style: const TextStyle(
                fontSize: 48.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}