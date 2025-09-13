import 'package:flutter/material.dart';
import '../core/api_client.dart';

class DebugServiciosPage extends StatefulWidget {
  const DebugServiciosPage({super.key});
  @override
  State<DebugServiciosPage> createState() => _DebugServiciosPageState();
}

class _DebugServiciosPageState extends State<DebugServiciosPage> {
  final api = ApiClient();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = api.getServicios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servicios')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error:\n${snap.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final data = snap.data ?? [];
          if (data.isEmpty) return const Center(child: Text('Sin servicios'));
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final s = data[i] as Map<String, dynamic>;
              final cat = (s['Categoria'] as Map?)?['nombre'] ?? '—';
              return ListTile(
                title: Text('${s['nombre']}'),
                subtitle: Text(
                  'cat: $cat   \$${s['precio_base']}   id:${s['id']}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
