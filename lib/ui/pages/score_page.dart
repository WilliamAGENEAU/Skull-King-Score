// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:skull_king/theme/app_theme.dart';
import 'package:skull_king/ui/pages/home_page.dart';
import 'package:skull_king/ui/pages/round/round_page.dart';
import 'package:skull_king/ui/widgets/current_chart_game.dart';
import 'package:skull_king/ui/widgets/score_table.dart';
import 'package:skull_king/utils/save_winners.dart'; // ✅ pour sauvegarder les parties

class ScorePage extends StatefulWidget {
  final List<String> players;

  const ScorePage({super.key, required this.players});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  int currentRound = 1;
  final Map<int, Map<String, Map<String, dynamic>>> allScores = {};
  final Map<String, int> totalScores = {}; // ✅ suivi total des scores

  @override
  void initState() {
    super.initState();
    for (var player in widget.players) {
      totalScores[player] = 0;
    }
  }

  void _openGraphPopup() {
    // Convertit allScores → format exploitable par le graphique
    allScores.entries.map((e) {
      return {
        "round": e.key,
        "scores": e.value.map(
          (player, data) => MapEntry(player, data["score"] ?? 0),
        ),
      };
    }).toList();

    widget.players.map((p) {
      return {"name": p, "score": totalScores[p] ?? 0};
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        final List<Map<String, int>> convertedScores = [];

        allScores.forEach((roundIndex, playerData) {
          final scoreMap = <String, int>{};

          playerData.forEach((player, info) {
            scoreMap[player] =
                info["total"] as int; // on prend la valeur finale de la manche
          });

          convertedScores.add(scoreMap);
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              // Papier en fond
              Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage("assets/images/papier.jpg"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: CurrentGameChart(
                    allScores: allScores, // Map<int, Map<String, dynamic>>
                    players: widget.players,
                    currentRound: currentRound,
                  ),
                ),
              ),

              // Bouton fermer
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  /// ✅ Calcule les scores finaux et enregistre la partie
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

    await saveWinners(
      winners: winners,
      players: allPlayers, // liste finale (name + score)
      rounds: allScores, // ton Map<int, Map<String, Map<String,dynamic>>>
    );

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
    final bool isLastRound = currentRound > 10;

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

          /// --- Bouton Graphique ---
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.show_chart,
                    color: Colors.black,
                    size: 34,
                  ),
                  onPressed: _openGraphPopup,
                ),
              ),
            ),
          ),

          /// --- Contenu principal ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: ScoreTable(
                players: widget.players,
                currentRound: currentRound,
                allScores: allScores,
              ),
            ),
          ),

          /// --- Bouton bas droit ---
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton.icon(
                  icon: Icon(
                    isLastRound ? Icons.flag : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  label: Text(
                    isLastRound ? 'Terminer la partie' : 'Manche $currentRound',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (!isLastRound) {
                      // --- Lance la manche suivante ---
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

                          // ✅ Mise à jour des scores totaux
                          result.forEach((player, data) {
                            final int pts = (data['score'] ?? 0)
                                .toInt(); // cast sécurisé
                            totalScores[player] =
                                (totalScores[player] ?? 0) + pts;
                          });

                          currentRound++;
                        });
                      }
                    } else {
                      // --- Fin de partie ---
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
