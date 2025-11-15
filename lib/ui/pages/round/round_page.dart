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
  late Map<String, String?> bonuses;

  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    bets = {for (var p in widget.players) p: null};
    tricks = {for (var p in widget.players) p: null};
    bonuses = {for (var p in widget.players) p: null};

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

  // ------------------ FIN DE MANCHE ------------------
  void _finishRound() {
    final results = <String, Map<String, dynamic>>{};

    for (final p in widget.players) {
      final bet = bets[p] ?? 0;
      final trick = tricks[p] ?? 0;
      final bonus = int.tryParse(bonuses[p] ?? "0") ?? 0;

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

    // ⏭️ Si on n'est pas au dernier tour → on retourne au tableau de marque
    if (widget.roundNumber < 10) {
      Navigator.pop(context, results);
      return;
    }

    // 🎉 FIN DE PARTIE
    final sorted = widget.totalScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bestScore = sorted.first.value;
    final winners = sorted.where((e) => e.value == bestScore).toList();

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
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ------------------ STEPPER ------------------
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
                        currentStep: currentStep,
                        type: StepperType.vertical,
                        controlsBuilder: (_, _) => const SizedBox.shrink(),
                        onStepTapped: (s) => setState(
                          () =>
                              currentStep = s <= currentStep ? s : currentStep,
                        ),
                        steps: [
                          Step(
                            title: const Text(
                              "Mise",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            state: allBetsSelected
                                ? StepState.complete
                                : StepState.indexed,
                            isActive: currentStep >= 0,
                            content: RoundBetStep(
                              players: widget.players,
                              bets: bets,
                              roundNumber: round,
                              onBetChanged: (p, v) {
                                setState(() {
                                  bets[p] = v;
                                  if (allBetsSelected) _nextStep();
                                });
                              },
                              onNext: _nextStep,
                            ),
                          ),

                          Step(
                            title: const Text(
                              "Plis / Bonus",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
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
                              onInputChanged: () => setState(() {}),
                              roundNumber: widget.roundNumber, // ⬅️ AJOUT ICI
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ------------------ BOUTON RESULTAT ------------------
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
}
