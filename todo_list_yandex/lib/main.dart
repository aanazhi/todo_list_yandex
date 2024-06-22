import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_yandex/config/theme/app_theme.dart';
import 'package:todo_list_yandex/features/tasks/presentation/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: TodoApp()));
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
