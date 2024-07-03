import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/services/tasks_sevice.dart';
import 'package:todo_list_yandex/logger/logger.dart';

class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TasksService tasksService;
  TasksNotifier(this.tasksService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      TaskLogger().logDebug('Инициализация задач...');
      final tasks = await tasksService.getAllTasks();
      state = AsyncValue.data(tasks);
      TaskLogger().logDebug('Задачи успешно загружены: ${tasks.length}');
    } catch (e) {
      TaskLogger().logDebug(
          'Ошибка при загрузке задач с сервера: $e. Попытка загрузки из локального хранилища...');
      try {
        final tasks = await tasksService.getTasksFromLocalStorage();
        if (tasks.isNotEmpty) {
          state = AsyncValue.data(tasks);
          TaskLogger().logDebug(
              'Задачи успешно загружены из локального хранилища: ${tasks.length}');
        } else {
          throw Exception('Локальное хранилище пусто');
        }
      } catch (localError, localStackTrace) {
        state = AsyncValue.error(localError, localStackTrace);
        TaskLogger().logDebug(
            'Ошибка при загрузке задач из локального хранилища: $localError');
      }
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await tasksService.addTask(task);
      state = state.whenData((tasks) => [...tasks, task]);
    } catch (e) {
      throw Exception('Ошибка при добавлении задачи: $e');
    }
  }

  Future<void> deleteTask(Task task) async {
    final previousState = state;
    state =
        state.whenData((tasks) => tasks.where((t) => t.id != task.id).toList());

    try {
      await tasksService.deleteTask(task.id);
      TaskLogger().logDebug('Задача успешно удалена: ${task.id}');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      state = previousState;
      TaskLogger().logError('Ошибка при удалении задачи: $e');
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    bool taskFound = false;

    state = state.whenData((tasks) {
      return tasks.map((task) {
        if (task.id == updatedTask.id) {
          taskFound = true;
          return updatedTask;
        } else {
          return task;
        }
      }).toList();
    });

    if (!taskFound) {
      throw Exception('Задача с идентификатором ${updatedTask.id} не найдена');
    }

    try {
      await tasksService.editTask(updatedTask);
      TaskLogger().logDebug('Задача успешно обновлена: ${updatedTask.id}');
    } catch (e) {
      TaskLogger().logError('Ошибка при обновлении задачи: $e');
      throw Exception('Ошибка при обновлении задачи: $e');
    }
  }

  Future<void> updateTasks(List<Task> updatedTasks) async {
    try {
      final tasks = await tasksService.updateTasks(updatedTasks);
      state = AsyncValue.data(tasks);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      TaskLogger().logError('Ошибка при обновлении задач: $e');
    }
  }
}
