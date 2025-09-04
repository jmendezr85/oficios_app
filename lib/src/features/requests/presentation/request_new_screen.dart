import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _sending = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final ctx = context; // capturamos el BuildContext actual
    final now = DateTime.now();

    final date = await showDatePicker(
      context: ctx,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      initialDate: now,
    );
    if (date == null) {
      return;
    }
    if (!ctx.mounted) {
      return;
    }

    final time = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null) {
      return;
    }
    if (!mounted) {
      return;
    }

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
    final form = _formKey.currentState;
    if (form == null) {
      return;
    }
    if (!form.validate()) {
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
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
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Solicitud enviada')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al enviar solicitud: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is! Service) {
      return const Scaffold(
        body: Center(child: Text('Servicio no encontrado')),
      );
    }
    final s = arg;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar servicio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner del servicio
              Container(
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.titulo,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.categoria} • ${s.ciudad} • \$${s.precioPorHora.toStringAsFixed(0)}/h',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nombre
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  prefixIcon: Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.length < 3) {
                    return 'Escribe tu nombre completo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Teléfono
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  hintText: 'Ej: 3001234567',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                  LengthLimitingTextInputFormatter(20),
                ],
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final t = (v ?? '').replaceAll(RegExp(r'\s'), '');
                  if (t.length < 7) {
                    return 'Teléfono inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Ciudad (opcional)
              TextFormField(
                controller: _cityCtrl,
                decoration: InputDecoration(
                  labelText: 'Ciudad (opcional, por defecto: ${s.ciudad})',
                  prefixIcon: const Icon(Icons.location_city),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Descripción
              TextFormField(
                controller: _descCtrl,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Descripción del trabajo',
                  hintText: 'Ej: instalar 3 enchufes en la sala...',
                  alignLabelWithHint: true,
                ),
                textInputAction: TextInputAction.newline,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.length < 10) {
                    return 'Describe mejor la necesidad (mín. 10 caracteres)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Programar fecha/hora (opcional)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sending ? null : _pickDateTime,
                      icon: const Icon(Icons.event),
                      label: Text(
                        _scheduled == null
                            ? 'Programar fecha/hora (opcional)'
                            : 'Programado: ${_scheduled!.day}/${_scheduled!.month} '
                                  '${_scheduled!.hour.toString().padLeft(2, '0')}:'
                                  '${_scheduled!.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  if (_scheduled != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Quitar programación',
                      onPressed: _sending
                          ? null
                          : () {
                              setState(() {
                                _scheduled = null;
                              });
                            },
                      icon: const Icon(Icons.clear),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // Enviar
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _sending ? null : () => _submit(s),
                  icon: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_sending ? 'Enviando...' : 'Enviar solicitud'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
