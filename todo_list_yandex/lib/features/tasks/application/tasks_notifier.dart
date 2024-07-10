import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/services/tasks_sevice.dart';
import 'package:todo_list_yandex/logger/logger.dart';

class TasksNotifier extends StateNotifier<List<Task>> {
  final TasksService tasksService;
  TasksNotifier(this.tasksService) : super([]) {
    _init();
    _listenToConnectivityChanges();
  }

  List<Task> tasks = [];

  Future<void> _init() async {
    try {
      logger.d('Инициализация задач...');
      final tasks = await tasksService.getAllTasks();
      state = tasks;
      logger.d('Задачи успешно загружены: ${tasks.length}');
    } catch (e) {
      logger.e('Ошибка при загрузке задач: $e');
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await tasksService.addTask(task);
      state = [...state, task];
    } catch (e) {
      logger.d('Ошибка при добавлении задачи: $e');
      throw Exception('Ошибка при добавлении задачи: $e');
    }
  }

  Future<void> deleteTask(Task task) async {
    state = state.where((t) => t.id != task.id).toList();

    try {
      await tasksService.deleteTask(task.id);
      logger.d('Задача успешно удалена: ${task.id}');
    } on Exception catch (e) {
      logger.e('Ошибка при удалении задачи: $e');

      state = [...state, task];
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    bool taskFound = false;

    state = state.map((task) {
      if (task.id == updatedTask.id) {
        taskFound = true;
        return updatedTask;
      } else {
        return task;
      }
    }).toList();

    if (!taskFound) {
      throw Exception('Задача с идентификатором ${updatedTask.id} не найдена');
    }

    try {
      await tasksService.editTask(updatedTask);
      logger.d('Задача успешно обновлена: ${updatedTask.id}');
    } catch (e) {
      logger.e('Ошибка при обновлении задачи: $e');
      throw Exception('Ошибка при обновлении задачи: $e');
    }
  }

  Future<void> updateTasks(List<Task> updatedTasks) async {
    try {
      tasks = await tasksService.updateTasks(updatedTasks);
    } catch (e) {
      logger.e('Ошибка при обновлении задач: $e');
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
