// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:skull_king/ui/pages/home_page.dart';
import 'dart:math';

class AdultPage extends StatefulWidget {
  const AdultPage({super.key});

  @override
  State<AdultPage> createState() => _AdultPageState();
}

class _AdultPageState extends State<AdultPage> {
  /// On stocke l'état des cartes (recto/verso)
  final List<bool> _isFlipped = List.generate(10, (_) => false);

  void _confirmReturnToMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Retour au menu principal ?",
          style: TextStyle(color: Color.fromARGB(255, 163, 41, 174)),
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
              backgroundColor: Color.fromARGB(255, 163, 41, 174),
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
    return Scaffold(
      body: Stack(
        children: [
          /// --- Image de fond ---
          Positioned.fill(
            child: Image.asset('assets/images/love.png', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.08)),

          /// --- Bouton menu ---
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

          /// --- GRILLE 2x5 AVEC FLIP CARDS ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 60),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 10,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 🔥 2 colonnes
                crossAxisSpacing: 16, // espace horizontal
                mainAxisSpacing: 16, // espace vertical
                childAspectRatio: 1.40, // ajustement ratio visuel
              ),
              itemBuilder: (context, index) {
                return _buildFlipCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// --- WIDGET FLIP CARD ---
  Widget _buildFlipCard(int index) {
    return GestureDetector(
      onTap: () {
        setState(() => _isFlipped[index] = !_isFlipped[index]);
      },
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: _isFlipped[index] ? 1 : 0),
        duration: const Duration(milliseconds: 400),
        builder: (context, value, child) {
          final isBack = value > 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(pi * value),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isBack
                    ? const Color.fromARGB(255, 255, 182, 234)
                    : const Color.fromARGB(255, 243, 94, 177),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: isBack
                  ? _buildBackCardContent(index)
                  : _buildFrontCardContent(index),
            ),
          );
        },
      ),
    );
  }

  /// --- RECTO: IMAGE pour chaque card ---
  Widget _buildFrontCardContent(int index) {
    // Liste des images associées à chaque carte
    final List<String> images = [
      "assets/images/fuite.png", // Card 1
      "assets/images/couleur.png", // Card 2
      "assets/images/atout.png", // Card 3
      "assets/images/sirenes.png", // Card 4
      "assets/images/pirates.png", // Card 5
      "assets/images/master.png", // Card 6
      "assets/images/couleur.png", // Card 7
      "assets/images/buttin.png", // Card 8
      "assets/images/baleine.png", // Card 9
      "assets/images/kraken.png", // Card 10
    ];

    return Center(
      child: Image.asset(
        images[index],
        width: 70, // 🔥 ajuste la taille ici si besoin
        height: 70,
        fit: BoxFit.contain,
      ),
    );
  }

  /// --- VERSO: TEXTE D’INFO (modifiable) ---
  /// --- VERSO: TEXTE D’INFO (spécifique à chaque carte) ---
  Widget _buildBackCardContent(int index) {
    // 🔥 Liste des textes pour chaque carte
    final List<String> backTexts = [
      "", // 1
      "", // 2
      "", // 3
      "", // 4
      "", // 5
      "", // 6
      "", // 7
      "", // 8
      "", // 9
      "", // 10
    ];

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi), // évite l'effet miroir
      child: Center(
        child: Text(
          backTexts[index],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 91, 12, 82),
          ),
        ),
      ),
    );
  }
}
