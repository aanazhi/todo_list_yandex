import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/tasks_provider.dart';
import 'package:todo_list_yandex/logger/logger.dart';
import 'package:todo_list_yandex/utils/utils.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task;

  const AddEditTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  late TextEditingController taskNameController;

  @override
  void initState() {
    super.initState();
    logger.d('Initializing state');
    final task = widget.task;

    if (task != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(taskNameProvider.notifier).state = task.title;
        ref.read(importanceProvider.notifier).state = task.importance!;
        ref.read(dueDateProvider.notifier).state = task.dueDate;
        ref.read(isDueDateEnabledProvider.notifier).state =
            task.dueDate != null;
      });
      taskNameController = TextEditingController(text: task.title);
    } else {
      taskNameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    logger.d('Disposing state');
    taskNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final textStyle = context.textTheme;

    final importance = ref.watch(importanceProvider);
    final dueDate = ref.watch(dueDateProvider);
    final isDueDateEnabled = ref.watch(isDueDateEnabledProvider);

    void _removeTask() async {
      await Future.delayed(Duration.zero);
      ref.read(tasksProvider.notifier).removeTask(widget.task!);
      Navigator.pop(context);
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              logger.d('Button pressed - Adding or updating task');
              final newTask = Task(
                id: widget.task?.id ?? DateTime.now().toString(),
                title: taskNameController.text,
                isCompleted: widget.task?.isCompleted ?? false,
                dueDate: dueDate,
                importance: importance,
              );

              if (widget.task != null) {
                ref.read(tasksProvider.notifier).updateTask(newTask);
              } else {
                ref.read(tasksProvider.notifier).addTask(newTask);
              }
              Navigator.pop(context);
            },
            child: const Text('СОХРАНИТЬ'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: taskNameController,
                  decoration: InputDecoration(
                    labelText: 'Что нужно сделать...',
                    labelStyle: textStyle.bodyMedium,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    logger.d('Text changed: $value');
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(taskNameProvider.notifier).state = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                Container(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    value: importance,
                    decoration: InputDecoration(
                      labelText: 'Важность',
                      labelStyle: textStyle.bodyMedium,
                      border: const OutlineInputBorder(),
                    ),
                    items: ['Нет', 'Низкий', '!! Высокий'].map((importance) {
                      return DropdownMenuItem<String>(
                          value: importance,
                          child: Text(
                            importance,
                            style: importance == '!! Высокий'
                                ? textStyle.bodyMedium
                                    ?.copyWith(color: colors.error)
                                : textStyle.bodyMedium
                                    ?.copyWith(color: colors.onSurface),
                          ));
                    }).toList(),
                    onChanged: (value) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref.read(importanceProvider.notifier).state = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: Text(
                    'Сделать до',
                    style: textStyle.bodyMedium,
                  ),
                  value: isDueDateEnabled,
                  onChanged: (bool value) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(isDueDateEnabledProvider.notifier).state = value;
                      if (!value) {
                        ref.read(dueDateProvider.notifier).state = null;
                      }
                    });
                  },
                ),
                if (isDueDateEnabled) ...[
                  ListTile(
                    title: Text(
                      dueDate == null
                          ? 'Выберите дату'
                          : DateFormat('dd MMMM').format(dueDate),
                      style: textStyle.bodyMedium?.copyWith(),
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: colors.onSecondary,
                    ),
                    onTap: () async {
                      logger.d('Date picker tapped');
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        ref.read(dueDateProvider.notifier).state = pickedDate;
                      }
                    },
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        logger.d('Button pressed - Removing task');
                        _removeTask();
                      },
                      icon: Icon(
                        Icons.delete,
                        color: colors.error,
                      ),
                      label: Text('Удалить',
                          style: textStyle.bodyMedium?.copyWith(
                            color: colors.error,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
