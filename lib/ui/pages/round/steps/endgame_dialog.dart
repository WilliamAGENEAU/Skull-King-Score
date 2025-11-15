// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:confetti/confetti.dart';

void showEndGameDialog(
  BuildContext context,
  List<MapEntry<String, int>> winners,
  Map<String, Map<String, dynamic>> roundResults,
  ConfettiController confettiController,
) {
  confettiController.play();

  final winnerNames = winners.map((w) => w.key).join(', ');
  final winnerScore = winners.first.value;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Stack(
      alignment: Alignment.center,
      children: [
        ConfettiWidget(
          confettiController: confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: 0.05,
          numberOfParticles: 25,
          gravity: 0.15,
          colors: const [
            Colors.amber,
            Colors.white,
            Colors.orange,
            Colors.yellow,
          ],
        ),
        AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          content: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/tresor.png',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.32,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.32,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🎉 Fin de la partie 🎉',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SvgPicture.asset(
                      'assets/svg/crown.svg',
                      width: 60,
                      height: 60,
                      colorFilter: const ColorFilter.mode(
                        Colors.amber,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Vainqueur${winners.length > 1 ? 's' : ''} : $winnerNames",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "$winnerScore points",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Colors.amberAccent.withOpacity(0.6),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, roundResults);
                      },
                      child: const Text(
                        "Voir les scores",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
