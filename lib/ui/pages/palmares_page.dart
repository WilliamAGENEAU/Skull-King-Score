// ignore_for_file: use_build_context_synchronously, deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:skull_king/ui/widgets/score_analysis_chart.dart';
import 'package:skull_king/utils/save_winners.dart';

class PalmaresPage extends StatefulWidget {
  const PalmaresPage({super.key});

  @override
  State<PalmaresPage> createState() => _PalmaresPageState();
}

class _PalmaresPageState extends State<PalmaresPage> {
  List<Map<String, dynamic>> winnersHistory = [];
  Map<String, int> playerWins = {};
  Map<String, int> playerGames = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await loadWinnersHistory();
    final Map<String, int> winCount = {};
    final Map<String, int> gamesCount = {};

    for (var game in history) {
      final winners = List<Map<String, dynamic>>.from(game['winners']);
      final allPlayers = List<Map<String, dynamic>>.from(
        game['players'] ?? winners,
      );

      for (var winner in winners) {
        winCount[winner['name']] = (winCount[winner['name']] ?? 0) + 1;
      }
      for (var player in allPlayers) {
        gamesCount[player['name']] = (gamesCount[player['name']] ?? 0) + 1;
      }
    }

    setState(() {
      winnersHistory = history.reversed.toList();
      playerWins = winCount;
      playerGames = gamesCount;
    });
  }

  Future<void> _deleteGame(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer cette partie ?"),
        content: const Text(
          "Êtes-vous sûr de vouloir supprimer cet enregistrement ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteGameFromHistory(winnersHistory.length - 1 - index);
      await _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/papier.jpg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Text(
                  "Palmarès",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),

                if (playerWins.isNotEmpty)
                  _buildPodiumSection()
                else
                  const Text(
                    "Aucune partie enregistrée.",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),

                const SizedBox(height: 20),
                const Text(
                  "Historique des parties",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: winnersHistory.isEmpty
                      ? const Center(
                          child: Text(
                            "Aucun historique de parties.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: winnersHistory.length,
                          itemBuilder: (context, index) {
                            final game = winnersHistory[index];
                            final date = DateTime.parse(game['date']);
                            final winners = List<Map<String, dynamic>>.from(
                              game['winners'],
                            );
                            final allPlayers = List<Map<String, dynamic>>.from(
                              game['players'] ?? winners,
                            );
                            dynamic rawRounds =
                                game['roundsData'] ??
                                game['scores'] ??
                                game['rounds'] ??
                                [];

                            List<Map<String, dynamic>> roundsData = [];

                            if (rawRounds is Map) {
                              for (var entry in rawRounds.entries) {
                                final roundNum = int.tryParse(entry.key) ?? 0;
                                final roundScores = <String, dynamic>{};

                                // 🔹 On cherche les scores dans chaque joueur
                                (entry.value as Map).forEach((player, data) {
                                  if (data is Map) {
                                    // On privilégie le total de points, sinon points, sinon 0
                                    roundScores[player] =
                                        data['total'] ?? data['points'] ?? 0;
                                  } else if (data is num) {
                                    roundScores[player] = data;
                                  }
                                });

                                roundsData.add({
                                  'round': roundNum,
                                  'scores': roundScores,
                                });
                              }

                              // 🔹 On trie les manches
                              roundsData.sort(
                                (a, b) => (a['round'] as int).compareTo(
                                  b['round'] as int,
                                ),
                              );
                            } else if (rawRounds is List) {
                              // Déjà sous forme de liste
                              roundsData = List<Map<String, dynamic>>.from(
                                rawRounds,
                              );
                            }

                            allPlayers.sort(
                              (a, b) =>
                                  (b['score'] ?? 0).compareTo(a['score'] ?? 0),
                            );

                            final score = winners.first['score'] ?? 0;
                            final names = winners
                                .map((e) => e['name'])
                                .join(', ');

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black54),
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                  expansionTileTheme:
                                      const ExpansionTileThemeData(
                                        iconColor: Colors.black,
                                        collapsedIconColor: Colors.black,
                                      ),
                                ),
                                child: ExpansionTile(
                                  collapsedBackgroundColor: Colors.black
                                      .withOpacity(0.0),
                                  backgroundColor: Colors.white.withOpacity(
                                    0.1,
                                  ),
                                  title: Text(
                                    "${date.day}/${date.month}/${date.year} - Victoire : $names ($score pts)",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: [
                                    const Divider(color: Colors.black),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: ScoreAnalysisChart(
                                        allPlayers: allPlayers,
                                        roundsData: roundsData,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton.icon(
                                      onPressed: () => _deleteGame(index),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        "Supprimer",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSection() {
    // 🔹 Trie par winrate décroissant
    final sorted = playerWins.keys.toList()
      ..sort((a, b) {
        final winRateA = playerWins[a]! / (playerGames[a] ?? 1);
        final winRateB = playerWins[b]! / (playerGames[b] ?? 1);
        return winRateB.compareTo(winRateA);
      });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Text(
            "Meilleurs joueurs",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 230,
            child: ListView.builder(
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final name = sorted[index];
                final wins = playerWins[name] ?? 0;
                final games = playerGames[name] ?? 1;
                final ratio = (wins / games * 100).toStringAsFixed(1);

                String medal = "";
                if (index == 0)
                  medal = "🥇";
                else if (index == 1)
                  medal = "🥈";
                else if (index == 2)
                  medal = "🥉";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black54),
                      color: Colors.white.withOpacity(0.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (medal.isNotEmpty)
                              Text(
                                "$medal ",
                                style: const TextStyle(fontSize: 20),
                              ),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "$wins / $games victoire${wins > 1 ? 's' : ''} ($ratio%)",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
