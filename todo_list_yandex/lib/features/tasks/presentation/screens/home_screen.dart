import 'package:flutter/material.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/remote_configs_provider.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/tasks_provider.dart';
import 'package:todo_list_yandex/features/tasks/presentation/widgets/add_task_button_plus.dart';
import 'package:todo_list_yandex/features/tasks/presentation/widgets/my_sliver_app_bar.dart';
import 'package:todo_list_yandex/features/tasks/presentation/widgets/tasks.dart';
import 'package:todo_list_yandex/generated/l10n.dart';
import 'package:todo_list_yandex/logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    final deviceSize = MediaQuery.of(context).size;
    final isVisible = ref.watch(taskVisibilityProvider);
    final tasksAsyncValue = ref.watch(tasksProvider);
    final importanceColor = ref.watch(colorStateProvider);

    return Scaffold(
      backgroundColor: colors.onPrimary,
      body: tasksAsyncValue.when(
        data: (tasks) => CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: MySliverAppBar(
                minHeight: deviceSize.height * 0.15,
                maxHeight: deviceSize.height * 0.25,
                child: Container(
                  color: colors.surface,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          S.of(context).my_tasks,
                          style: textStyle.displayLarge,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Text(
                                '${S.of(context).completed} - ${tasks.where((task) => task.done).length}',
                                style: textStyle.bodySmall,
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 40),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      TaskLogger().logDebug(
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
                                  IconButton(
                                    onPressed: () => ref
                                        .read(colorStateProvider.notifier)
                                        .toggleColor(),
                                    icon: Icon(
                                      Icons.color_lens,
                                      color: importanceColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Tasks(),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
            child: Text('Ошибка загрузки задач', style: textStyle.bodySmall)),
      ),
      floatingActionButton: AddTaskButtonPlus(colors: colors),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
