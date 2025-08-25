import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pro/domain/service.dart';
import '../data/job_request_controller.dart';

class RequestNewScreen extends ConsumerStatefulWidget {
  const RequestNewScreen({super.key});

  @override
  ConsumerState<RequestNewScreen> createState() => _RequestNewScreenState();
}

class _RequestNewScreenState extends ConsumerState<RequestNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  DateTime? _scheduled;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    // Capturamos el BuildContext que vamos a reutilizar tras awaits
    final ctx = context;
    final now = DateTime.now();

    final date = await showDatePicker(
      context: ctx,
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
      initialDate: now,
    );
    if (date == null) return;

    // ⚠️ Después de un await, si vamos a usar "ctx" otra vez, debemos validar ctx.mounted
    if (!ctx.mounted) return;

    final time = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;

    // Para setState, validamos el State.
    if (!mounted) return;

    setState(() {
      _scheduled = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit(Service s) async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(jobRequestControllerProvider.notifier)
        .create(
          serviceId: s.id,
          clientName: _nameCtrl.text.trim(),
          clientPhone: _phoneCtrl.text.trim(),
          descripcion: _descCtrl.text.trim(),
          ciudad: _cityCtrl.text.trim().isEmpty
              ? s.ciudad
              : _cityCtrl.text.trim(),
          scheduledAt: _scheduled,
        );

    // ⚠️ Después del await, si vamos a usar "context" (del State), validamos mounted
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Solicitud enviada')));
    Navigator.of(context).pop(); // volver al detalle
  }

  @override
  Widget build(BuildContext context) {
    final serviceArg = ModalRoute.of(context)?.settings.arguments;
    if (serviceArg is! Service) {
      return const Scaffold(
        body: Center(child: Text('Servicio no encontrado')),
      );
    }
    final s = serviceArg;

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar servicio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _BannerService(service: s),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Nombre muy corto'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().length < 7)
                    ? 'Teléfono inválido'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityCtrl,
                decoration: InputDecoration(
                  labelText: 'Ciudad (opcional, por defecto: ${s.ciudad})',
                  prefixIcon: const Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descripción del trabajo',
                  hintText: 'Ej: instalar 3 enchufes en la sala...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Describe mejor la necesidad'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDateTime,
                      icon: const Icon(Icons.event),
                      label: Text(
                        _scheduled == null
                            ? 'Programar fecha/hora'
                            : 'Programado: ${_scheduled!.day}/${_scheduled!.month} '
                                  '${_scheduled!.hour.toString().padLeft(2, '0')}:${_scheduled!.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _submit(s),
                icon: const Icon(Icons.send),
                label: const Text('Enviar solicitud'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerService extends StatelessWidget {
  final Service service;
  const _BannerService({required this.service});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.titulo,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${service.categoria} • ${service.ciudad} • \$${service.precioPorHora.toStringAsFixed(0)}/h',
          ),
        ],
      ),
    );
  }
}
