import 'package:flutter/material.dart';
import 'package:oficios_app/src/features/pro/presentation/service_register_screen.dart';

/// Lista de servicios ofrecidos por el profesional.
/// De momento usa datos de ejemplo; luego se conecta a tu API/SQLite.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const demoServices = <Map<String, String>>[
      {
        'title': 'Electricidad',
        'desc': 'Instalaciones y reparaciones eléctricas',
      },
      {'title': 'Plomería', 'desc': 'Reparación de fugas y mantenimiento'},
      {'title': 'Carpintería', 'desc': 'Muebles a medida y reparaciones'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Servicios')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demoServices.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final service = demoServices[index];
          final title = service['title'] ?? '';
          final desc = service['desc'] ?? '';

          return ListTile(
            leading: const Icon(Icons.build_circle_outlined),
            title: Text(title),
            subtitle: Text(desc),
            trailing: IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit),
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Editar $title')));
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ServiceRegisterScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }
}
