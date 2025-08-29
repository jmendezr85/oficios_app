import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/job_request_api.dart';
import '../domain/job_request.dart';

class ClientHistoryScreen extends ConsumerStatefulWidget {
  const ClientHistoryScreen({super.key});

  @override
  ConsumerState<ClientHistoryScreen> createState() =>
      _ClientHistoryScreenState();
}

class _ClientHistoryScreenState extends ConsumerState<ClientHistoryScreen> {
  bool _loading = true;
  String? _status;
  String? _phone;
  List<JobRequest> _items = const [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('client_phone');
      if (!mounted) {
        return;
      }
      setState(() {
        _phone = saved;
      });
      await _load();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar el teléfono guardado')),
      );
    }
  }

  Future<void> _load() async {
    if (_phone == null || _phone!.trim().isEmpty) {
      setState(() {
        _items = const [];
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
    });
    try {
      final list = await JobRequestApi.listByClientPhone(
        _phone!,
        status: _status,
      );
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
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando historial: $e')));
    }
  }

  void _changeFilter(String? st) {
    setState(() {
      _status = st;
    });
    _load();
  }

  Future<void> _editPhoneDialog() async {
    final ctx = context;
    final ctrl = TextEditingController(text: _phone ?? '');
    final res = await showDialog<String>(
      context: ctx,
      builder: (context) {
        return AlertDialog(
          title: const Text('Teléfono del cliente'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'Ej: 3001234567'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, ctrl.text.trim());
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
    if (res == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('client_phone', res);
    if (!mounted) {
      return;
    }
    setState(() {
      _phone = res;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial del cliente'),
        actions: [
          IconButton(
            tooltip: 'Cambiar teléfono',
            onPressed: _editPhoneDialog,
            icon: const Icon(Icons.edit),
          ),
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
          if (_phone == null || _phone!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Aún no hay teléfono guardado. Toca el ícono ✎ para configurar tu número y ver tu historial.',
                      style: tt.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty && !_loading
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Column(
                            children: [
                              const Icon(Icons.history, size: 48),
                              const SizedBox(height: 12),
                              Text('Sin solicitudes', style: tt.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                _phone == null || _phone!.isEmpty
                                    ? 'Configura tu teléfono para ver tu historial.'
                                    : 'Cuando envíes una solicitud con tu número, aparecerá aquí.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final r = _items[i];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        r.descripcion,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    _StatusBadge(status: r.status),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_city, size: 16),
                                    const SizedBox(width: 4),
                                    Text(r.ciudad),
                                    const Spacer(),
                                    Text(
                                      '${r.creadoEn.day}/${r.creadoEn.month}/${r.creadoEn.year}',
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                if (r.scheduledAt != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.event, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${r.scheduledAt!.day}/${r.scheduledAt!.month} '
                                        '${r.scheduledAt!.hour.toString().padLeft(2, '0')}:'
                                        '${r.scheduledAt!.minute.toString().padLeft(2, '0')}',
                                      ),
                                    ],
                                  ),
                                ],
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
