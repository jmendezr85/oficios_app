import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pro/data/service_controller.dart';
import '../../pro/domain/service.dart';

class ServiceRegisterScreen extends ConsumerStatefulWidget {
  const ServiceRegisterScreen({super.key});

  @override
  ConsumerState<ServiceRegisterScreen> createState() =>
      _ServiceRegisterScreenState();
}

class _ServiceRegisterScreenState extends ConsumerState<ServiceRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _disponible = true;
  bool _loading = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _categoriaCtrl.dispose();
    _ciudadCtrl.dispose();
    _precioCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ctx = context;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    setState(() {
      _loading = true;
    });

    final precio =
        double.tryParse(_precioCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final service = Service(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: _tituloCtrl.text.trim(),
      categoria: _categoriaCtrl.text.trim(),
      ciudad: _ciudadCtrl.text.trim(),
      precioPorHora: precio,
      descripcion: _descCtrl.text.trim(),
      disponible: _disponible,
      creadoEn: DateTime.now(),
    );

    await Future.delayed(const Duration(milliseconds: 250));
    await ref.read(serviceControllerProvider.notifier).add(service);

    if (!ctx.mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(const SnackBar(content: Text('Servicio registrado')));
    Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar servicio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Completa la información', style: tt.titleLarge),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _tituloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título del servicio',
                    hintText: 'Ej: Instalación de enchufe doble',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa un título';
                    }
                    if (v.trim().length < 6) {
                      return 'Título muy corto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _categoriaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Categoría/Oficio',
                    hintText: 'Ej: Electricista, Carpintero...',
                    prefixIcon: Icon(Icons.category),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa una categoría/oficio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _ciudadCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    hintText: 'Ej: Bogotá',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa la ciudad';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _precioCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Precio por hora (COP)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa un precio';
                    }
                    final parsed = double.tryParse(v.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) {
                      return 'Precio inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Cuenta tu experiencia y qué ofreces',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 4,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa una descripción';
                    }
                    if (v.trim().length < 20) {
                      return 'Describe un poco más tu servicio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                SwitchListTile(
                  title: const Text('Disponible ahora'),
                  subtitle: const Text('Mostrar mi servicio como disponible'),
                  value: _disponible,
                  onChanged: (val) {
                    setState(() {
                      _disponible = val;
                    });
                  },
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_loading ? 'Guardando...' : 'Guardar servicio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
