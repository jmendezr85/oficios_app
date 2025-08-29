import 'package:flutter/material.dart';
import 'package:oficios_app/src/theme/app_theme.dart';

// Onboarding
import 'package:oficios_app/src/features/onboarding/presentation/role_selector_screen.dart';

// Auth / Home / Pantallas existentes
import 'package:oficios_app/src/features/auth/presentation/login_screen.dart';
import 'package:oficios_app/src/features/auth/presentation/register_screen.dart';
import 'package:oficios_app/src/features/home/presentation/home_screen.dart'; // opcional si sigues usando Home directa

// Search & Requests (deep screens)
import 'package:oficios_app/src/features/search/presentation/pro_list_screen.dart';
import 'package:oficios_app/src/features/search/presentation/pro_detail_screen.dart';
import 'package:oficios_app/src/features/requests/presentation/request_new_screen.dart';
import 'package:oficios_app/src/features/requests/presentation/requests_list_screen.dart';
import 'package:oficios_app/src/features/requests/presentation/client_history_screen.dart';

// Shells por rol (nuevo)
import 'package:oficios_app/src/shell/client_shell.dart';
import 'package:oficios_app/src/shell/pro_shell.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oficios App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light, // tu AppTheme existente
      home: const RoleSelectorScreen(),
      routes: {
        // Auth
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),

        // Shells por rol
        '/client': (_) => const ClientShell(),
        '/pro': (_) => const ProShell(),

        // Deep screens (se abren desde tabs o listas)
        '/home': (_) => const HomeScreen(), // si quieres mantenerla
        '/pro_list': (_) => const ProListScreen(),
        '/pro_detail': (_) => const ProDetailScreen(),
        '/request_new': (_) => const RequestNewScreen(),
        '/requests': (_) => const RequestsListScreen(),
        '/client_history': (_) => const ClientHistoryScreen(),
      },
    );
  }
}
