import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/service_controller.dart';
import 'package:oficios_app/src/features/pro/presentation/service_register_screen.dart';

/// Lista de servicios ofrecidos por el profesional.
/// Ahora se conecta al controlador de servicios del usuario.
class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await ref.read(serviceControllerProvider.notifier).reload();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(serviceControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Servicios')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : services.isEmpty
          ? const Center(child: Text('Aún no has registrado servicios'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final service = services[index];
                return ListTile(
                  leading: const Icon(Icons.build_circle_outlined),
                  title: Text(service.titulo),
                  subtitle: Text(service.descripcion),
                  trailing: IconButton(
                    tooltip: 'Editar',
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Editar ${service.titulo}')),
                      );
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
