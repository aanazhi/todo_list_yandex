import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/tasks_provider.dart';
import 'package:todo_list_yandex/features/tasks/presentation/screens/add_edit_task_screen.dart';
import 'package:todo_list_yandex/logger/logger.dart';

class AddTaskButtonPlus extends ConsumerWidget {
  final ColorScheme colors;

  const AddTaskButtonPlus({
    super.key,
    required this.colors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () async {
          logger
              .d('Очистка состояния задачи перед переходом к экрану добавления и редактирования задачи');
          ref.read(taskNameProvider.notifier).state = '';
          ref.read(importanceProvider.notifier).state = 'basic';
          ref.read(dueDateProvider.notifier).state = null;
          ref.read(isDueDateEnabledProvider.notifier).state = false;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
          if (result != null && result is Task) {
            ref.read(tasksProvider.notifier).addTask(result);
          }
        },
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: colors.surface),
      ),
    );
  }
}
