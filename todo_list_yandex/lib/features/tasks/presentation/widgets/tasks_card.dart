import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/tasks_provider.dart';
import 'package:todo_list_yandex/features/tasks/presentation/screens/add_edit_task_screen.dart';
import 'package:todo_list_yandex/logger/logger.dart';
import 'package:todo_list_yandex/utils/utils.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colorScheme;
    final textStyle = context.textTheme;

    return Card(
      child: ListTile(
        tileColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.importance == '!! Высокий'
                  ? '!! ${task.title}'
                  : task.importance == 'Низкий'
                      ? '↓ ${task.title}'
                      : task.title,
              style: textStyle.bodyMedium?.copyWith(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: colors.onSurface,
              ),
            ),
            if (task.dueDate != null)
              Text(
                DateFormat('dd-MM-yyyy').format(task.dueDate!),
                style: TextStyle(
                  color: colors.onBackground.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        leading: Icon(
          task.isCompleted ? Icons.check_box : Icons.crop_square_outlined,
          color: task.importance == '!! Высокий' && !task.isCompleted
              ? colors.error
              : colors.onBackground,
        ),
        trailing: IconButton(
          onPressed: () async {
            logger.d('The button for editing the task has been pressed');
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditTaskScreen(task: task),
              ),
            );
            if (result != null && result is Task) {
              logger.d('The result is received from the task editing screen');
              ref.read(tasksProvider.notifier).updateTask(result);
            }
          },
          icon: Icon(
            Icons.info_outline,
            color: colors.onBackground,
          ),
        ),
      ),
    );
  }
}
