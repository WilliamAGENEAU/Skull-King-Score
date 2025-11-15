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
  @override
  Widget build(BuildContext context) {
    final plisOptions = List<int>.generate(widget.roundNumber + 1, (i) => i);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
            ),
            itemCount: widget.players.length,
            itemBuilder: (_, i) {
              final p = widget.players[i];
              final bonusActive = (widget.bonuses[p] ?? 0) > 0;

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

                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "+${widget.bonuses[p] ?? 0}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  IconButton(
                    onPressed: () {
                      setState(() => widget.bonuses[p] = bonusActive ? 0 : 10);
                      widget.onInputChanged();
                    },
                    icon: Icon(
                      Icons.star,
                      size: 32,
                      color: bonusActive ? Colors.amber : Colors.grey,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
