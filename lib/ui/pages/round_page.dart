// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

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

  void _finishRound() {
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

    Navigator.pop(context, roundResults);
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
                        onStepTapped: (i) {
                          if (i <= currentStep) {
                            setState(() => currentStep = i);
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

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        alignment: WrapAlignment.start,
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
                  hint: const Text(
                    "Mise",
                    style: TextStyle(color: Colors.white),
                  ),
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
      ),
    );
  }

  Widget _buildTrickGrid(int roundNumber) {
    final plisOptions = List<int>.generate(roundNumber + 1, (i) => i);

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2; // adaptatif
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(), // 🔥 pas de scroll
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
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
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                tricks[player] = val;
                              });
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
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
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
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
