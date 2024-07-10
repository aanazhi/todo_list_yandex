import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_yandex/features/tasks/data/device/device_id.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/tasks_provider.dart';
import 'package:todo_list_yandex/features/tasks/presentation/widgets/task_name_input.dart';
import 'package:todo_list_yandex/logger/logger.dart';
import 'package:todo_list_yandex/utils/utils.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  AddEditTaskScreenState createState() => AddEditTaskScreenState();
}

class AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  late TextEditingController taskNameController;

  @override
  void initState() {
    super.initState();
    logger.d('Initializing state');
    final task = widget.task;

    boxFuture = Hive.openBox<Task>('taskBox');

    if (task != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(taskNameProvider.notifier).state = task.text;
        ref.read(importanceProvider.notifier).state = task.importance;
        ref.read(dueDateProvider.notifier).state = task.deadline;
        ref.read(isDueDateEnabledProvider.notifier).state =
            task.deadline != null;
      });
      taskNameController = TextEditingController(text: task.text);
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
    final deadline = ref.watch(dueDateProvider);
    final isDueDateEnabled = ref.watch(isDueDateEnabledProvider);

    return Scaffold(
      backgroundColor: colors.onPrimary,
      appBar: AppBar(
        backgroundColor: colors.onPrimary,
        leading: IconButton(
          color: colors.onSecondary,
          icon: const Icon(Icons.close),
          onPressed: () {
            context.go('/');
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              logger.d('Нажата кнопка - добавление или обновление задачи');

              final deviceId = await getDeviceId();
              const uuid = Uuid();

              final newTask = Task(
                id: widget.task?.id ?? uuid.v4(),
                text: taskNameController.text,
                done: widget.task?.done ?? false,
                deadline: deadline,
                importance: importance,
                createdAt: widget.task?.createdAt ?? DateTime.now(),
                changedAt: DateTime.now(),
                lastUpdatedBy: deviceId,
              );

              final box = await boxFuture;
              await box.put(newTask.id, newTask);
              logger.d('Значения бокса ${box.values.toList()}');

              if (widget.task != null) {
                ref.read(tasksProvider.notifier).updateTask(newTask);
              } else {
                ref.read(tasksProvider.notifier).addTask(newTask);
              }

              context.go('/');
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
                TaskNameInput(controller: taskNameController),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    value: importance.isNotEmpty ? importance : null,
                    decoration: InputDecoration(
                      labelText: 'Важность',
                      labelStyle: textStyle.bodyMedium,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      {'display': 'Нет', 'value': 'basic'},
                      {'display': 'Низкий', 'value': 'low'},
                      {'display': '!! Высокий', 'value': 'important'}
                    ].map((importanceItem) {
                      return DropdownMenuItem<String>(
                        value: importanceItem['value'],
                        child: Text(
                          importanceItem['display']!,
                          style: importanceItem['value'] == 'important'
                              ? textStyle.bodyMedium
                                  ?.copyWith(color: colors.error)
                              : textStyle.bodyMedium
                                  ?.copyWith(color: colors.onSurface),
                        ),
                      );
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Сделать до',
                        style: textStyle.bodyMedium,
                      ),
                      value: isDueDateEnabled,
                      activeColor: colors.primary,
                      onChanged: (bool value) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref.read(isDueDateEnabledProvider.notifier).state =
                              value;
                          if (!value) {
                            ref.read(dueDateProvider.notifier).state = null;
                          }
                        });
                      },
                    ),
                    if (isDueDateEnabled)
                      ListTile(
                        title: Text(
                          deadline == null
                              ? 'Выберите дату'
                              : DateFormat('dd MMMM').format(deadline),
                          style: textStyle.bodyMedium?.copyWith(),
                        ),
                        trailing: Icon(
                          Icons.calendar_today,
                          color: colors.onSecondary,
                        ),
                        onTap: () async {
                          logger.d('Выбор даты нажат');
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 1)),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            ref.read(dueDateProvider.notifier).state =
                                pickedDate;
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        logger.d('Нажата кнопка - удаление задачи');
                        ref
                            .read(tasksProvider.notifier)
                            .deleteTask(widget.task!);

                        final box = await boxFuture;
                        await box.delete(widget.task!.id);

                        logger.d('Значение бокса удалено ${box.values.toList()}');

                        Navigator.pop(context);
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
