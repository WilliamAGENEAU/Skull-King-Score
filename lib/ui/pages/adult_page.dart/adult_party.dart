// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:skull_king/ui/pages/home_page.dart';

class AdultPage extends StatefulWidget {
  const AdultPage({super.key});

  @override
  State<AdultPage> createState() => _AdultPageState();
}

class _AdultPageState extends State<AdultPage> {
  /// État recto / verso
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
          /// --- Fond ---
          Positioned.fill(
            child: Image.asset('assets/images/love.png', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.08)),

          /// --- Bouton menu ---
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton(
                  onPressed: () => _confirmReturnToMenu(context),
                  icon: const Icon(Icons.menu, color: Colors.black, size: 34),
                ),
              ),
            ),
          ),

          /// --- Grille 2x5 ---
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 70, 14, 20),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.40,
              ),
              itemBuilder: (_, index) => _buildFlipCard(index),
            ),
          ),
        ],
      ),
    );
  }

  /// --- Flip card ---
  Widget _buildFlipCard(int index) {
    return GestureDetector(
      onTap: () {
        setState(() => _isFlipped[index] = !_isFlipped[index]);
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _isFlipped[index] ? 1 : 0),
        duration: const Duration(milliseconds: 400),
        builder: (_, value, _) {
          final bool isBack = value > 0.5;

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
                    color: Colors.pink.withOpacity(0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: isBack
                  ? _buildBackCardImage(index)
                  : _buildFrontCardImage(index),
            ),
          );
        },
      ),
    );
  }

  /// --- RECTO : images ---
  Widget _buildFrontCardImage(int index) {
    final List<String> images = [
      "assets/images/fuite.png",
      "assets/images/couleur.png",
      "assets/images/atout.png",
      "assets/images/sirenes.png",
      "assets/images/pirates.png",
      "assets/images/master.png",
      "assets/images/couleur.png",
      "assets/images/buttin.png",
      "assets/images/baleine.png",
      "assets/images/kraken.png",
    ];

    return Center(
      child: Image.asset(
        images[index],
        width: 72,
        height: 72,
        fit: BoxFit.contain,
      ),
    );
  }

  /// --- VERSO : images PNG ---
  Widget _buildBackCardImage(int index) {
    final List<String> backImages = [
      "assets/images/back_1.png",
      "assets/images/back_2.png",
      "assets/images/back_3.png",
      "assets/images/back_4.png",
      "assets/images/back_5.png",
      "assets/images/back_6.png",
      "assets/images/back_7.png",
      "assets/images/back_8.png",
      "assets/images/back_9.png",
      "assets/images/back_10.png",
    ];

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi), // corrige miroir
      child: Center(
        child: Image.asset(
          backImages[index],
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
