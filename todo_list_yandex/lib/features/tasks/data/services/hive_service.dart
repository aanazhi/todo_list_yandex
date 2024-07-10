import 'package:hive/hive.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/logger/logger.dart';

class HiveService {
  static const String boxName = 'tasksBox';
  final TaskLogger logger;
  final String boxNameOverride;

  HiveService(this.logger, {this.boxNameOverride = boxName});

  Future<Box<Task>> openBox() async {
    return await Hive.openBox<Task>(boxNameOverride);
  }

  Future<void> saveTask(Task task) async {
    final box = await openBox();
    await box.put(task.id, task);
    logger.logDebug('Task saved in box : ${task.id}');
  }

  Future<void> deleteTask(String taskId) async {
    final box = await openBox();
    await box.delete(taskId);
    logger.logDebug('Task delete in box : $taskId');
  }

  Future<List<Task>> getAllTasks() async {
    final box = await openBox();
    logger.logDebug('All tasks from box');
    return box.values.toList();
  }

  Future<void> clearBox() async {
    final box = await openBox();
    await box.clear();
  }

  Future<void> closeBox() async {
    final box = await Hive.openBox<Task>(boxNameOverride);
    await box.close();
  }
}
