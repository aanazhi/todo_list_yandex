import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/tasks_provider.dart';

import 'package:todo_list_yandex/generated/l10n.dart';
import 'package:todo_list_yandex/logger/logger.dart';
import 'package:todo_list_yandex/utils/utils.dart';

class AddTaskButtonNew extends ConsumerWidget {
  const AddTaskButtonNew({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyle = context.textTheme;
    return Padding(
      padding: const EdgeInsets.only(right: 250.0),
      child: TextButton(
        onPressed: () async {
          TaskLogger().logDebug(
              'Очистка состояния задачи перед переходом к экрану добавления и редактирования задачи');
          ref.read(taskNameProvider.notifier).state = '';
          ref.read(importanceProvider.notifier).state = 'basic';
          ref.read(dueDateProvider.notifier).state = null;
          ref.read(isDueDateEnabledProvider.notifier).state = false;
          final result = await context.push<Task>('/addtask');
          if (result != null) {
            ref.read(tasksProvider.notifier).addTask(result);
          }
        },
        child: Text(
          S.of(context).newT,
          style: textStyle.bodySmall,
        ),
      ),
    );
  }
}
