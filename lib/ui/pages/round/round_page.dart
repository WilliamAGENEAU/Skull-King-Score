// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:skull_king/ui/pages/round/steps/endgame_dialog.dart';
import 'package:skull_king/ui/pages/round/steps/round_bet_step.dart';
import 'package:skull_king/ui/pages/round/steps/round_trick_step.dart';

class RoundPage extends StatefulWidget {
  final int roundNumber;
  final List<String> players;
  final Map<String, int> totalScores;

  const RoundPage({
    super.key,
    required this.roundNumber,
    required this.players,
    required this.totalScores,
  });

  @override
  State<RoundPage> createState() => _RoundPageState();
}

class _RoundPageState extends State<RoundPage> {
  int currentStep = 0;

  late Map<String, int?> bets;
  late Map<String, int?> tricks;
  late Map<String, int> bonuses;

  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    bets = {for (var p in widget.players) p: null};
    tricks = {for (var p in widget.players) p: null};
    bonuses = {for (var p in widget.players) p: 0};

    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  bool get allBetsSelected => bets.values.every((v) => v != null);
  bool get allTricksSelected => tricks.values.every((v) => v != null);

  void _nextStep() => setState(() => currentStep++);

  // ---------------- FIN MANCHE ----------------
  void _finishRound() {
    final results = <String, Map<String, dynamic>>{};

    for (final p in widget.players) {
      final bet = bets[p] ?? 0;
      final trick = tricks[p] ?? 0;
      final bonus = bonuses[p] ?? 0;

      final points = _calculatePoints(widget.roundNumber, bet, trick);
      final total = points + bonus;

      widget.totalScores[p] = (widget.totalScores[p] ?? 0) + total;

      results[p] = {
        "mise": bet,
        "plis": trick,
        "points": points,
        "bonus": bonus,
        "total": total,
      };
    }

    if (widget.roundNumber < 10) {
      Navigator.pop(context, results);
      return;
    }

    /// 🎉 FIN DE PARTIE
    final sorted = widget.totalScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final best = sorted.first.value;
    final winners = sorted.where((e) => e.value == best).toList();

    showEndGameDialog(context, winners, results, _confetti);
  }

  int _calculatePoints(int round, int bet, int trick) {
    if (bet > 0 && bet == trick) return 20 * bet;
    if (bet > 0 && bet != trick) return -10 * (bet - trick).abs();
    if (bet == 0 && trick == 0) return 10 * round;
    return -10 * round;
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.roundNumber;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/papier.jpg", fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                Text(
                  "Manche $round",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: SingleChildScrollView(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.black,
                          onPrimary: Colors.white,
                        ),
                        canvasColor: Colors.transparent,
                      ),
                      child: Stepper(
                        currentStep: currentStep,
                        physics: const NeverScrollableScrollPhysics(),
                        controlsBuilder: (_, _) => const SizedBox.shrink(),

                        onStepTapped: (step) {
                          setState(() {
                            // ⬅️ Autorisé : revenir en arrière
                            if (step < currentStep) {
                              currentStep = step;
                              return;
                            }

                            // ⬅️ Autorisé : passer à PLIS si toutes les mises sont faites
                            if (step == 1 && allBetsSelected) {
                              currentStep = 1;
                              return;
                            }

                            // ⛔ Pas autorisé d’aller plus loin sinon
                          });
                        },

                        steps: [
                          Step(
                            title: const Text(
                              "Mise",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            state: allBetsSelected
                                ? StepState.complete
                                : StepState.indexed,
                            isActive: currentStep >= 0,
                            content: RoundBetStep(
                              players: widget.players,
                              bets: bets,
                              onBetChanged: (p, v) {
                                setState(() {
                                  bets[p] = v;
                                  if (allBetsSelected) _nextStep();
                                });
                              },
                              roundNumber: round,
                              onNext: _nextStep,
                            ),
                          ),
                          Step(
                            title: const Text(
                              "Plis / Bonus",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            state: allTricksSelected
                                ? StepState.complete
                                : StepState.indexed,
                            isActive: currentStep >= 1,
                            content: RoundTrickStep(
                              players: widget.players,
                              tricks: tricks,
                              bonuses: bonuses,
                              bets: bets,
                              onInputChanged: () => setState(() {}),
                              roundNumber: widget.roundNumber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (currentStep == 1 && allTricksSelected)
                  ElevatedButton(
                    onPressed: _finishRound,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 42,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Résultat",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
