/// Base failure class
abstract class Failure {
  final String message;
  final int? code;
  
  const Failure(this.message, [this.code]);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;
  
  @override
  int get hashCode => message.hashCode ^ code.hashCode;
  
  @override
  String toString() => message;
}

/// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timeout', super.code]);
}

/// Storage failures
class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.code]);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}
