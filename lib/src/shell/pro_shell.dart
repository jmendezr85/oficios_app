import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oficios_app/src/features/requests/presentation/requests_list_screen.dart';
import 'package:oficios_app/src/features/pro/presentation/services_screen.dart';
import 'package:oficios_app/src/features/pro/presentation/service_register_screen.dart';

class ProShell extends StatefulWidget {
  const ProShell({super.key});

  @override
  State<ProShell> createState() => _ProShellState();
}

class _ProShellState extends State<ProShell> {
  int _index = 0;

  late final List<Widget> _pages = <Widget>[
    const RequestsListScreen(), // Solicitudes recibidas
    const ServicesScreen(), // Lista de servicios
    const ServiceRegisterScreen(), // Registrar servicio
    const _ProProfileScreen(), // Perfil profesional
  ];

  @override
  Widget build(BuildContext context) {
    // Punto de quiebre simple: rail para pantallas anchas
    final isWide = MediaQuery.of(context).size.width >= 900;

    final destinations = const <NavigationDestination>[
      NavigationDestination(
        icon: Icon(Icons.inbox_outlined),
        selectedIcon: Icon(Icons.inbox),
        label: 'Solicitudes',
      ),
      NavigationDestination(
        icon: Icon(Icons.list_alt_outlined),
        selectedIcon: Icon(Icons.list_alt),
        label: 'Servicios',
      ),
      NavigationDestination(
        icon: Icon(Icons.add_box_outlined),
        selectedIcon: Icon(Icons.add_box),
        label: 'Registrar',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ];

    final railDestinations = const <NavigationRailDestination>[
      NavigationRailDestination(
        icon: Icon(Icons.inbox_outlined),
        selectedIcon: Icon(Icons.inbox),
        label: Text('Solicitudes'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.list_alt_outlined),
        selectedIcon: Icon(Icons.list_alt),
        label: Text('Servicios'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.add_box_outlined),
        selectedIcon: Icon(Icons.add_box),
        label: Text('Registrar'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: Text('Perfil'),
      ),
    ];

    final body = IndexedStack(index: _index, children: _pages);

    if (!isWide) {
      // Layout móvil: NavigationBar inferior
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: destinations,
        ),
      );
    }

    // Layout ancho: NavigationRail lateral + AppBar simple
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Profesional')),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            destinations: railDestinations,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (i) => setState(() => _index = i),
            leading: const SizedBox(height: 8),
            trailing: const SizedBox(height: 8),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _ProProfileScreen extends StatelessWidget {
  const _ProProfileScreen();

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_role');
    await prefs.remove('auth_email');
    await prefs.remove('auth_name');
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil profesional')),
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
            const Text('Aquí podrás editar datos de perfil más adelante.'),
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
