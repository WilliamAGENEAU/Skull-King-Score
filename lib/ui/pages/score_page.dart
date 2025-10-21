// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:skull_king/theme/app_theme.dart';
import 'package:skull_king/ui/pages/home_page.dart';
import 'package:skull_king/ui/pages/round_page.dart';
import 'package:skull_king/ui/widgets/score_table.dart';

class ScorePage extends StatefulWidget {
  final List<String> players;

  const ScorePage({super.key, required this.players});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  int currentRound = 1;

  void _confirmReturnToMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Retour au menu principal ?",
          style: TextStyle(color: AppTheme.primaryGold),
        ),
        content: const Text(
          "La partie en cours sera perdue.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Annuler",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            },
            child: const Text(
              "Confirmer",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// --- Image de fond ---
          Positioned.fill(
            child: Image.asset('assets/images/papier.jpg', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.08)),

          /// --- Bouton menu haut gauche ---
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  onPressed: () => _confirmReturnToMenu(context),
                  icon: const Icon(Icons.menu, color: Colors.black, size: 34),
                ),
              ),
            ),
          ),

          /// --- Contenu principal ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 80.0,
              ),
              child: Stack(
                children: [
                  /// --- Tableau des scores ---
                  Positioned.fill(
                    child: ScoreTable(
                      players: widget.players,
                      currentRound: currentRound,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// --- Bouton menu haut gauche ---
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: Text(
                    'Manche $currentRound',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoundPage(
                          roundNumber: currentRound,
                          players: widget.players,
                        ),
                      ),
                    );

                    // Si la manche est terminée, passer à la suivante
                    if (result == true && currentRound < 10) {
                      setState(() {
                        currentRound++;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 8,
                    shadowColor: AppTheme.primaryGold.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
