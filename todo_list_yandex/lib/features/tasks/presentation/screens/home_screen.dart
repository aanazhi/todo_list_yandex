import 'package:flutter/material.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/tasks_provider.dart';
import 'package:todo_list_yandex/features/tasks/presentation/widgets/add_task_button_plus.dart';
import 'package:todo_list_yandex/features/tasks/presentation/widgets/tasks.dart';
import 'package:todo_list_yandex/logger/logger.dart';
import 'package:todo_list_yandex/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colorScheme;
    final textStyle = context.textTheme;

    final deviceSize = context.deviceSize;
    final isVisible = ref.watch(taskVisibilityProvider);
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: colors.onPrimary,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: deviceSize.width,
                height: deviceSize.height * 0.25,
                color: colors.surface,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Мои дела',
                        style: textStyle.displayLarge,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Text(
                              'Выполнено - ${tasks.where((task) => task.done).length}',
                              style: textStyle.bodySmall,
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: IconButton(
                              onPressed: () {
                                logger.d(
                                    'Нажата кнопка - переключение видимости задачи');
                                ref
                                    .read(taskVisibilityProvider.notifier)
                                    .state = !isVisible;
                              },
                              icon: Icon(
                                isVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Tasks(),
            ),
          ),
        ],
      ),
      floatingActionButton: AddTaskButtonPlus(
        colors: colors,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
