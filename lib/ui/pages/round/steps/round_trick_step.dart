import 'package:flutter/material.dart';
import 'package:skull_king/ui/pages/round/steps/avatar_bonus.dart';

class RoundTrickStep extends StatelessWidget {
  final List<String> players;
  final Map<String, int?> tricks;
  final Map<String, String?> bonuses;
  final VoidCallback onInputChanged;
  final int roundNumber; // ⬅️ NOUVEAU

  const RoundTrickStep({
    super.key,
    required this.players,
    required this.tricks,
    required this.bonuses,
    required this.onInputChanged,
    required this.roundNumber, // ⬅️ OBLIGATOIRE
  });

  bool _allPlayersFilled() => tricks.values.every((v) => v != null);

  @override
  Widget build(BuildContext context) {
    /// 👇 CORRECTION → 0 → numéro de manche
    final plisOptions = List<int>.generate(roundNumber + 1, (i) => i);

    return Column(
      children: [
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.25,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: players.length,
          itemBuilder: (context, i) {
            final p = players[i];

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlisAvatar(name: p),
                const SizedBox(height: 6),

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
                        value: tricks[p],
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
                                  "$v",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          tricks[p] = val;
                          onInputChanged();
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    SizedBox(
                      width: 65,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          bonuses[p] = val.isEmpty ? null : val;
                          onInputChanged();
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          hintText: "Bonus",
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
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
        ),

        const SizedBox(height: 20),

        if (_allPlayersFilled())
          const Text(
            "✔️ Tous les plis ont été renseignés",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
