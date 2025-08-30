import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:oficios_app/src/features/pro/domain/service.dart';

class ServiceApi {
  ServiceApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Cambia esta URL a tu backend (XAMPP)
  static const String baseUrl = 'http://192.168.1.11/oficios_api';

  Future<List<Service>> listByProPhone(String proPhone) async {
    final uri = Uri.parse('$baseUrl/services_get.php?pro_phone=$proPhone');
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final data = json.decode(res.body);
    if (data is List) {
      return data
          .map((e) => Service.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    return const <Service>[];
  }

  Future<List<Service>> search({
    required String q,
    int limit = 20,
    int offset = 0,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/services_get.php?q=${Uri.encodeQueryComponent(q)}&limit=$limit&offset=$offset',
    );
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final data = json.decode(res.body);
    if (data is List) {
      return data
          .map((e) => Service.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    return const <Service>[];
  }

  Future<Service> create(Service service) async {
    final uri = Uri.parse('$baseUrl/services_post.php');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: service.toJson(),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    return Service.fromMap(data);
  }

  Future<Service> update(Service service) async {
    final uri = Uri.parse('$baseUrl/services_put.php?id=${service.id}');
    final res = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: service.toJson(),
    );
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    return Service.fromMap(data);
  }

  Future<void> delete(int id) async {
    final uri = Uri.parse('$baseUrl/services_delete.php?id=$id');
    final res = await _client.delete(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }
}
