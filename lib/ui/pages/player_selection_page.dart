import 'package:flutter/material.dart';
import 'package:skull_king/theme/app_theme.dart';
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
            bottom: 20,
            right: 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: IconButton(
                onPressed: _players.isNotEmpty
                    ? () {
                        // TODO: Lancer la partie
                      }
                    : null,
                icon: const Icon(Icons.play_circle_fill, size: 70),
                color: _players.isNotEmpty
                    ? AppTheme.primaryGold
                    : Colors.white24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
