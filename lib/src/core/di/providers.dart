import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/search/data/pro_repository.dart';
import '../../features/search/domain/search_params.dart';
import '../../features/search/domain/professional.dart';

// Repositorio inyectado (luego lo cambiamos por uno HTTP sin tocar pantallas)
final proRepositoryProvider = Provider<ProRepository>((ref) {
  return ProRepository.instance;
});

// Parámetros de búsqueda globales (query, minRating, ProfessionalSortBy)
final searchParamsProvider = StateProvider<SearchParams>((ref) {
  return const SearchParams(); // valores por defecto
});

// Resultados según params (se recalcula cuando cambian params)
final searchResultsProvider = FutureProvider<List<Professional>>((ref) async {
  final repo = ref.watch(proRepositoryProvider);
  final params = ref.watch(searchParamsProvider);
  final results = await repo.search(params);
  return results;
});
