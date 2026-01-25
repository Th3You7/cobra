class Validators {
  // Email validation
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }
  
  // Phone validation
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
  }
  
  // Password validation (min 8 chars, at least one letter and one number)
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    return true;
  }
  
  // URL validation
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Empty string check
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
