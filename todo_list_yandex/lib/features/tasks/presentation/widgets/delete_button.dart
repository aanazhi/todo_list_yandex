import 'package:flutter/material.dart';
import 'package:todo_list_yandex/utils/utils.dart';

class DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DeleteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final textStyle = context.textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: onPressed,
          icon: Icon(
            Icons.delete,
            color: colors.error,
          ),
          label: Text(
            'Удалить',
            style: textStyle.bodySmall?.copyWith(color: colors.error),
          ),
        ),
      ],
    );
  }
}
