import 'package:flutter/material.dart';
import 'package:oficios_app/src/features/requests/presentation/requests_list_screen.dart';
// Si ya tienes esta pantalla real, usa su import real:
import 'package:oficios_app/src/features/pro/presentation/service_register_screen.dart';

class ProShell extends StatefulWidget {
  const ProShell({super.key});

  @override
  State<ProShell> createState() => _ProShellState();
}

class _ProShellState extends State<ProShell> {
  int _index = 0;

  late final List<Widget> _pages = [
    const RequestsListScreen(), // Solicitudes recibidas
    const ServiceRegisterScreen(), // Mis servicios (form/lista básica)
    const _ProProfileScreen(), // Perfil profesional (placeholder)
  ];

  @override
  Widget build(BuildContext context) {
    final destinations = const <NavigationDestination>[
      NavigationDestination(icon: Icon(Icons.inbox), label: 'Solicitudes'),
      NavigationDestination(icon: Icon(Icons.build), label: 'Servicios'),
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

class _ProProfileScreen extends StatelessWidget {
  const _ProProfileScreen();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil profesional')),
      body: Center(
        child: Text(
          'Aquí podrás editar tu nombre, ciudad, disponibilidad y tarifa.',
          style: tt.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
