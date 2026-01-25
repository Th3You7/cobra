class ApiConstants {
  // Request Headers
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String accept = 'Accept';
  
  // Content Types
  static const String applicationJson = 'application/json';
  static const String multipartFormData = 'multipart/form-data';
  
  // Response Keys
  static const String data = 'data';
  static const String message = 'message';
  static const String error = 'error';
  static const String status = 'status';
  static const String token = 'token';
  
  // Status Codes
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int serverError = 500;
}
