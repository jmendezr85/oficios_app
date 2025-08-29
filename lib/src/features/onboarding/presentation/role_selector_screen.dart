import 'package:flutter/material.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  void _goClient(BuildContext context) {
    // Debe existir en app.dart: routes['/login'] = LoginScreen();
    Navigator.pushNamed(context, '/login');
  }

  void _goPro(BuildContext context) {
    // Debe existir en app.dart: routes['/register'] = RegisterScreen();
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Elige tu rol')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.handyman, size: 72, color: cs.primary),
                const SizedBox(height: 12),
                Text(
                  '¿Cómo quieres usar la app?',
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Soy Cliente
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.person_search),
                    onPressed: () => _goClient(context),
                    label: const Text('Soy Cliente'),
                  ),
                ),
                const SizedBox(height: 12),

                // Soy Profesional
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.home_repair_service),
                    onPressed: () => _goPro(context),
                    label: const Text('Soy Profesional'),
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'Como cliente podrás buscar profesionales y solicitar servicios.\n'
                  'Como profesional podrás administrar tus servicios y solicitudes.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
