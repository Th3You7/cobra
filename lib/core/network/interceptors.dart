import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../config/api_config.dart';

/// Auth interceptor - adds token to requests and handles token refresh
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage = SecureStorage();
  final Dio _refreshDio = Dio(); // Separate Dio instance for refresh to avoid interceptor loop

  AuthInterceptor() {
    _refreshDio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: ApiConfig.headers,
    );
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getToken();

    if (token != null) {
      options.headers[ApiConfig.tokenHeader] = '${ApiConfig.tokenPrefix}$token';
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 - Unauthorized - attempt token refresh
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      
      if (refreshed) {
        // Retry the original request with new token
        try {
          final token = await _secureStorage.getToken();
          if (token != null) {
            err.requestOptions.headers[ApiConfig.tokenHeader] = 
                '${ApiConfig.tokenPrefix}$token';
            
            final response = await _refreshDio.fetch(err.requestOptions);
            return handler.resolve(response);
          }
        } catch (e) {
          // Refresh failed, proceed with error
        }
      }
      
      // If refresh failed or no refresh token, clear tokens and logout
      try {
        await _secureStorage.deleteToken();
        await _secureStorage.deleteRefreshToken();
      } catch (_) {
        // Ignore storage errors when clearing tokens; still proceed to reject with 401
      }
      // Note: Navigation to login will be handled by auth feature
    }

    super.onError(err, handler);
  }

  /// Attempt to refresh the access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final response = await _refreshDio.post(
        ApiConfig.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;
        
        if (newToken != null) {
          await _secureStorage.saveToken(newToken);
          if (newRefreshToken != null) {
            await _secureStorage.saveRefreshToken(newRefreshToken);
          }
          return true;
        }
      }
    } catch (e) {
      // Refresh failed
      return false;
    }
    
    return false;
  }
}

/// Error interceptor - handles common errors and logging
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error details for debugging
    // Additional error handling can be added here if needed
    // Most error handling is done in ErrorHandler class
    super.onError(err, handler);
  }
}
