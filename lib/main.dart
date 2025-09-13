import 'package:flutter/material.dart';
import 'src/debug/debug_home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oficios App (debug)',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
      home: const DebugHome(),
    );
  }
}
