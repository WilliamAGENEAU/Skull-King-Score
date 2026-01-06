// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:skull_king/theme/app_theme.dart';
import 'package:skull_king/ui/pages/home_page.dart';

class ExtensionPage extends StatefulWidget {
  const ExtensionPage({super.key});

  @override
  State<ExtensionPage> createState() => _ExtensionPageState();
}

class _ExtensionPageState extends State<ExtensionPage> {
  bool _isFlipped = false;
  static const double cardWidth = 160;
  static const double cardHeight = 220;

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
    return Scaffold(
      body: Stack(
        children: [
          /// --- FOND PAPIER ---
          Positioned.fill(
            child: Image.asset('assets/images/papier.jpg', fit: BoxFit.cover),
          ),

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

          /// --- GRILLE DES EXTENSIONS ---
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildFizzCard(),
                  _buildLockedCard(),
                  _buildLockedCard(),
                  _buildLockedCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// --- CARTE FIZZ (FLIP) ---
  Widget _buildFizzCard() {
    return GestureDetector(
      onTap: () {
        setState(() => _isFlipped = !_isFlipped);
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _isFlipped ? 1 : 0),
        duration: const Duration(milliseconds: 450),
        builder: (context, value, _) {
          final isBack = value > 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(pi * value),
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: isBack ? _buildFizzBack() : _buildFizzFront(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFizzFront() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        'assets/images/fizz.jpg',
        fit: BoxFit.cover, // 🔥 remplit sans changer la taille
      ),
    );
  }

  Widget _buildFizzBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Center(
          child: Text(
            "Le plus petit chiffre gagne quelque soit la couleur.\n\n"
            "Fizz < Baleine et Kraken",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  /// --- CARTES VERROUILLÉES ---
  Widget _buildLockedCard() {
    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "?",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}
