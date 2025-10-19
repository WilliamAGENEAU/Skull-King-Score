// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:skull_king/theme/app_theme.dart';

class PlayerAvatar extends StatelessWidget {
  final String? name;
  final VoidCallback onAddPressed;
  final VoidCallback? onRemove;

  const PlayerAvatar({
    super.key,
    this.name,
    required this.onAddPressed,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (name == null) {
      // Rond avec un plus (ajout de joueur)
      return GestureDetector(
        onTap: onAddPressed,
        child: Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.textWhite, width: 2),
          ),
          child: const Icon(Icons.add, color: AppTheme.textWhite, size: 36),
        ),
      );
    }

    final String initial = name!.isNotEmpty ? name![0].toUpperCase() : '?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Croix de suppression
        if (onRemove != null)
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                padding: const EdgeInsets.all(3),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
