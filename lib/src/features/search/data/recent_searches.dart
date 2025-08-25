import 'package:shared_preferences/shared_preferences.dart';

class RecentSearches {
  static const _key = 'recent_searches';
  static const _maxItems = 8;

  static Future<List<String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];
    return List.unmodifiable(list);
  }

  static Future<void> add(String term) async {
    final t = term.trim();
    if (t.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final list = List<String>.from(prefs.getStringList(_key) ?? <String>[]);
    // De-dup: mueve al inicio si ya existe
    list.removeWhere((e) => e.toLowerCase() == t.toLowerCase());
    list.insert(0, t);
    // Limita longitud
    if (list.length > _maxItems) {
      list.removeRange(_maxItems, list.length);
    }
    await prefs.setStringList(_key, list);
  }

  static Future<void> remove(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final list = List<String>.from(prefs.getStringList(_key) ?? <String>[]);
    list.removeWhere((e) => e.toLowerCase() == term.trim().toLowerCase());
    await prefs.setStringList(_key, list);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
