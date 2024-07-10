import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/tasks_provider.dart';
import 'package:todo_list_yandex/features/tasks/presentation/screens/add_edit_task_screen.dart';
import 'package:todo_list_yandex/logger/logger.dart';
import 'package:todo_list_yandex/utils/extensions.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colorScheme;
    final textStyle = context.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          tileColor: colors.surface,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: textStyle.bodyMedium,
                  children: [
                    if (task.importance == 'important')
                      TextSpan(
                        text: '!! ',
                        style: textStyle.bodyMedium?.copyWith(
                          fontSize: 25,
                          color: colors.error,
                        ),
                      ),
                    if (task.importance == 'low')
                      TextSpan(
                        text: '↓ ',
                        style: textStyle.bodyMedium?.copyWith(
                          fontSize: 22,
                          color: colors.onSurface,
                        ),
                      ),
                    TextSpan(
                      text: task.text,
                      style: textStyle.bodyMedium?.copyWith(
                        decoration: task.done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (task.deadline != null)
                Text(
                  DateFormat('dd-MM-yyyy').format(task.deadline!),
                  style: textStyle.bodySmall?.copyWith(fontSize: 13),
                ),
            ],
          ),
          leading: Checkbox(
            value: task.done,
            onChanged: (bool? value) {
              if (value != null) {
                final updatedTask = task.copyWith(done: value);
                ref.read(tasksProvider.notifier).updateTask(updatedTask);
              }
            },
            activeColor: Colors.green,
            checkColor: colors.surface,
          ),
          trailing: IconButton(
            onPressed: () async {
              TaskLogger().logDebug('Нажата кнопка для редактирования задачи');

              final result = await context.push<Task>(
                '/addtask',
                extra: task,
              );
              if (result != null) {

                TaskLogger().logDebug(
                    'Результат будет получен на экране редактирования задачи');
                ref.read(tasksProvider.notifier).updateTask(result);
              }
            },
            icon: Icon(
              Icons.info_outline,
              color: colors.onError,
            ),
          ),
        ),
      ),
    );
  }
}
