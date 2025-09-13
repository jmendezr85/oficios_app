import 'package:flutter/material.dart';
import '../core/api_client.dart';

class DebugCategoriasPage extends StatefulWidget {
  const DebugCategoriasPage({super.key});
  @override
  State<DebugCategoriasPage> createState() => _DebugCategoriasPageState();
}

class _DebugCategoriasPageState extends State<DebugCategoriasPage> {
  final api = ApiClient();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = api.getCategorias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
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
          if (data.isEmpty) return const Center(child: Text('Sin categorías'));
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = data[i] as Map<String, dynamic>;
              return ListTile(
                title: Text('${c['nombre']}'),
                subtitle: Text('id: ${c['id']}'),
              );
            },
          );
        },
      ),
    );
  }
}
