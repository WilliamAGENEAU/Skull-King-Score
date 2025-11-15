import 'package:flutter/material.dart';
import 'package:skull_king/ui/pages/round/steps/avatar_bonus.dart';

class RoundBetStep extends StatelessWidget {
  final List<String> players;
  final Map<String, int?> bets;
  final int roundNumber;
  final VoidCallback onNext;

  /// Callback vers le parent : informe du changement de mise
  final void Function(String player, int value) onBetChanged;

  const RoundBetStep({
    super.key,
    required this.players,
    required this.bets,
    required this.roundNumber,
    required this.onNext,
    required this.onBetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final miseOptions = List<int>.generate(roundNumber + 1, (i) => i);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 10,
      children: players.map((player) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlisAvatar(name: player),
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
                  if (value == null) return;
                  // Informe le parent du changement
                  onBetChanged(player, value);
                },
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
