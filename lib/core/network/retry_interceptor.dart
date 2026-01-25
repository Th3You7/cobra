import 'package:dio/dio.dart';
import '../config/api_config.dart';

/// Retry interceptor - automatically retries failed requests
class RetryInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Don't retry on certain status codes
    if (err.response?.statusCode != null) {
      final statusCode = err.response!.statusCode!;
      if (statusCode >= 400 && statusCode < 500 && statusCode != 408) {
        // Don't retry client errors (except timeout)
        return super.onError(err, handler);
      }
    }

    // Don't retry if request was cancelled
    if (err.type == DioExceptionType.cancel) {
      return super.onError(err, handler);
    }

    // Get retry count from options or use default
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 
                       ApiConfig.retryCount;
    final currentRetry = err.requestOptions.extra['currentRetry'] as int? ?? 0;

    if (currentRetry < retryCount) {
      // Wait before retrying
      await Future.delayed(ApiConfig.retryDelay * (currentRetry + 1));

      // Update retry count
      err.requestOptions.extra['currentRetry'] = currentRetry + 1;

      try {
        // Retry the request
        final response = await _retry(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // If retry fails, continue with error
        if (e is DioException) {
          return super.onError(e, handler);
        }
        return super.onError(err, handler);
      }
    }

    return super.onError(err, handler);
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return Dio().request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
