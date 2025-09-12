import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:oficios_app/src/core/config/env.dart';

/// The base URL is configured through the `API_BASE_URL` environment variable.
/// Default: http://10.0.2.2/oficios_api (Android emulator).
/// Examples:
/// - Emulador Android:    http://10.0.2.2/oficios_api
/// - Dispositivo físico:  http://TU_IP_LOCAL/oficios_api  (ej. 192.168.0.10)
/// - PC (debug web):      http://localhost/oficios_api
class ApiClient {
  static String get _baseUrl => Env.apiBaseUrl;

  static Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final res = await http.get(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
  }

  static Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (headers != null) ...headers,
      },
      body: json.encode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
  }
}
