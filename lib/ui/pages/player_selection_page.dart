// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:skull_king/theme/app_theme.dart';
import 'package:skull_king/ui/pages/home_page.dart';
import 'package:skull_king/ui/pages/score_page.dart';
import 'package:skull_king/ui/widgets/player_avatar.dart';

class PlayerSelectionPage extends StatefulWidget {
  const PlayerSelectionPage({super.key});

  @override
  State<PlayerSelectionPage> createState() => _PlayerSelectionPageState();
}

class _PlayerSelectionPageState extends State<PlayerSelectionPage>
    with TickerProviderStateMixin {
  final List<String> _players = [];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

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
              Navigator.pop(context); // Ferme le dialogue
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

  void _addPlayer() async {
    if (_players.length >= 8) return;

    final TextEditingController nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Nouveau joueur",
            style: TextStyle(color: AppTheme.primaryGold),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Entrez un prénom",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryGold),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryGold, width: 2),
              ),
            ),
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
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() => _players.add(name));
                }
                Navigator.pop(context);
              },
              child: const Text(
                "Enregistrer",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _removePlayer(String name) {
    setState(() => _players.remove(name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset('assets/images/papier.jpg', fit: BoxFit.cover),
          ),

          // Légère teinte pour le contraste
          Container(color: Colors.black.withOpacity(0.2)),
          // Bouton menu haut droit
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  onPressed: () => _confirmReturnToMenu(context),
                  icon: const Icon(Icons.menu, color: Colors.black, size: 34),
                  tooltip: "Retour au menu principal",
                ),
              ),
            ),
          ),
          // Contenu centré
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: [
                  ..._players.map(
                    (p) => PlayerAvatar(
                      name: p,
                      onAddPressed: _addPlayer,
                      onRemove: () => _removePlayer(p),
                    ),
                  ),
                  if (_players.length < 8)
                    PlayerAvatar(onAddPressed: _addPlayer),
                ],
              ),
            ),
          ),

          // Bouton Play en bas à droite
          Positioned(
            bottom: 25,
            right: 25,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ElevatedButton.icon(
                onPressed: _players.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ScorePage(players: _players),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(
                  Icons.play_arrow,
                  color: AppTheme.textWhite,
                  size: 30,
                ),
                label: const Text(
                  "Début",
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  elevation: 8,
                  shadowColor: AppTheme.primaryGold.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
