import 'package:flutter/material.dart';
import '../../pro/domain/service.dart';

class ProDetailScreen extends StatelessWidget {
  const ProDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is! Service) {
      return const Scaffold(
        body: Center(child: Text('Profesional no encontrado')),
      );
    }
    final s = arg;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(s.categoria)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.titulo,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('${s.ciudad} • \$${s.precioPorHora.toStringAsFixed(0)}/h'),
            const SizedBox(height: 12),
            Text(s.descripcion),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/request_new', arguments: s);
              },
              icon: const Icon(Icons.send),
              label: const Text('Solicitar servicio'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, '/request_new', arguments: s),
        icon: const Icon(Icons.message),
        label: const Text('Solicitar'),
        backgroundColor: cs.secondary,
        foregroundColor: cs.onSecondary,
      ),
    );
  }
}
