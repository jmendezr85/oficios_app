import 'package:flutter/material.dart';
import '../../../core/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _decidirRuta() async {
    // Pequeño delay para ver el splash
    await Future.delayed(const Duration(seconds: 2));

    final logged = await AuthService.isLoggedIn();
    if (!mounted) {
      return;
    }
    if (logged) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/role');
    }
  }

  @override
  void initState() {
    super.initState();
    _decidirRuta();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlutterLogo(size: 96),
            SizedBox(height: 16),
            Text(
              'Oficios App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
