import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';

class ApiClient {
  final String base = AppConfig.apiBaseUrl;

  Future<Map<String, dynamic>> getHealth() async {
    final uri = Uri.parse('$base/health');
    final res = await http.get(uri);
    _checkOkJson(res, wantList: false);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getCategorias() async {
    final uri = Uri.parse('$base/categorias');
    final res = await http.get(uri);
    _checkOkJson(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<List<dynamic>> getServicios({int? categoriaId}) async {
    final qp = categoriaId != null ? '?categoria_id=$categoriaId' : '';
    final uri = Uri.parse('$base/servicios$qp');
    final res = await http.get(uri);
    _checkOkJson(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  void _checkOkJson(http.Response res, {bool wantList = true}) {
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final ct = res.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      final snippet = res.body.length > 180
          ? res.body.substring(0, 180)
          : res.body;
      throw Exception('Respuesta no JSON (CT=$ct). Ejemplo: $snippet');
    }
    // validación mínima del shape
    final body = jsonDecode(res.body);
    if (wantList && body is! List) {
      throw Exception(
        'Esperaba una lista JSON pero llegó: ${body.runtimeType}',
      );
    }
    if (!wantList && body is! Map) {
      throw Exception(
        'Esperaba un objeto JSON pero llegó: ${body.runtimeType}',
      );
    }
  }
}
