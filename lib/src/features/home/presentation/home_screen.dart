import 'package:flutter/material.dart';
import '../../../core/auth_service.dart';
import '../../search/data/recent_searches.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<String> _recientes = <String>[];

  @override
  void initState() {
    super.initState();
    _cargarRecientes();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarRecientes() async {
    final list = await RecentSearches.getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _recientes = list;
    });
  }

  Future<void> _guardarYBuscar(String query) async {
    final ctx = context; // capturar el BuildContext que usaremos
    final q = query.trim();
    if (q.isEmpty) {
      // seguro: no hubo await antes
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Escribe un oficio para buscar')),
      );
      return;
    }

    await RecentSearches.add(q);
    await _cargarRecientes();

    // proteger el MISMO contexto que vamos a usar
    if (!ctx.mounted) {
      return;
    }

    Navigator.pushNamed(ctx, '/pros', arguments: q);
  }

  void _buscarDesdeChip(String q) {
    _searchCtrl.text = q;
    Navigator.pushNamed(context, '/pros', arguments: q);
  }

  Future<void> _limpiarRecientes() async {
    final ctx = context; // capturar el contexto usado después del await
    await RecentSearches.clear();
    await _cargarRecientes();

    if (!ctx.mounted) {
      return;
    }

    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(content: Text('Búsquedas recientes borradas')),
    );
  }

  Future<void> _logout() async {
    final ctx = context; // capturar el contexto usado después del await
    await AuthService.logout();
    if (!ctx.mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(ctx, '/role', (route) => false);
  }

  void _goToServiceRegister() {
    Navigator.pushNamed(context, '/service_register');
  }

  void _goToMyServices() {
    Navigator.pushNamed(context, '/my_services');
  }

  void _goToProsQuick(String categoria) {
    _guardarYBuscar(categoria);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'register_service') {
                _goToServiceRegister();
              } else if (value == 'my_services') {
                _goToMyServices();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'register_service',
                child: Text('Registrar servicio'),
              ),
              PopupMenuItem(value: 'my_services', child: Text('Mis servicios')),
              PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Busca un oficio', style: tt.titleLarge),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Ej: carpintero, electricista, mecánico...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: _guardarYBuscar,
                  textInputAction: TextInputAction.search,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _guardarYBuscar(_searchCtrl.text),
                icon: const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text('Categorías rápidas', style: tt.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _CategoryChip(
                label: 'Carpintero',
                icon: Icons.handyman,
                onTap: () => _goToProsQuick('Carpintero'),
              ),
              _CategoryChip(
                label: 'Electricista',
                icon: Icons.bolt,
                onTap: () => _goToProsQuick('Electricista'),
              ),
              _CategoryChip(
                label: 'Plomero',
                icon: Icons.water_damage,
                onTap: () => _goToProsQuick('Plomero'),
              ),
              _CategoryChip(
                label: 'Mecánico',
                icon: Icons.car_repair,
                onTap: () => _goToProsQuick('Mecánico'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (_recientes.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text('Búsquedas recientes', style: tt.titleMedium),
                ),
                TextButton.icon(
                  onPressed: _limpiarRecientes,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Limpiar'),
                  style: TextButton.styleFrom(foregroundColor: cs.error),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recientes
                  .map(
                    (q) => ActionChip(
                      label: Text(q, overflow: TextOverflow.ellipsis),
                      onPressed: () => _buscarDesdeChip(q),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: cs.onPrimaryContainer),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: cs.onPrimaryContainer)),
          ],
        ),
      ),
    );
  }
}
