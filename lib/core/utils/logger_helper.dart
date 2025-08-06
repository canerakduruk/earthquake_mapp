import 'package:logger/logger.dart';

class LoggerHelper {
  static final Logger _logger = Logger();

  static String _format(String title, String message) {
    return "[$title] $message";
  }

  static void info(String title, String msg) {
    _logger.i(_format(title, msg));
  }

  static void debug(String title, String msg) {
    _logger.d(_format(title, msg));
  }

  static void warning(String title, String msg) {
    _logger.w(_format(title, msg));
  }

  static void err(
    String title,
    String msg, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (error != null && stackTrace != null) {
      _logger.e(_format(title, msg), error: error, stackTrace: stackTrace);
    } else if (error != null) {
      _logger.e(_format(title, msg), error: error);
    } else {
      _logger.e(_format(title, msg));
    }
  }
}
