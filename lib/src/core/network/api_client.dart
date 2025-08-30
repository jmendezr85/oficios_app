import 'dart:convert';
import 'package:http/http.dart' as http;

/// Ajusta la base según dónde ejecutes:
/// - Emulador Android:    http://10.0.2.2/oficios_api
/// - Dispositivo físico:  http://TU_IP_LOCAL/oficios_api  (ej. 192.168.0.10)
/// - PC (debug web):      http://localhost/oficios_api
class ApiClient {
  static const String baseUrl = 'http://192.168.1.7/oficios_api';
  // 👈 AJUSTA aquí si usas dispositivo físico

  static Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final res = await http.get(uri);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
  }

  static Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
  }
}
