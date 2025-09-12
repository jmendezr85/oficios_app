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
  /// Must point to an HTTPS endpoint. You can override this value at build
  /// time using `--dart-define` or `--dart-define-from-file`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://example.com/prod',
  );
}
