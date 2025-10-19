import 'package:flutter/material.dart';
import 'package:skull_king/theme/app_theme.dart';
import 'package:skull_king/ui/pages/home_page.dart';

void main() {
  runApp(const SkullKingApp());
}

class SkullKingApp extends StatelessWidget {
  const SkullKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skull King',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomePage(),
    );
  }
}
