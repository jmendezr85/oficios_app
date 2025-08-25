import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/service.dart';
import 'service_db.dart';
import '../../search/domain/search_filters.dart';

// (OPCIONAL) migración desde SharedPreferences
import 'service_store.dart';

class ServiceController extends StateNotifier<List<Service>> {
  ServiceController(this._db, this._legacyStore) : super(const []) {
    _init();
  }

  final ServiceDb _db;
  final ServiceStore? _legacyStore;

  Future<void> _init() async {
    final current = await _db.getAll();

    if (current.isEmpty && _legacyStore != null) {
      final legacy = await _legacyStore.getAll();
      if (legacy.isNotEmpty) {
        await _db.insertMany(legacy);
      }
    }

    // (Opcional) sembrar datos demo si sigue vacío
    if (await _db.isEmpty()) {
      await _db.seedDemoIfEmpty();
    }

    state = await _db.getAll();
  }

  Future<void> add(Service s) async {
    await _db.insert(s);
    state = [s, ...state];
  }

  Future<void> remove(String id) async {
    await _db.delete(id);
    state = state.where((e) => e.id != id).toList(growable: false);
  }

  Future<void> toggleDisponible(String id) async {
    final curr = state.firstWhere((e) => e.id == id);
    final newVal = !curr.disponible;
    await _db.updateDisponible(id, newVal);
    state = state
        .map((e) => e.id == id ? e.copyWith(disponible: newVal) : e)
        .toList(growable: false);
  }

  Future<void> reload() async {
    state = await _db.getAll();
  }

  /// Búsqueda con filtros (no altera `state`, devuelve resultados puntuales)
  Future<List<Service>> search(SearchFilters filters) {
    return _db.search(filters);
  }
}

// Providers
final serviceDbProvider = Provider<ServiceDb>((ref) => ServiceDb());
final serviceStoreProvider = Provider<ServiceStore?>((ref) => ServiceStore());

final serviceControllerProvider =
    StateNotifierProvider<ServiceController, List<Service>>(
      (ref) => ServiceController(
        ref.read(serviceDbProvider),
        ref.read(serviceStoreProvider),
      ),
    );
