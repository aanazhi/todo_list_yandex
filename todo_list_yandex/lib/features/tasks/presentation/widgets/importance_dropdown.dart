import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/tasks_provider.dart';
import 'package:todo_list_yandex/logger/logger.dart';
import 'package:todo_list_yandex/utils/utils.dart';

class ImportanceDropdown extends ConsumerWidget {
  final String importance;

  const ImportanceDropdown({super.key, required this.importance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colorScheme;
    final textStyle = context.textTheme;
    return Container(
        width: 200,
        child: DropdownButtonFormField<String>(
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
                      ? textStyle.bodyMedium?.copyWith(color: colors.error)
                      : textStyle.bodyMedium?.copyWith(color: colors.onSurface),
                ));
          }).toList(),
          onChanged: (value) {
            TaskLogger().logDebug('The value has been changed to: $value');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              TaskLogger().logDebug('Setting the value to the provider');
              ref.read(importanceProvider.notifier).state = value!;
            });
          },
          style: textStyle.bodyMedium,
        ));
  }
}
