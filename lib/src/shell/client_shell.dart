import 'package:flutter/material.dart';

import 'package:oficios_app/src/features/search/presentation/pro_list_screen.dart';
import 'package:oficios_app/src/features/requests/presentation/requests_list_screen.dart';
import 'user_profile_screen.dart';

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
    const UserProfileScreen(title: 'Perfil de cliente'), // Perfil
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
