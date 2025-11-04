import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Sauvegarde une partie dans l'historique.
/// [winners] : liste des gagnants {name, score}
/// [allPlayers] : liste complète des joueurs avec leur score final
Future<void> saveWinners({
  required List<Map<String, dynamic>> winners,
  required List<Map<String, dynamic>> allPlayers,
}) async {
  final prefs = await SharedPreferences.getInstance();

  // Récupération de l'historique existant
  final String? existingData = prefs.getString('winners_history');
  List<Map<String, dynamic>> history = [];

  if (existingData != null && existingData.isNotEmpty) {
    try {
      history = List<Map<String, dynamic>>.from(jsonDecode(existingData));
    } catch (_) {
      history = [];
    }
  }

  // Ajout de la nouvelle partie
  final newEntry = {
    'date': DateTime.now().toIso8601String(),
    'winners': winners,
    'players': allPlayers,
  };

  history.add(newEntry);

  // Sauvegarde mise à jour
  await prefs.setString('winners_history', jsonEncode(history));
}

/// Charge tout l'historique des parties sauvegardées
Future<List<Map<String, dynamic>>> loadWinnersHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final String? data = prefs.getString('winners_history');

  if (data == null || data.isEmpty) return [];

  try {
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  } catch (_) {
    return [];
  }
}

/// Supprime une partie spécifique de l'historique
Future<void> deleteGameFromHistory(int index) async {
  final prefs = await SharedPreferences.getInstance();
  final String? data = prefs.getString('winners_history');

  if (data == null || data.isEmpty) return;

  List<Map<String, dynamic>> history = List<Map<String, dynamic>>.from(
    jsonDecode(data),
  );

  if (index >= 0 && index < history.length) {
    history.removeAt(index);
    await prefs.setString('winners_history', jsonEncode(history));
  }
}

/// Vide complètement l'historique
Future<void> clearWinnersHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('winners_history');
}
