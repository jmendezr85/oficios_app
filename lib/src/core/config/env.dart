/// Provides environment configuration values for the app.
///
/// The API base URL can be supplied at compile time using the
/// `--dart-define` option or a `.env` file with Flutter's
/// `--dart-define-from-file`.
///
/// Example:
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://example.com/api
/// # or
/// flutter run --dart-define-from-file=.env
/// ```
class Env {
  Env._();

  /// Base URL for the backend API.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.10/oficios_api',
  );
}
