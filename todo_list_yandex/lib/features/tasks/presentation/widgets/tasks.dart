import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/tasks_provider.dart';
import 'package:todo_list_yandex/features/tasks/presentation/widgets/add_task_button_new.dart';
import 'package:todo_list_yandex/features/tasks/presentation/widgets/tasks_card.dart';
import 'package:todo_list_yandex/logger/logger.dart';
import 'package:todo_list_yandex/utils/utils.dart';

class Tasks extends ConsumerWidget {
  const Tasks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colorScheme;

    final isVisible = ref.watch(taskVisibilityProvider);
    final tasks = ref.watch(tasksProvider);

    final filteredTasks =
        isVisible ? tasks : tasks.where((task) => !task.isCompleted).toList();

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return Dismissible(
                key: Key(task.id),
                background: Stack(
                  children: [
                    Container(
                      color: task.isCompleted
                          ? colors.onSecondary
                          : colors.secondary,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Icon(
                          Icons.check,
                          color: colors.onError,
                        ),
                      ),
                    ),
                  ],
                ),
                secondaryBackground: Stack(
                  children: [
                    Container(
                      color: colors.error,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Icon(
                          Icons.delete,
                          color: colors.surface,
                        ),
                      ),
                    ),
                  ],
                ),
                onDismissed: (direction) {
                  logger.d('Swipe direction: $direction');
                  if (direction == DismissDirection.startToEnd) {
                    ref
                        .read(tasksProvider.notifier)
                        .toggleTaskCompletion(task.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: colors.secondary,
                          content: Text(
                            '${task.title} выполнена',
                            style: TextStyle(color: colors.surface),
                          )),
                    );
                  } else if (direction == DismissDirection.endToStart) {
                    ref.read(tasksProvider.notifier).removeTask(task);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: colors.error,
                          content: Text(
                            '${task.title} удалена',
                            style: TextStyle(color: colors.surface),
                          )),
                    );
                    logger.d('The task ${task.title} delete');
                  }
                },
                confirmDismiss: (direction) async {
                  logger.d('Swipe direction: $direction');
                  if (direction == DismissDirection.startToEnd) {
                    if (task.isCompleted) {
                      logger.d(
                          'The result of the swipe confirmation: ${task.isCompleted}');
                      return false;
                    }
                    return true;
                  } else if (direction == DismissDirection.endToStart) {
                    logger.d(
                        'The result of the swipe confirmation: ${task.isCompleted}');
                    return true;
                  }
                  logger.d(
                      'The result of the swipe confirmation: ${task.isCompleted}');
                  return false;
                },
                child: TaskCard(
                  task: task,
                ),
              );
            },
          ),
        ),
        const AddTaskButtonNew(),
      ],
    );
  }
}
