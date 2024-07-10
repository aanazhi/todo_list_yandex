import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/tasks_provider.dart';
import 'package:todo_list_yandex/features/tasks/presentation/widgets/add_task_button_new.dart';
import 'package:todo_list_yandex/features/tasks/presentation/widgets/tasks_card.dart';
import 'package:todo_list_yandex/logger/logger.dart';
import 'package:todo_list_yandex/utils/utils.dart';

class Tasks extends ConsumerStatefulWidget {
  const Tasks({super.key});

  @override
  TasksState createState() => TasksState();
}

class TasksState extends ConsumerState<Tasks> {
  late Future<Box<Task>> boxFuture;

  @override
  void initState() {
    super.initState();
    boxFuture = Hive.openBox<Task>('taskBox');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    final isVisible = ref.watch(taskVisibilityProvider);
    final tasks = ref.watch(tasksProvider);

    final filteredTasks =
        isVisible ? tasks : tasks.where((task) => !task.done).toList();

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
                      color: task.done ? colors.onSecondary : colors.secondary,
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
                onDismissed: (direction) async {
                  logger.d('Направление свайпа: $direction');
                  if (direction == DismissDirection.startToEnd) {
                    final updatedTask = task.copyWith(done: true);
                    await ref
                        .read(tasksProvider.notifier)
                        .updateTask(updatedTask);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: colors.secondary,
                          content: Text(
                            '${task.text} выполнена',
                            style: TextStyle(color: colors.surface),
                          )),
                    );
                  } else if (direction == DismissDirection.endToStart) {
                    ref.read(tasksProvider.notifier).deleteTask(task);
                    final box = await boxFuture;
                    await box.delete(task.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: colors.error,
                          content: Text(
                            '${task.text} удалена',
                            style: TextStyle(color: colors.surface),
                          )),
                    );
                    logger.d('Задача ${task.text} удалена');
                  }
                },
                confirmDismiss: (direction) async {
                  logger.d('Направление свайпа: $direction');
                  if (direction == DismissDirection.startToEnd) {
                    return !task.done;
                  } else if (direction == DismissDirection.endToStart) {
                    return true;
                  }
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
