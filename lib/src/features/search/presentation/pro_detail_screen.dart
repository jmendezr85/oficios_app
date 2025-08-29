import 'package:flutter/material.dart';
import '../../pro/domain/service.dart';

class ProDetailScreen extends StatelessWidget {
  const ProDetailScreen({super.key});

  void _goRequest(BuildContext context, Service s) {
    Navigator.pushNamed(context, '/request_new', arguments: s);
  }

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
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(s.titulo, overflow: TextOverflow.ellipsis)),
      // ✅ SIN floatingActionButton para evitar duplicado
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header / avatar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.person,
                    color: cs.onPrimaryContainer,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.titulo,
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${s.categoria} • ${s.ciudad}',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Precio / disponibilidad
            Row(
              children: [
                Icon(Icons.attach_money, size: 20, color: cs.primary),
                const SizedBox(width: 4),
                Text(
                  '${s.precioPorHora.toStringAsFixed(0)}/h',
                  style: tt.titleMedium,
                ),
                const Spacer(),
                Icon(
                  s.disponible ? Icons.check_circle : Icons.cancel_outlined,
                  size: 20,
                  color: s.disponible ? Colors.green : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  s.disponible ? 'Disponible' : 'No disponible',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Descripción
            Text(
              'Descripción',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(s.descripcion, style: tt.bodyMedium),
            const SizedBox(height: 24),

            // (Si luego quieres agregar reseñas, galería, etc., van aquí)
          ],
        ),
      ),

      // ✅ ÚNICO CTA (sin duplicados)
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _goRequest(context, s),
              icon: const Icon(Icons.send),
              label: const Text('Solicitar servicio'),
            ),
          ),
        ),
      ),
    );
  }
}
