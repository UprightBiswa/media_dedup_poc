import 'dart:developer' as developer;

class AppLogger {
  void info(String scope, String message) {
    developer.log(message, name: scope);
  }

  void warning(String scope, String message) {
    developer.log(message, name: scope, level: 900);
  }

  void error(
    String scope,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    developer.log(
      message,
      name: scope,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
