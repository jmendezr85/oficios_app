import 'package:flutter/material.dart';
import '../../../core/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _goToRegister() {
    Navigator.pushNamed(context, '/register');
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
      // Si tienes AuthService, úsalo aquí.
      // await AuthService.login(email: _emailCtrl.text.trim(), password: _passCtrl.text);

      // Guardar sesión mínima local (rol cliente + email)
      await AuthService.login(role: 'client', email: _emailCtrl.text.trim());

      if (!mounted) {
        return;
      }
      Navigator.pushNamedAndRemoveUntil(context, '/client', (_) => false);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo iniciar sesión: $e')));
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
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Bienvenido',
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingresa con tu correo para continuar como cliente.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _emailCtrl,
                  autofillHints: const [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                  ),
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
                  autofillHints: const [AutofillHints.password],
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
                        : const Icon(Icons.login),
                    label: Text(_loading ? 'Ingresando...' : 'Iniciar sesión'),
                  ),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: _loading ? null : _goToRegister,
                  child: Text(
                    '¿No tienes cuenta? Regístrate',
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
