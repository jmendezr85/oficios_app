import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/job_request_controller.dart';
import '../domain/job_request.dart';

class RequestsListScreen extends ConsumerWidget {
  const RequestsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(jobRequestControllerProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis solicitudes')),
      body: list.isEmpty
          ? const Center(child: Text('Aún no tienes solicitudes.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final r = list[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      r.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${r.ciudad} • ${r.status} • ${r.creadoEn.day}/${r.creadoEn.month}',
                    ),
                    trailing: Icon(Icons.chevron_right, color: cs.primary),
                  ),
                );
              },
            ),
    );
  }
}
