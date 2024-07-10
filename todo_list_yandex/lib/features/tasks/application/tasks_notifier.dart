import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/services/tasks_sevice.dart';
import 'package:todo_list_yandex/logger/logger.dart';

class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TasksService tasksService;

  final Connectivity connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  TasksNotifier(this.tasksService, this.connectivity)
      : super(const AsyncValue.loading()) {
    _init();
    _listenToConnectivityChanges();

  }

  Future<void> _init() async {
    try {
      TaskLogger().logDebug('Инициализация задач...');
      final tasks = await tasksService.getTasksFromLocalStorage();
      state = AsyncValue.data(tasks);
      TaskLogger().logDebug(
          'Задачи успешно загружены из локального хранилища: ${tasks.length}');

      // Попытка загрузки задач с сервера
      if (await _isConnected()) {
        await _syncTasks();
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      TaskLogger().logError('Ошибка при инициализации задач: $e', stackTrace);
    }
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      for (var result in results) {
        if (result != ConnectivityResult.none) {
          TaskLogger()
              .logDebug('Подключение восстановлено. Синхронизация данных...');
          await _syncTasks();
          break;
        }
      }
    });
  }

  Future<bool> _isConnected() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> _syncTasks() async {
    try {
      final localTasks = await tasksService.getTasksFromLocalStorage();
      final serverTasks = await tasksService.updateTasks(localTasks);
      state = AsyncValue.data(serverTasks);
      TaskLogger().logDebug('Задачи успешно синхронизированы с сервером.');
    } catch (e, stackTrace) {
      TaskLogger().logError('Ошибка при синхронизации задач: $e', stackTrace);
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await tasksService.addTaskToLocalStorage(task);
      state = state.whenData((tasks) => [...tasks, task]);

      if (await _isConnected()) {
        await tasksService.addTask(task);
      }
    } catch (e) {
      throw Exception('Ошибка при добавлении задачи: $e');
    }
  }

  Future<void> deleteTask(Task task) async {
    final previousState = state;
    state =
        state.whenData((tasks) => tasks.where((t) => t.id != task.id).toList());

    try {
      await tasksService.deleteTaskFromLocalStorage(task.id);

      if (await _isConnected()) {
        await tasksService.deleteTask(task.id);
        TaskLogger().logDebug('Задача успешно удалена: ${task.id}');
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      state = previousState;
      TaskLogger().logError('Ошибка при удалении задачи: $e', stackTrace);
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
      await tasksService.updateTaskInLocalStorage(updatedTask);

      if (await _isConnected()) {
        await tasksService.editTask(updatedTask);
        TaskLogger().logDebug('Задача успешно обновлена: ${updatedTask.id}');
      }
    } catch (e, stackTrace) {
      TaskLogger().logError('Ошибка при обновлении задачи: $e', stackTrace);
      throw Exception('Ошибка при обновлении задачи: $e');
    }
  }

  Future<void> updateTasks(List<Task> updatedTasks) async {
    try {
      await tasksService.updateTasksInLocalStorage(updatedTasks);

      if (await _isConnected()) {
        final tasks = await tasksService.updateTasks(updatedTasks);
        state = AsyncValue.data(tasks);
      } else {
        state = AsyncValue.data(updatedTasks);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      TaskLogger().logError('Ошибка при обновлении задач: $e', stackTrace);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
