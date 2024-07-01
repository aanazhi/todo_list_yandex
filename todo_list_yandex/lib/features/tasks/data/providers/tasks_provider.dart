import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_yandex/features/tasks/application/tasks_notifier.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier();
});

final taskNameProvider = StateProvider<String>((ref) => '');
final importanceProvider = StateProvider<String>((ref) => 'Нет');
final dueDateProvider = StateProvider<DateTime?>((ref) => null);
final isDueDateEnabledProvider = StateProvider<bool>((ref) => false);
final taskVisibilityProvider = StateProvider<bool>((ref) => false);
final completedTasksProvider = StateProvider<List<String>>((ref) => []);

final resetStateProvider = Provider<void>((ref) {
  ref.read(taskNameProvider.notifier).state = '';
  ref.read(importanceProvider.notifier).state = 'Нет';
  ref.read(dueDateProvider.notifier).state = null;
  ref.read(isDueDateEnabledProvider.notifier).state = false;
});
