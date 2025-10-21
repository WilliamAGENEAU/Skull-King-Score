import 'package:flutter/material.dart';

/// --- WIDGET DE CELLULE ---
class ScoreCell extends StatelessWidget {
  const ScoreCell({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.34, // pour garder une belle forme carrée
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomPaint(
                    painter: _DiagonalBoxPainter(),
                    child: Container(),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54, width: 0.8),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54, width: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54, width: 0.8),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54, width: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// --- PEINTURE POUR LA CASE DIAGONALE ---
class _DiagonalBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final Paint diagonalPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Bordure
    canvas.drawRect(rect, borderPaint);
    // Diagonale
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, size.height),
      diagonalPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
