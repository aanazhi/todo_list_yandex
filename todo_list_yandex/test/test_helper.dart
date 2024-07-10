import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';

Future<void> setUpTestHive() async {
  await Hive.initFlutter('test_hive');
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasksBox');
}
