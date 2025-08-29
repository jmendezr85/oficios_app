import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pro/domain/service.dart';
import '../domain/search_filters.dart';
import '../data/service_api.dart';

class ProListScreen extends ConsumerStatefulWidget {
  const ProListScreen({super.key});

  @override
  ConsumerState<ProListScreen> createState() => _ProListScreenState();
}

class _ProListScreenState extends ConsumerState<ProListScreen> {
  SearchFilters _filters = const SearchFilters(limit: 20, offset: 0);
  final List<Service> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  final TextEditingController _queryCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = context;
      final arg = ModalRoute.of(ctx)?.settings.arguments;
      if (arg is String && arg.trim().isNotEmpty) {
        _queryCtrl.text = arg;
        _filters = _filters.copyWith(query: arg);
      }
      _buscar(reset: true);
    });

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ======= ÚNICA implementación =======
  Future<void> _buscar({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _hasMore = true;
        _filters = _filters.copyWith(offset: 0);
        _items.clear();
      });
    }

    try {
      final list = await ServiceApi.search(_filters);
      if (!mounted) return;
      setState(() {
        _items.addAll(list);
        _loading = false;
        _hasMore = list.length == _filters.limit;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando servicios: $e')));
    }
  }

  // ======= ÚNICA implementación =======
  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);

    try {
      final next = _filters.copyWith(offset: _filters.offset + _filters.limit);
      final list = await ServiceApi.search(next);
      if (!mounted) return;
      setState(() {
        _filters = next;
        _items.addAll(list);
        _loadingMore = false;
        _hasMore = list.length == _filters.limit;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando más: $e')));
    }
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<SearchFilters>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _FiltersSheet(initial: _filters),
    );
    if (result != null) {
      setState(() => _filters = result);
      await _buscar(reset: true);
    }
  }

  void _changeSort(SortBy by) {
    setState(() => _filters = _filters.copyWith(sortBy: by));
    _buscar(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profesionales'),
        actions: [
          PopupMenuButton<SortBy>(
            tooltip: 'Ordenar',
            initialValue: _filters.sortBy,
            onSelected: _changeSort,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: SortBy.recientes,
                child: Text('Más recientes'),
              ),
              PopupMenuItem(
                value: SortBy.precioAsc,
                child: Text('Precio: menor a mayor'),
              ),
              PopupMenuItem(
                value: SortBy.precioDesc,
                child: Text('Precio: mayor a menor'),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            onPressed: _openFilters,
            icon: const Icon(Icons.tune),
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por oficio/ciudad...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (q) {
                      setState(
                        () => _filters = _filters.copyWith(query: q, offset: 0),
                      );
                      _buscar(reset: true);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    setState(
                      () => _filters = _filters.copyWith(
                        query: _queryCtrl.text,
                        offset: 0,
                      ),
                    );
                    _buscar(reset: true);
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _buscar(reset: true),
              child: _items.isEmpty && !_loading
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Column(
                            children: [
                              const Icon(Icons.search_off, size: 48),
                              const SizedBox(height: 12),
                              Text('No hay resultados', style: tt.titleMedium),
                              const SizedBox(height: 4),
                              const Text(
                                'Prueba cambiar los filtros o la búsqueda.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length + (_loadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        if (_loadingMore && i == _items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final s = _items[i];
                        return _ProCard(service: s, color: cs);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProCard extends StatelessWidget {
  final Service service;
  final ColorScheme color;
  const _ProCard({required this.service, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, '/pro_detail', arguments: service),
      child: Card(
        color: color.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.person, color: color.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${service.categoria} • ${service.ciudad}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: color.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: color.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 18,
                          color: color.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(service.precioPorHora.toStringAsFixed(0)),
                        const Spacer(),
                        Icon(
                          service.disponible
                              ? Icons.check_circle
                              : Icons.cancel_outlined,
                          size: 18,
                          color: service.disponible
                              ? color.secondary
                              : color.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  final SearchFilters initial;
  const _FiltersSheet({required this.initial});

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late final TextEditingController _categoriaCtrl;
  late final TextEditingController _ciudadCtrl;
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;
  bool? _disponible;
  SortBy _sortBy = SortBy.recientes;

  @override
  void initState() {
    super.initState();
    _categoriaCtrl = TextEditingController(
      text: widget.initial.categoria ?? '',
    );
    _ciudadCtrl = TextEditingController(text: widget.initial.ciudad ?? '');
    _minCtrl = TextEditingController(
      text: widget.initial.minPrecio?.toString() ?? '',
    );
    _maxCtrl = TextEditingController(
      text: widget.initial.maxPrecio?.toString() ?? '',
    );
    _disponible = widget.initial.disponible;
    _sortBy = widget.initial.sortBy;
  }

  @override
  void dispose() {
    _categoriaCtrl.dispose();
    _ciudadCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final min = double.tryParse(_minCtrl.text.replaceAll(',', '.'));
    final max = double.tryParse(_maxCtrl.text.replaceAll(',', '.'));
    final result = widget.initial.copyWith(
      categoria: _categoriaCtrl.text.trim().isEmpty
          ? null
          : _categoriaCtrl.text.trim(),
      ciudad: _ciudadCtrl.text.trim().isEmpty ? null : _ciudadCtrl.text.trim(),
      minPrecio: min,
      maxPrecio: max,
      disponible: _disponible,
      sortBy: _sortBy,
      offset: 0,
    );
    Navigator.pop(context, result);
  }

  void _clear() {
    Navigator.pop(context, const SearchFilters(limit: 20, offset: 0));
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoriaCtrl,
              decoration: const InputDecoration(
                labelText: 'Categoría (exacta)',
                hintText: 'Ej: Electricista',
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ciudadCtrl,
              decoration: const InputDecoration(
                labelText: 'Ciudad (exacta)',
                hintText: 'Ej: Bogotá',
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio mínimo',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio máximo',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<bool?>(
              value: _disponible,
              decoration: const InputDecoration(
                labelText: 'Disponibilidad',
                prefixIcon: Icon(Icons.toggle_on),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: true, child: Text('Solo disponibles')),
                DropdownMenuItem(value: false, child: Text('No disponibles')),
              ],
              onChanged: (val) => setState(() => _disponible = val),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SortBy>(
              value: _sortBy,
              decoration: const InputDecoration(
                labelText: 'Ordenar por',
                prefixIcon: Icon(Icons.sort),
              ),
              items: const [
                DropdownMenuItem(
                  value: SortBy.recientes,
                  child: Text('Más recientes'),
                ),
                DropdownMenuItem(
                  value: SortBy.precioAsc,
                  child: Text('Precio: menor a mayor'),
                ),
                DropdownMenuItem(
                  value: SortBy.precioDesc,
                  child: Text('Precio: mayor a menor'),
                ),
              ],
              onChanged: (val) =>
                  setState(() => _sortBy = val ?? SortBy.recientes),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Limpiar'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _apply,
                  icon: const Icon(Icons.check),
                  label: const Text('Aplicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
