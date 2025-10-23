// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoundPage extends StatefulWidget {
  final int roundNumber;
  final List<String> players;

  const RoundPage({
    super.key,
    required this.roundNumber,
    required this.players,
  });

  @override
  State<RoundPage> createState() => _RoundPageState();
}

class _RoundPageState extends State<RoundPage> {
  int currentStep = 0;

  late Map<String, int?> bets;
  late Map<String, int?> tricks;
  late Map<String, String?> bonuses;

  @override
  void initState() {
    super.initState();
    bets = {for (var p in widget.players) p: null};
    tricks = {for (var p in widget.players) p: null};
    bonuses = {for (var p in widget.players) p: null};
  }

  bool get allBetsSelected => bets.values.every((v) => v != null);
  bool get allTricksSelected => tricks.values.every((v) => v != null);

  void _nextStep() {
    if (currentStep < 1) setState(() => currentStep++);
  }

  void _finishRound() async {
    final Map<String, Map<String, dynamic>> roundResults = {};

    for (var player in widget.players) {
      final int bet = bets[player] ?? 0;
      final int trick = tricks[player] ?? 0;
      final int bonus = int.tryParse(bonuses[player] ?? '0') ?? 0;

      final int points = calculatePoints(
        roundNumber: widget.roundNumber,
        bet: bet,
        tricks: trick,
      );

      final int total = bonus > 0 ? points + bonus : points;

      roundResults[player] = {
        'mise': bet,
        'plis': trick,
        'points': points,
        'bonus': bonus > 0 ? bonus : null,
        'total': total,
      };
    }

    // ✅ On retourne d’abord les résultats
    Navigator.pop(context, roundResults);

    // ✅ Si c’est la dernière manche, on affiche le dialogue **après le retour**
    if (widget.roundNumber == 10) {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return; // ✅ évite le bug "widget unmounted"
      _showEndGameDialog(context, _getWinnersFromScores(roundResults));
    }
  }

  int calculatePoints({
    required int roundNumber,
    required int bet,
    required int tricks,
  }) {
    if (bet > 0 && bet == tricks) {
      return 20 * bet;
    } else if (bet > 0 && bet != tricks) {
      return -10 * (bet - tricks).abs();
    } else if (bet == 0 && bet == tricks) {
      return 10 * roundNumber;
    } else {
      return -10 * roundNumber;
    }
  }

  List<String> _getWinnersFromScores(
    Map<String, Map<String, dynamic>> results,
  ) {
    final totals = <String, int>{};
    for (var player in results.keys) {
      totals[player] = results[player]?['total'] ?? 0;
    }
    final maxScore = totals.values.reduce((a, b) => a > b ? a : b);
    return totals.entries
        .where((e) => e.value == maxScore)
        .map((e) => e.key)
        .toList();
  }

  void _showEndGameDialog(BuildContext context, List<String> winners) {
    final confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          // 🎉 Confettis en fond
          ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
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

          // 🏝️ Image de fond du trésor
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

                // 🕶️ voile sombre pour lisibilité du texte
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.32,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                // 🏆 contenu principal
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
                        winners.length > 1
                            ? "Égalité entre :\n${winners.join(', ')}"
                            : "${winners.first} remporte la partie ! 🏆",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
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
                          Navigator.pop(context); // ✅ on ferme juste le dialog
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
    ).then((_) {
      // ✅ On ne le libère qu'ici, une seule fois
      confettiController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.roundNumber;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/papier.jpg', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.05)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  Text(
                    "Manche $round",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.black,
                          onPrimary: Colors.white,
                        ),
                        canvasColor: Colors.transparent,
                      ),
                      child: Stepper(
                        type: StepperType.vertical,
                        currentStep: currentStep,
                        margin: EdgeInsets.zero,
                        controlsBuilder: (_, _) => const SizedBox.shrink(),
                        onStepContinue: () {
                          if (currentStep == 0 && allBetsSelected) {
                            _nextStep();
                          }
                        },
                        steps: [
                          Step(
                            title: const Text(
                              'Mise',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            isActive: currentStep >= 0,
                            state: allBetsSelected
                                ? StepState.complete
                                : StepState.indexed,
                            content: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _buildBetStep(round),
                            ),
                          ),
                          Step(
                            title: const Text(
                              'Plis / Bonus',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            isActive: currentStep >= 1,
                            state: allTricksSelected
                                ? StepState.complete
                                : StepState.indexed,
                            content: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _buildTrickGrid(round),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (currentStep == 1 && allTricksSelected)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _finishRound,
                      child: const Text(
                        "Résultat",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// --- Étape 1 : Mises ---
  Widget _buildBetStep(int roundNumber) {
    final miseOptions = List<int>.generate(roundNumber + 1, (i) => i);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 10,
      children: widget.players.map((player) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.black,
              child: Text(
                player.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<int>(
                value: bets[player],
                hint: const Text("Mise", style: TextStyle(color: Colors.white)),
                dropdownColor: Colors.black,
                underline: const SizedBox(),
                iconEnabledColor: Colors.white,
                items: miseOptions
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(
                          v.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    bets[player] = value;
                    if (allBetsSelected) _nextStep();
                  });
                },
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTrickGrid(int roundNumber) {
    final plisOptions = List<int>.generate(roundNumber + 1, (i) => i);
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.25,
      ),
      itemCount: widget.players.length,
      itemBuilder: (context, index) {
        final player = widget.players[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.black,
              child: Text(
                player.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: tricks[player],
                    hint: const Text(
                      "Plis",
                      style: TextStyle(color: Colors.white),
                    ),
                    dropdownColor: Colors.black,
                    underline: const SizedBox(),
                    iconEnabledColor: Colors.white,
                    items: plisOptions
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text(
                              v.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() => tricks[player] = val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 65,
                  child: TextField(
                    onChanged: (val) =>
                        bonuses[player] = val.isEmpty ? null : val,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      hintText: "Bonus",
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
