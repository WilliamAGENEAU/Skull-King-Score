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
    bets = {for (var player in widget.players) player: null};
    tricks = {for (var player in widget.players) player: null};
    bonuses = {for (var player in widget.players) player: null};
  }

  bool get allBetsSelected => bets.values.every((v) => v != null);
  bool get allTricksSelected => tricks.values.every((v) => v != null);

  void _goToNextStep() {
    if (currentStep < 1) setState(() => currentStep++);
  }

  void _finishRound() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final roundNumber = widget.roundNumber;

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Manche $roundNumber',
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
                        controlsBuilder: (context, details) =>
                            const SizedBox.shrink(),
                        onStepContinue: () {
                          if (currentStep == 0 && allBetsSelected) {
                            _goToNextStep();
                          }
                        },
                        onStepTapped: (index) {
                          if (index <= currentStep) {
                            setState(() => currentStep = index);
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
                              // 🔥 réduit la marge verticale pour alignement
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 12,
                                left: 0,
                              ),
                              child: _buildBetStep(roundNumber),
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
                              child: _buildTrickStep(roundNumber),
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
                        'Résultat',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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

  Widget _buildBetStep(int roundNumber) {
    final miseOptions = List<int>.generate(roundNumber + 1, (i) => i);

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 16,
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
                        if (allBetsSelected) _goToNextStep();
                      });
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTrickStep(int roundNumber) {
    final plisOptions = List<int>.generate(roundNumber + 1, (i) => i);

    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 16,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                          onChanged: (value) {
                            setState(() {
                              tricks[player] = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: TextField(
                          onChanged: (value) =>
                              bonuses[player] = value.isEmpty ? null : value,
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
                              horizontal: 8,
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
            }).toList(),
          ),
        ],
      ),
    );
  }
}
