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

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    } else {
      final first = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
      final last = parts[1].isNotEmpty ? parts[1][0].toUpperCase() : '';
      return "$first$last";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (name == null) {
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

    final String initials = _getInitials(name!);

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
              initials,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
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
