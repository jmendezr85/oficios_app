import 'package:flutter/material.dart';
import '../../../core/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) {
      return;
    }
    if (!form.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // Si tienes AuthService.register, úsalo aquí.
      // await AuthService.register(name: _nameCtrl.text.trim(), email: _emailCtrl.text.trim(), password: _passCtrl.text);

      await AuthService.login(
        role: 'pro',
        email: _emailCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
      );

      if (!mounted) {
        return;
      }
      Navigator.pushNamedAndRemoveUntil(context, '/pro', (_) => false);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo registrar: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta (Profesional)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Regístrate',
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea tu cuenta para gestionar solicitudes.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
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

                TextFormField(
                  controller: _emailCtrl,
                  autofillHints: const [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty || !t.contains('@')) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (v) {
                    final t = v ?? '';
                    if (t.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add),
                    label: Text(_loading ? 'Creando...' : 'Crear cuenta'),
                  ),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: _loading ? null : _goToLogin,
                  child: Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: TextStyle(color: cs.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
