import 'package:flutter/material.dart';
import '../core/api_client.dart';
import 'debug_categorias_page.dart';
import 'debug_servicios_page.dart';

class DebugHome extends StatefulWidget {
  const DebugHome({super.key});
  @override
  State<DebugHome> createState() => _DebugHomeState();
}

class _DebugHomeState extends State<DebugHome> {
  final api = ApiClient();
  String _status = '—';

  @override
  void initState() {
    super.initState();
    _ping();
  }

  Future<void> _ping() async {
    try {
      final h = await api.getHealth();
      setState(() => _status = 'OK ${h['ok']} ${h['ts']}');
    } catch (e) {
      setState(() => _status = 'ERR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug API')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Health: $_status'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DebugCategoriasPage()),
              ),
              child: const Text('Ver Categorías'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DebugServiciosPage()),
              ),
              child: const Text('Ver Servicios'),
            ),
          ],
        ),
      ),
    );
  }
}
