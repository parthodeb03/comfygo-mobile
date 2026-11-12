import 'dart:developer' as developer;

/// Lightweight app logger.
///
/// Uses [developer.log] so output shows up in Dart DevTools / flutter run
/// console instead of leaking raw prints in production code.
class AppLogger { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  AppLogger._();

  static void info(String message) => developer.log(message, name: 'INFO');

  static void warning(String message) => developer.log(message, name: 'WARN');

  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      developer.log(
        message,
        name: 'ERROR',
        error: error,
        stackTrace: stackTrace,
      );
}
