import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _keyRole = 'auth_role';
  static const _keyEmail = 'auth_email';
  static const _keyName = 'auth_name';
  static const _storage = FlutterSecureStorage();

  /// Devuelve true si hay sesión guardada
  static Future<bool> isLoggedIn() async {
    final role = await _storage.read(key: _keyRole);
    return role != null;
  }

  /// Guarda sesión (aquí podrías guardar token real)
  static Future<void> login({
    required String role,
    required String email,
    String? name,
  }) async {
    await _storage.write(key: _keyRole, value: role);
    await _storage.write(key: _keyEmail, value: email);
    if (name != null) {
      await _storage.write(key: _keyName, value: name);
    }
  }

  /// Limpia la sesión
  static Future<void> logout() async {
    await _storage.delete(key: _keyRole);
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyName);
  }

  /// (Opcional) Obtener el email guardado
  static Future<String?> getEmail() => _storage.read(key: _keyEmail);
  static Future<String?> getRole() => _storage.read(key: _keyRole);
  static Future<String?> getName() => _storage.read(key: _keyName);
}
