import '../../search/domain/professional.dart';
import '../domain/search_params.dart';

class ProRepository {
  ProRepository._();
  static final instance = ProRepository._();

  // Datos dummy
  final List<Professional> _seed = const [
    Professional(
      nombre: 'Carlos Pérez',
      oficio: 'Carpintero',
      rating: 4.7,
      distancia: '1.2 km',
      descripcion: '15 años de experiencia en muebles a medida.',
    ),
    Professional(
      nombre: 'Ana Gómez',
      oficio: 'Electricista',
      rating: 4.9,
      distancia: '2.4 km',
      descripcion: 'Instalaciones y mantenimiento residencial.',
    ),
    Professional(
      nombre: 'Javier Ruiz',
      oficio: 'Plomero',
      rating: 4.5,
      distancia: '900 m',
      descripcion: 'Urgencias 24/7, reparación de fugas y grifería.',
    ),
    Professional(
      nombre: 'Lucía Torres',
      oficio: 'Carpintero',
      rating: 4.3,
      distancia: '3.1 km',
      descripcion: 'Restauración y reparación de puertas/ventanas.',
    ),
    Professional(
      nombre: 'Miguel Álvarez',
      oficio: 'Electricista',
      rating: 4.6,
      distancia: '2.0 km',
      descripcion: 'Cableado estructurado y diagnóstico.',
    ),
  ];

  // Simula una búsqueda con filtros
  Future<List<Professional>> search(SearchParams params) async {
    // pequeño delay para simular IO
    await Future.delayed(const Duration(milliseconds: 200));

    final q = params.query?.trim().toLowerCase() ?? '';
    List<Professional> results = _seed.where((p) {
      final matchQuery = q.isEmpty
          ? true
          : p.oficio.toLowerCase().contains(q) ||
                p.nombre.toLowerCase().contains(q);
      final matchRating = p.rating >= params.minRating;
      return matchQuery && matchRating;
    }).toList();

    // Orden
    switch (params.sortBy) {
      case SortBy.rating:
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortBy.name:
        results.sort((a, b) => a.nombre.compareTo(b.nombre));
        break;
    }

    // Simular distancia “variable” si quisieras; aquí la dejamos como está.
    return results;
  }
}
