import 'package:flutter/material.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  void _go(BuildContext context, String route, {Object? args}) {
    Navigator.pushNamed(context, route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Elige tu rol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('¿Cómo deseas usar la app?', style: tt.titleLarge),
            const SizedBox(height: 24),

            // CLIENTE → ir directo a la lista de profesionales (demo)
            _RoleCard(
              title: 'Soy Cliente',
              subtitle: 'Ver profesionales cercanos por oficio',
              icon: Icons.search,
              onTap: () => _go(
                context,
                '/pros',
                args: 'Carpintero',
              ), // puedes cambiar la categoría inicial
            ),
            const SizedBox(height: 16),

            // PROFESIONAL → ir directo al formulario de registrar servicio (demo)
            _RoleCard(
              title: 'Soy Profesional',
              subtitle: 'Registrar mi servicio y disponibilidad',
              icon: Icons.home_repair_service,
              onTap: () => _go(context, '/service_register'),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Accesos secundarios al flujo con autenticación
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => _go(context, '/login'),
                  child: Text(
                    'Iniciar sesión',
                    style: TextStyle(color: cs.primary),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _go(context, '/register'),
                  child: Text(
                    'Crear cuenta',
                    style: TextStyle(color: cs.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: cs.primaryContainer,
                child: Icon(icon, size: 28, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
