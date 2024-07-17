import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:todo_list_yandex/logger/logger.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static void logTaskEvent(String action, String taskId) {
    _analytics.logEvent(
      name: 'task_$action',
      parameters: <String, Object>{
        'task_id': taskId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static void logScreenView(String screenName) {
    TaskLogger().logDebug('Переход на экран: $screenName');
    _analytics.logEvent(
      name: 'screen_view',
      parameters: <String, Object>{
        'screen_name': screenName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
