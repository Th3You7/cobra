import 'package:dio/dio.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  static Failure handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is AppException) {
      return _handleAppException(error);
    } else {
      return ServerFailure('An unexpected error occurred');
    }
  }
  
  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure('Connection timeout');
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error';
        
        switch (statusCode) {
          case 400:
            return ServerFailure('Bad request: $message', statusCode);
          case 401:
            return AuthFailure('Unauthorized: $message', statusCode);
          case 403:
            return AuthFailure('Forbidden: $message', statusCode);
          case 404:
            return ServerFailure('Not found: $message', statusCode);
          case 500:
            return ServerFailure('Server error: $message', statusCode);
          default:
            return ServerFailure(message, statusCode);
        }
        
      case DioExceptionType.cancel:
        return const NetworkFailure('Request cancelled');
        
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');
        
      default:
        return NetworkFailure(error.message ?? 'Network error');
    }
  }
  
  static Failure _handleAppException(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message, exception.code);
    } else if (exception is ServerException) {
      return ServerFailure(exception.message, exception.code);
    } else if (exception is StorageException) {
      return StorageFailure(exception.message, exception.code);
    } else if (exception is AuthException) {
      return AuthFailure(exception.message, exception.code);
    } else {
      return ServerFailure(exception.message, exception.code);
    }
  }
  
  static String getErrorMessage(Failure failure) {
    return failure.message;
  }
}
