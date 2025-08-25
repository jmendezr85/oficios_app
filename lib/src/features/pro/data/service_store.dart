import 'package:shared_preferences/shared_preferences.dart';
import '../domain/service.dart';
import 'dart:convert';

class ServiceStore {
  static const _key = 'my_services_v1';

  Future<List<Service>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const <Service>[];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return servicesFromMaps(decoded);
    } catch (_) {
      // Si algo falla al decodificar, devolvemos lista vacía
      return const <Service>[];
    }
  }

  Future<void> setAll(List<Service> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(servicesToMaps(list));
    await prefs.setString(_key, encoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
