import 'package:flutter/material.dart';
import 'package:skull_king/ui/pages/round/steps/avatar_bonus.dart';

class RoundTrickStep extends StatefulWidget {
  final List<String> players;
  final Map<String, int?> tricks;
  final Map<String, int> bonuses;
  final VoidCallback onInputChanged;
  final int roundNumber;

  const RoundTrickStep({
    super.key,
    required this.players,
    required this.tricks,
    required this.bonuses,
    required this.onInputChanged,
    required this.roundNumber,
  });

  @override
  State<RoundTrickStep> createState() => _RoundTrickStepState();
}

class _RoundTrickStepState extends State<RoundTrickStep> {
  /// 🔥 Valeur d’un bonus (quantité x ce nombre)
  final bonusValues = {
    "couleur": 10,
    "noir": 20,
    "sirene": 20,
    "pirate": 30,
    "skull": 40,
    "butin": 20,
  };

  /// 🔥 Nombre de fois max qu’on peut cliquer
  final maxBonusLevel = {
    "couleur": 3,
    "sirene": 2,
    "pirate": 5,
    "butin": 2,
    "noir": 1,
    "skull": 1,
  };

  /// 🔥 Stocke combien de fois chaque bonus est activé
  late Map<String, Map<String, int>> bonusCount;

  @override
  void initState() {
    super.initState();
    bonusCount = {
      for (var p in widget.players) p: {for (var k in bonusValues.keys) k: 0},
    };
  }

  /// 🔁 GESTION DU NOMBRE DE CLICS + RECALCUL POINTS
  void toggleBonus(String player, String key) {
    setState(() {
      int current = bonusCount[player]![key]!;
      current++;

      if (current > maxBonusLevel[key]!) current = 0;
      bonusCount[player]![key] = current;

      widget.bonuses[player] = bonusCount[player]!.entries.fold(0, (sum, e) {
        return sum + (bonusValues[e.key]! * e.value);
      });
    });

    widget.onInputChanged();
  }

  /// 🖼️ Image GRAY / COLOR selon niveau
  Widget bonusIcon(int count, String asset, double size) {
    final isActive = count > 0;

    return ColorFiltered(
      colorFilter: isActive
          ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
          : const ColorFilter.matrix([
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
      child: Image.asset(asset, width: size, height: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plisOptions = List<int>.generate(widget.roundNumber + 1, (i) => i);

    return SizedBox(
      height: 500,
      child: SingleChildScrollView(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.80,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
          ),
          itemCount: widget.players.length,
          itemBuilder: (_, i) {
            final p = widget.players[i];
            final bonusValue = widget.bonuses[p] ?? 0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlisAvatar(name: p),
                const SizedBox(height: 6),

                /// 🎯 LIGNE PLIS + BONUS RESULTAT
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
                        value: widget.tricks[p],
                        dropdownColor: Colors.black,
                        underline: const SizedBox(),
                        iconEnabledColor: Colors.white,
                        hint: const Text(
                          "Plis",
                          style: TextStyle(color: Colors.white),
                        ),
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
                        onChanged: (v) {
                          setState(() => widget.tricks[p] = v);
                          widget.onInputChanged();
                        },
                      ),
                    ),

                    const SizedBox(width: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "+$bonusValue",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                Wrap(
                  spacing: 8,
                  children: [
                    bonusBtn(p, "couleur", "assets/images/couleur.png", 42),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: bonusBtn(p, "noir", "assets/images/noir.png", 28),
                    ),
                    bonusBtn(p, "sirene", "assets/images/sirene.png", 42),
                  ],
                ),

                Wrap(
                  spacing: 8,
                  children: [
                    bonusBtn(p, "pirate", "assets/images/pirate.png", 42),
                    bonusBtn(p, "skull", "assets/images/skull.png", 42),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: bonusBtn(
                        p,
                        "butin",
                        "assets/images/buttin.png",
                        28,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 🟡 BOUTON BONUS AVEC NIVEAU
  Widget bonusBtn(String p, String key, String asset, double size) {
    final level = bonusCount[p]![key]!;

    return GestureDetector(
      onTap: () => toggleBonus(p, key),
      child: Stack(
        alignment: Alignment.center,
        children: [
          bonusIcon(level, asset, size),
          if (level > 0)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${level}x",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
