import 'package:flutter/material.dart';
import 'package:todo_list_yandex/features/tasks/presentation/screens/add_edit_task_screen.dart';
import 'package:todo_list_yandex/logger/logger.dart';
import 'package:todo_list_yandex/utils/utils.dart';

class AddTaskButtonNew extends StatelessWidget {
  const AddTaskButtonNew({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textTheme;
    return Padding(
      padding: const EdgeInsets.only(right: 250.0),
      child: TextButton(
        onPressed: () {
          logger.d('Нажата кнопка - переход к экрану добавления и редактирования задачи');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
        },
        child: Text(
          'Новое',
          style: textStyle.bodySmall,
        ),
      ),
    );
  }
}
