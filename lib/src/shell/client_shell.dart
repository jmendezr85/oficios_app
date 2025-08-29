import 'package:flutter/material.dart';
import 'package:oficios_app/src/features/search/presentation/pro_list_screen.dart';
import 'package:oficios_app/src/features/requests/presentation/client_history_screen.dart';

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;

  // Páginas del cliente:
  late final List<Widget> _pages = [
    const ProListScreen(), // Buscar profesionales
    const ClientHistoryScreen(), // Historial del cliente
    const _ClientProfileScreen(), // Perfil (placeholder simple)
  ];

  @override
  Widget build(BuildContext context) {
    final destinations = const <NavigationDestination>[
      NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
      NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
      NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: destinations,
      ),
    );
  }
}

class _ClientProfileScreen extends StatelessWidget {
  const _ClientProfileScreen();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: Center(
        child: Text(
          'Aquí podrás editar tu nombre, teléfono y preferencias.',
          style: tt.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
