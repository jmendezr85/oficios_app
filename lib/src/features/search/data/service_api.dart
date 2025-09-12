import '../../../core/network/api_client.dart';
import '../../pro/domain/service.dart';
import '../domain/search_filters.dart';

class ServiceApi {
  static Future<List<Service>> search(
    SearchFilters f, {
    Map<String, String>? headers,
  }) async {
    final qp = <String, String>{
      'limit': '${f.limit}',
      'offset': '${f.offset}',
      'sortBy': switch (f.sortBy) {
        ServiceSortBy.precioAsc => 'precioAsc',
        ServiceSortBy.precioDesc => 'precioDesc',
        _ => 'recientes',
      },
    };
    if (f.query?.isNotEmpty == true) qp['query'] = f.query!;
    if (f.categoria?.isNotEmpty == true) qp['categoria'] = f.categoria!;
    if (f.ciudad?.isNotEmpty == true) qp['ciudad'] = f.ciudad!;
    if (f.disponible != null) qp['disponible'] = f.disponible! ? '1' : '0';
    if (f.minPrecio != null) qp['minPrecio'] = '${f.minPrecio}';
    if (f.maxPrecio != null) qp['maxPrecio'] = '${f.maxPrecio}';

    final json = await ApiClient.getJson(
      '/services',
      query: qp,
      headers: headers,
    );
    final items = (json['items'] as List).cast<Map<String, dynamic>>();
    return items
        .map(
          (m) => Service(
            id: m['id'] as String,
            titulo: m['titulo'] as String,
            categoria: m['categoria'] as String,
            ciudad: m['ciudad'] as String,
            precioPorHora: (m['precioPorHora'] as num).toDouble(),
            descripcion: m['descripcion'] as String,
            disponible: m['disponible'] as bool,
            creadoEn: DateTime.parse(m['creadoEn'] as String),
          ),
        )
        .toList(growable: false);
  }
}
