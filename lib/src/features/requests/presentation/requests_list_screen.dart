import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/job_request_api.dart';
import '../data/job_request_controller.dart';
import '../domain/job_request.dart';

class RequestsListScreen extends ConsumerStatefulWidget {
  const RequestsListScreen({super.key});

  @override
  ConsumerState<RequestsListScreen> createState() => _RequestsListScreenState();
}

class _RequestsListScreenState extends ConsumerState<RequestsListScreen> {
  bool _loading = true;
  String? _status; // null -> todas
  List<JobRequest> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await JobRequestApi.list(status: _status);
      if (!mounted) {
        return;
      }
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando solicitudes: $e')));
    }
  }

  void _changeFilter(String? st) {
    setState(() => _status = st);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final locals = ref.watch(jobRequestControllerProvider);
    final localFiltered = locals
        .where((r) => _status == null || r.status == _status)
        .toList();
    final items = [
      ..._items,
      ...localFiltered.where((l) => _items.every((r) => r.id != l.id)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis solicitudes'),
        actions: [
          PopupMenuButton<String?>(
            tooltip: 'Filtrar estado',
            onSelected: _changeFilter,
            itemBuilder: (context) => const [
              PopupMenuItem(value: null, child: Text('Todas')),
              PopupMenuItem(value: 'pending', child: Text('Pendientes')),
              PopupMenuItem(value: 'accepted', child: Text('Aceptadas')),
              PopupMenuItem(value: 'rejected', child: Text('Rechazadas')),
              PopupMenuItem(value: 'completed', child: Text('Completadas')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: items.isEmpty && !_loading
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Column(
                            children: [
                              const Icon(Icons.inbox_outlined, size: 48),
                              const SizedBox(height: 12),
                              Text('No hay solicitudes', style: tt.titleMedium),
                              const SizedBox(height: 4),
                              const Text(
                                'Cuando envíes una solicitud aparecerá aquí.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final r = items[i];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.request_page,
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              r.clientName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          _StatusBadge(status: r.status),
                                          const SizedBox(width: 8),
                                          _ActionsMenu(
                                            current: r.status,
                                            onSelect: (newStatus) async {
                                              final ctx =
                                                  context; // capturamos el BuildContext
                                              try {
                                                await JobRequestApi.updateStatus(
                                                  id: r.id,
                                                  status: newStatus,
                                                );
                                                ref
                                                    .read(
                                                      jobRequestControllerProvider
                                                          .notifier,
                                                    )
                                                    .setStatus(r.id, newStatus);
                                                if (!mounted || !ctx.mounted) {
                                                  return;
                                                }
                                                setState(() {
                                                  final idx = _items.indexWhere(
                                                    (e) => e.id == r.id,
                                                  );
                                                  if (idx >= 0) {
                                                    _items[idx] = _items[idx]
                                                        .copyWith(
                                                          status: newStatus,
                                                        );
                                                  }
                                                });
                                                ScaffoldMessenger.of(
                                                  ctx,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Estado actualizado a $newStatus',
                                                    ),
                                                  ),
                                                );
                                              } catch (e) {
                                                if (!mounted || !ctx.mounted) {
                                                  return;
                                                }
                                                ScaffoldMessenger.of(
                                                  ctx,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error al actualizar estado: $e',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        r.descripcion,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_city,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(r.ciudad),
                                          const Spacer(),
                                          if (r.scheduledAt != null)
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.event,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${r.scheduledAt!.day}/${r.scheduledAt!.month} '
                                                  '${r.scheduledAt!.hour.toString().padLeft(2, '0')}:'
                                                  '${r.scheduledAt!.minute.toString().padLeft(2, '0')}',
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'accepted':
        bg = cs.secondaryContainer;
        fg = cs.onSecondaryContainer;
        label = 'Aceptada';
        break;
      case 'rejected':
        bg = Colors.red.withValues(alpha: 0.15);
        fg = Colors.red.shade800;
        label = 'Rechazada';
        break;
      case 'completed':
        bg = Colors.green.withValues(alpha: 0.15);
        fg = Colors.green.shade800;
        label = 'Completada';
        break;
      default:
        bg = cs.surfaceContainerHighest;
        fg = cs.onSurfaceVariant;
        label = 'Pendiente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelect;
  const _ActionsMenu({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = <MapEntry<String, String>>[
      const MapEntry('pending', 'Marcar como Pendiente'),
      const MapEntry('accepted', 'Aceptar'),
      const MapEntry('rejected', 'Rechazar'),
      const MapEntry('completed', 'Completar'),
    ].where((e) => e.key != current).toList(growable: false);

    return PopupMenuButton<String>(
      tooltip: 'Cambiar estado',
      onSelected: onSelect,
      itemBuilder: (context) => options
          .map((e) => PopupMenuItem<String>(value: e.key, child: Text(e.value)))
          .toList(),
      icon: const Icon(Icons.more_vert),
    );
  }
}
