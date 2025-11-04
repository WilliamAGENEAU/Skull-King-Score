// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:skull_king/theme/app_theme.dart';
import 'package:skull_king/ui/pages/home_page.dart';
import 'package:skull_king/ui/pages/round_page.dart';
import 'package:skull_king/ui/widgets/score_table.dart';
import 'package:skull_king/utils/save_winners.dart'; // ✅ pour sauvegarder

class ScorePage extends StatefulWidget {
  final List<String> players;

  const ScorePage({super.key, required this.players});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  int currentRound = 1;
  final Map<int, Map<String, Map<String, dynamic>>> allScores = {};
  final Map<String, int> totalScores = {}; // ✅ suivi total

  @override
  void initState() {
    super.initState();
    for (var player in widget.players) {
      totalScores[player] = 0;
    }
  }

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

  /// ✅ Calcule les scores finaux et les enregistre
  Future<void> _saveFinalResults() async {
    final sortedPlayers = totalScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final highestScore = sortedPlayers.first.value;
    final winners = sortedPlayers
        .where((e) => e.value == highestScore)
        .map((e) => {'name': e.key, 'score': e.value})
        .toList();

    final allPlayers = sortedPlayers
        .map((e) => {'name': e.key, 'score': e.value})
        .toList();

    await saveWinners(winners: winners, allPlayers: allPlayers);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Partie enregistrée dans le palmarès !",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: AppTheme.primaryGold,
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

          /// --- Bouton menu ---
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
                  Positioned.fill(
                    child: ScoreTable(
                      players: widget.players,
                      currentRound: currentRound,
                      allScores: allScores,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// --- Bouton "Manche suivante" ou "Terminer la partie" ---
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton.icon(
                  icon: Icon(
                    currentRound <= 10 ? Icons.play_arrow : Icons.flag,
                    color: Colors.white,
                  ),
                  label: Text(
                    currentRound <= 10
                        ? 'Manche $currentRound'
                        : 'Terminer la partie',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (currentRound <= 10) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoundPage(
                            roundNumber: currentRound,
                            players: widget.players,
                            totalScores: totalScores,
                          ),
                        ),
                      );

                      if (result != null &&
                          result is Map<String, Map<String, dynamic>>) {
                        setState(() {
                          allScores[currentRound] = result;

                          // ✅ Mise à jour des totaux
                          result.forEach((player, data) {
                            final int pts = data['total'] ?? 0;
                            totalScores[player] =
                                (totalScores[player] ?? 0) + (pts);
                          });

                          currentRound++;
                        });
                      }
                    } else {
                      await _saveFinalResults();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                        (route) => false,
                      );
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
