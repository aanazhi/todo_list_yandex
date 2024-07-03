import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/tasks_provider.dart';
import 'package:todo_list_yandex/generated/l10n.dart';
import 'package:todo_list_yandex/utils/extensions.dart';

class TaskNameInput extends ConsumerWidget {
  final TextEditingController controller;

  const TaskNameInput({required this.controller, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colorScheme;
    final textStyle = context.textTheme;

    return Container(
      color: colors.onPrimary,
      child: TextFormField(
        controller: controller,
        maxLines: null,
        decoration: InputDecoration(
          labelText: S.of(context).wINTD,
          labelStyle: textStyle.bodyMedium,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: colors.onPrimary,
        ),
        onChanged: (value) {
          ref.read(taskNameProvider.notifier).state = value;
        },
      ),
    );
  }
}
