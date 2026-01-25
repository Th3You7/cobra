import 'package:intl/intl.dart';

class Formatters {
  // Date formatters
  static String formatDate(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
    return DateFormat(pattern).format(date);
  }
  
  static String formatDateTime(DateTime date, {String pattern = 'yyyy-MM-dd HH:mm'}) {
    return DateFormat(pattern).format(date);
  }
  
  static String formatTime(DateTime date, {String pattern = 'HH:mm'}) {
    return DateFormat(pattern).format(date);
  }
  
  // Duration formatter
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  // Number formatters
  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }
  
  // File size formatter
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
