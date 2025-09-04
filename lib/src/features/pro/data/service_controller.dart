import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../search/domain/search_filters.dart';
import '../domain/service.dart';
import 'service_api.dart';
import 'service_store.dart';

/// Controller that manages the professional services.
///
/// It delegates all persistence to the backend API and optionally keeps a
/// local cache using [ServiceStore] for offline availability.
class ServiceController extends StateNotifier<List<Service>> {
  ServiceController(this._api, this._cache) : super(const []) {
    _init();
  }

  final ServiceApi _api;
  final ServiceStore? _cache;
  String? _proPhone;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _proPhone = prefs.getString('auth_phone');

    try {
      if (_proPhone != null && _proPhone!.isNotEmpty) {
        final list = await _api.listByProPhone(_proPhone!);
        state = list;
        await _cache?.setAll(list);
        return;
      }
    } catch (_) {
      // ignore network errors and fall back to cache
    }

    // Fallback to cached data when network request fails or phone is missing
    state = await _cache?.getAll() ?? const [];
  }

  Future<void> add(Service s) async {
    final created = await _api.create(s);
    state = [created, ...state];
    await _cache?.setAll(state);
  }

  Future<void> remove(String id) async {
    await _api.delete(int.parse(id));
    state = state.where((e) => e.id != id).toList(growable: false);
    await _cache?.setAll(state);
  }

  Future<void> toggleDisponible(String id) async {
    final current = state.firstWhere((e) => e.id == id);
    final updated = current.copyWith(disponible: !current.disponible);
    await _api.update(updated);
    state = state.map((e) => e.id == id ? updated : e).toList(growable: false);
    await _cache?.setAll(state);
  }

  Future<void> reload() async {
    if (_proPhone == null || _proPhone!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _proPhone = prefs.getString('auth_phone');
    }
    if (_proPhone != null && _proPhone!.isNotEmpty) {
      final list = await _api.listByProPhone(_proPhone!);
      state = list;
      await _cache?.setAll(list);
    }
  }

  /// Search services using backend API. Only the query, limit and offset
  /// filters are currently supported by the endpoint.
  Future<List<Service>> search(SearchFilters filters) {
    final q = filters.query ?? '';
    return _api.search(q: q, limit: filters.limit, offset: filters.offset);
  }
}

// Providers
final serviceApiProvider = Provider<ServiceApi>((ref) => ServiceApi());
final serviceStoreProvider = Provider<ServiceStore?>((ref) => ServiceStore());

final serviceControllerProvider =
    StateNotifierProvider<ServiceController, List<Service>>(
      (ref) => ServiceController(
        ref.read(serviceApiProvider),
        ref.read(serviceStoreProvider),
      ),
    );
