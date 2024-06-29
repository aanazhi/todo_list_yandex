import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_yandex/features/tasks/application/tasks_notifier.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/services/tasks_sevice.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      followRedirects: true,
      validateStatus: (status) {
        return status != null && status < 400;
      },
    ),
  );

  return dio;
});

final tasksServiceProvider = Provider<TasksService>((ref) {
  return TasksService(dio: ref.watch(dioProvider));
});

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier(ref.watch(tasksServiceProvider));
});

final taskNameProvider = StateProvider<String>((ref) => '');
final importanceProvider = StateProvider<String>((ref) => 'basic');
final dueDateProvider = StateProvider<DateTime?>((ref) => null);
final isDueDateEnabledProvider = StateProvider<bool>((ref) => false);
final taskVisibilityProvider = StateProvider<bool>((ref) => false);
final completedTasksProvider = StateProvider<List<String>>((ref) => []);

final resetStateProvider = Provider<void>((ref) {
  ref.read(taskNameProvider.notifier).state = '';
  ref.read(importanceProvider.notifier).state = 'basic';
  ref.read(dueDateProvider.notifier).state = null;
  ref.read(isDueDateEnabledProvider.notifier).state = false;
});
