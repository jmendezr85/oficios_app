import 'package:flutter/material.dart';

// Tema (solo light)
import 'theme/app_theme.dart';

// Onboarding
import 'features/onboarding/presentation/splash_screen.dart';
import 'features/onboarding/presentation/role_selector_screen.dart';

// Auth / Home
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/home/presentation/home_screen.dart';

// Búsqueda / Profesionales
import 'features/search/presentation/pro_list_screen.dart';
import 'features/search/presentation/pro_detail_screen.dart';

// Profesional
import 'features/pro/presentation/service_register_screen.dart';
import 'features/pro/presentation/my_services_screen.dart';

// ...
import 'features/requests/presentation/request_new_screen.dart';
import 'features/requests/presentation/requests_list_screen.dart';
// ...

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oficios App',
      debugShowCheckedModeBanner: false,

      // Solo tema claro (amarillo)
      theme: AppTheme.light,

      // Ruta inicial (puedes cambiar a '/splash' si tienes splash funcional)
      initialRoute: '/role',

      routes: {
        // Onboarding
        '/splash': (_) => const SplashScreen(),
        '/role': (_) => const RoleSelectorScreen(),

        // Auth / Home
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),

        // Búsqueda / Profesionales
        '/pros': (_) => const ProListScreen(),
        '/pro_detail': (_) => const ProDetailScreen(),

        // Profesional
        '/service_register': (_) => const ServiceRegisterScreen(),
        '/my_services': (_) => const MyServicesScreen(),

        '/request_new': (_) => const RequestNewScreen(), // 👈 nueva
        '/requests': (_) => const RequestsListScreen(), // 👈 nueva
      },

      // Fallback por si llega una ruta desconocida
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        builder: (_) => const RoleSelectorScreen(),
        settings: const RouteSettings(name: '/role'),
      ),
    );
  }
}
