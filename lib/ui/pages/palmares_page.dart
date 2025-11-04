// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:skull_king/utils/save_winners.dart';

class PalmaresPage extends StatefulWidget {
  const PalmaresPage({super.key});

  @override
  State<PalmaresPage> createState() => _PalmaresPageState();
}

class _PalmaresPageState extends State<PalmaresPage> {
  List<Map<String, dynamic>> winnersHistory = [];
  Map<String, int> playerWins = {};
  Map<String, int> playerGames =
      {}; // 👈 nouveau pour compter les parties jouées

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

      // 🔹 Comptage des victoires
      for (var winner in winners) {
        winCount[winner['name']] = (winCount[winner['name']] ?? 0) + 1;
      }

      // 🔹 Comptage des parties jouées
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
                // --- Bouton retour ---
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // --- Titre ---
                const Text(
                  "Palmarès",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // --- Podium ---
                if (playerWins.isNotEmpty)
                  _buildPodiumSection()
                else
                  const Text(
                    "Aucune partie enregistrée.",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),

                const SizedBox(height: 20),

                // --- Historique ---
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

                            // tri des joueurs par score
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
                                    Column(
                                      children: allPlayers
                                          .map(
                                            (p) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                  ),
                                              child: Text(
                                                "${p['name']} - ${p['score']} pts",
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
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

  /// Section podium (top 3)
  Widget _buildPodiumSection() {
    final sorted = playerWins.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
          Column(
            children: sorted.take(3).map((e) {
              final name = e.key;
              final wins = e.value;
              final games =
                  playerGames[name] ??
                  wins; // si pas trouvé, assume autant de jeux que de victoires
              final ratio = (wins / games * 100).toStringAsFixed(1);

              final rank = sorted.indexOf(e) + 1;
              final medal = rank == 1
                  ? "🥇"
                  : rank == 2
                  ? "🥈"
                  : "🥉";
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
                      Text(
                        "$medal $name",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "$wins / $games victoire${wins > 1 ? 's' : ''}  ($ratio%)",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
