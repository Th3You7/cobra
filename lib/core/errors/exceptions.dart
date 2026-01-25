/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final int? code;
  
  const AppException(this.message, [this.code]);
  
  @override
  String toString() => message;
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timeout', super.code]);
}

/// Storage exceptions
class StorageException extends AppException {
  const StorageException(super.message, [super.code]);
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}
