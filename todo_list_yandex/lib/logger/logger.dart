import 'package:logger/logger.dart';

class TaskLogger {
  final Logger logger = Logger();

  void logInfo(String message) {
    logger.i(message);
  }

  void logError(String message, StackTrace stackTrace) {
    logger.e('$message ; StackTrace - $stackTrace');
  }

  void logDebug(String message) {
    logger.d(message);
  }
}
