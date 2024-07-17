import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/services/analytics_service.dart';
import 'package:todo_list_yandex/features/tasks/presentation/screens/add_edit_task_screen.dart';
import 'package:todo_list_yandex/features/tasks/presentation/screens/home_screen.dart';

class AppRouter {
  final GoRouter router;

  AppRouter()
      : router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) {
                AnalyticsService.logScreenView('HomeScreen');
                return const HomeScreen();
              },
            ),
            GoRoute(
              path: '/addtask',
              builder: (context, state) {
                final task = state.extra as Task?;
                AnalyticsService.logScreenView('AddEditTaskScreen');
                return AddEditTaskScreen(task: task);
              },
            ),
          ],
        );

  void navigateToAddTask(BuildContext context, {Task? task}) {
    router.go('/addtask', extra: task);
  }
}
