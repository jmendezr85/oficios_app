import '../../../core/network/api_client.dart';
import '../domain/service.dart';

class ServiceApi {
  static Future<List<Service>> listByProPhone(
    String proPhone, {
    Map<String, String>? headers,
  }) async {
    final json = await ApiClient.getJson(
      '/services',
      query: {'proPhone': proPhone},
      headers: headers,
    );
    final items = (json['items'] as List).cast<Map<String, dynamic>>();
    return items.map((m) => Service.fromMap(m)).toList(growable: false);
  }

  static Future<List<Service>> search({
    required String q,
    int limit = 20,
    int offset = 0,
    Map<String, String>? headers,
  }) async {
    final qp = {'q': q, 'limit': '$limit', 'offset': '$offset'};
    final json = await ApiClient.getJson(
      '/services',
      query: qp,
      headers: headers,
    );
    final items = (json['items'] as List).cast<Map<String, dynamic>>();
    return items.map((m) => Service.fromMap(m)).toList(growable: false);
  }

  static Future<Service> create(
    Service service, {
    Map<String, String>? headers,
  }) async {
    final json = await ApiClient.postJson(
      '/services',
      service.toMap(),
      headers: headers,
    );
    return Service.fromMap(json);
  }

  static Future<Service> update(
    Service service, {
    Map<String, String>? headers,
  }) async {
    final json = await ApiClient.postJson(
      '/services/update',
      service.toMap(),
      headers: headers,
    );
    return Service.fromMap(json);
  }

  static Future<void> delete(String id, {Map<String, String>? headers}) async {
    await ApiClient.postJson('/services/delete', {'id': id}, headers: headers);
  }
}
