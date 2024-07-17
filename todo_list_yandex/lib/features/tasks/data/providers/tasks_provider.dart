import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_yandex/features/tasks/application/tasks_notifier.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/services/hive_service.dart';
import 'package:todo_list_yandex/features/tasks/data/services/tasks_sevice.dart';
import 'package:todo_list_yandex/logger/logger.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  final taskLogger = ref.watch(taskLoggerProvider);
  return HiveService(taskLogger);
});

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

final taskLoggerProvider = Provider<TaskLogger>((ref) {
  return TaskLogger();
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final tasksServiceProvider = Provider<TasksService>((ref) {
  final dio = ref.watch(dioProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  final connectivity = ref.watch(connectivityProvider);
  return TasksService(
      dio: dio, hiveService: hiveService, connectivity: connectivity);
});

final tasksProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
  final tasksService = ref.watch(tasksServiceProvider);
  final connectivity = ref.watch(connectivityProvider);
  return TasksNotifier(tasksService, connectivity);
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


