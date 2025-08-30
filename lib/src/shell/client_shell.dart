import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oficios_app/src/features/search/presentation/pro_list_screen.dart';
import 'package:oficios_app/src/features/requests/presentation/requests_list_screen.dart';

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;

  // 👇 Sin estado ni UI de filtros aquí.
  late final List<Widget> _pages = <Widget>[
    const ProListScreen(), // Buscar (aquí van los filtros si los tienes)
    const RequestsListScreen(), // Mis solicitudes
    const _ClientProfileScreen(), // Perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar aquí para no duplicar encabezados con ProListScreen
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _ClientProfileScreen extends StatelessWidget {
  const _ClientProfileScreen();

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_role');
    await prefs.remove('auth_email');
    await prefs.remove('auth_name');
    if (!context.mounted) return; // proteger BuildContext tras await
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu cuenta',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text('Aquí podrás editar tus datos más adelante.'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
