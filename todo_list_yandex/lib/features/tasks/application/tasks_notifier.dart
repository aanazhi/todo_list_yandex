import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:uuid/uuid.dart';

class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier() : super(_initialTasks);

  static final List<Task> _initialTasks = [
    'Сделать что-то',
    'Сделать что-то',
    'Сделать что-то',
    'Сделать что-то',
    'Сделать что-то',
    'Сделать что-то',
    'Сделать что-то',
  ]
      .map((title) =>
          Task(id: const Uuid().v4(), title: title, importance: 'Нет'))
      .toList();

  void addTask(Task task) {
    state = [...state, task];
  }

  void removeTask(Task task) {
    state = state.where((t) => t.id != task.id).toList();
  }

  void toggleTaskCompletion(String id) {
    state = state.map((task) {
      if (task.id == id) {
        return Task(
            id: task.id,
            title: task.title,
            isCompleted: !task.isCompleted,
            importance: task.importance);
      }
      return task;
    }).toList();
  }

  void updateTask(Task updatedTask) {
    state = [
      for (final task in state)
        if (task.id == updatedTask.id) updatedTask else task
    ].toList();
  }
}
