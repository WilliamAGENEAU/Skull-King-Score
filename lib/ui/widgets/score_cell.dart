import 'package:flutter/material.dart';

class ScoreCell extends StatelessWidget {
  final int? mise;
  final int? plis;
  final int? points;
  final int? bonus;
  final int? total;
  final int? cumul;
  final bool isPastRound; // ✅ nouvelle propriété

  const ScoreCell({
    super.key,
    this.mise,
    this.plis,
    this.points,
    this.bonus,
    this.total,
    this.cumul,
    this.isPastRound = false,
  });

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 13,
      color: Colors.black, // ✅ tous les textes en noir
    );

    return AspectRatio(
      aspectRatio: 1.32,
      child: Column(
        children: [
          // --- Ligne du haut : Mise / Points / Bonus ---
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // --- Case 1 : Mise / Plis ---
                Expanded(
                  flex: 2,
                  child: CustomPaint(
                    painter: _DiagonalBoxPainter(), // ✅ diagonale inversée
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment:
                                Alignment.centerLeft, // 🔥 mise un peu à gauche
                            child: Text(
                              mise?.toString() ?? '',
                              style: textStyle,
                            ),
                          ),
                          Align(
                            alignment: Alignment
                                .centerRight, // 🔥 plis un peu à droite
                            child: Text(
                              plis?.toString() ?? '',
                              style: textStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- Case 2 : Points ---
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54, width: 0.8),
                    ),
                    child: Center(
                      child: Text(points?.toString() ?? '', style: textStyle),
                    ),
                  ),
                ),

                // --- Case 3 : Bonus ---
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54, width: 0.8),
                    ),
                    child: Center(
                      child: Text(
                        bonus != null && bonus! > 0 ? "+$bonus" : '',
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Ligne du bas : Total / Cumul ---
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // --- Case 4 : Total de la manche ---
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54, width: 0.8),
                    ),
                    child: Center(
                      child: Text(total?.toString() ?? '', style: textStyle),
                    ),
                  ),
                ),

                // --- Case 5 : Cumul total ---
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54, width: 0.8),
                    ),
                    child: Center(
                      child: Text(
                        // ✅ n’afficher le cumul que pour les manches passées
                        isPastRound && cumul != null ? cumul.toString() : '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
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

/// --- PEINTURE POUR LA CASE DIAGONALE (inversée) ---
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
    // ✅ Diagonale inversée (bas gauche → haut droite)
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      diagonalPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
