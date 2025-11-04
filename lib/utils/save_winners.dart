// ignore_for_file: unintended_html_in_doc_comment

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String _kWinnersKey = 'winners_history_v2';

/// Sauvegarde une partie complète:
/// - winners: liste des vainqueurs avec leur score [{'name':..,'score':..}, ...]
/// - players: liste complète des joueurs finaux [{'name':..,'score':..}, ...]
/// - rounds: Map<int, Map<String, Map<String,dynamic>>> (roundNumber -> player -> data)
Future<void> saveWinners({
  required List<Map<String, dynamic>> winners,
  required List<Map<String, dynamic>> players,
  required Map<int, Map<String, Map<String, dynamic>>> rounds,
}) async {
  final prefs = await SharedPreferences.getInstance();

  final entry = <String, dynamic>{
    'date': DateTime.now().toIso8601String(),
    'winners': winners,
    'players': players,
    // rounds : convert keys to strings for JSON-friendly map
    'rounds': rounds.map((k, v) => MapEntry(k.toString(), v)),
  };

  final List<String> list = prefs.getStringList(_kWinnersKey) ?? [];
  list.add(jsonEncode(entry));
  await prefs.setStringList(_kWinnersKey, list);
}

/// Charge tout l'historique (liste d'objets decodés).
/// Retourne List<Map<String,dynamic>>
Future<List<Map<String, dynamic>>> loadWinnersHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? raw = prefs.getStringList(_kWinnersKey);
  if (raw == null) return [];

  final List<Map<String, dynamic>> out = [];
  for (var s in raw) {
    try {
      final decoded = jsonDecode(s) as Map<String, dynamic>;
      // restore rounds keys to int if desired (we can keep as string)
      out.add(decoded);
    } catch (_) {
      // ignore malformed entries
    }
  }

  return out;
}

/// Supprime une partie de l'historique par index (0 = la plus ancienne).
Future<void> deleteGameFromHistory(int indexFromOldest) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? raw = prefs.getStringList(_kWinnersKey);
  if (raw == null) return;
  if (indexFromOldest < 0 || indexFromOldest >= raw.length) return;

  raw.removeAt(indexFromOldest);
  await prefs.setStringList(_kWinnersKey, raw);
}
