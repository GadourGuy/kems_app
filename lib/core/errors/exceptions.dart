class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}