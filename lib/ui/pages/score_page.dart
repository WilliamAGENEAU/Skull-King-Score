// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:skull_king/theme/app_theme.dart';
import 'package:skull_king/ui/pages/home_page.dart';
import 'package:skull_king/ui/widgets/score_table.dart';

class ScorePage extends StatelessWidget {
  final List<String> players;

  const ScorePage({super.key, required this.players});

  void _confirmReturnToMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Retour au menu principal ?",
          style: TextStyle(color: AppTheme.primaryGold),
        ),
        content: const Text(
          "La partie en cours sera perdue.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Annuler",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            },
            child: const Text(
              "Confirmer",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Padding global pour ne pas coller aux bords de l'écran
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/papier.jpg', fit: BoxFit.cover),
          ),
          // légère teinte pour lisibilité
          Container(color: Colors.black.withOpacity(0.08)),

          // Bouton menu haut droit
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  onPressed: () => _confirmReturnToMenu(context),
                  icon: const Icon(Icons.menu, color: Colors.black, size: 34),
                ),
              ),
            ),
          ),
          // Zone principale : tableau qui prend l'espace disponible
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 80.0,
              ),
              child: Column(
                children: [
                  // Optionnel : titre ou espace (tu as demandé d'enlever les titres sur d'autres pages)
                  Expanded(
                    child: Container(
                      // Fond transparent explicitement pour s'assurer qu'on voit le papier
                      color: Colors.transparent,
                      child: ScoreTable(players: players),
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
