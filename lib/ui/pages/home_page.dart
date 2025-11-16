// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:skull_king/theme/app_theme.dart';
import 'package:skull_king/ui/pages/palmares_page.dart';
import 'package:skull_king/ui/widgets/skull_button.dart';
import 'package:skull_king/ui/pages/player_selection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _fadeController;
  late Animation<double> _bgScaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _bgScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bgScaleAnimation.value,
                  child: Image.asset(
                    'assets/images/skull_king_bkg.png',
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkullButton(
                      label: 'Nouvelle Partie',
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 700,
                            ),
                            pageBuilder: (_, _, _) =>
                                const PlayerSelectionPage(),
                            transitionsBuilder: (_, anim, _, child) =>
                                FadeTransition(opacity: anim, child: child),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    SkullButton(
                      label: 'Palmarès',
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 700,
                            ),
                            pageBuilder: (_, _, _) => PalmaresPage(),
                            transitionsBuilder: (_, anim, _, child) =>
                                FadeTransition(opacity: anim, child: child),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    SkullButton(
                      label: 'Extensions (Bientôt)',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'v1.1 • William Ageneau',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
