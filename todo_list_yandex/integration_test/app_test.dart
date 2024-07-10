import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/main.dart';

import '../test/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setUpTestHive();
  });

  tearDown(() async {
    await Hive.box<Task>('tasksBox').clear();
  });

  testWidgets('Добавление новой задачи', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(child: TodoApp()));

    await tester.pumpAndSettle();

    final addButton = find.byIcon(Icons.add);
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);

    await tester.pumpAndSettle();

    final taskField = find.byType(TextFormField);
    expect(taskField, findsOneWidget);
    await tester.enterText(taskField, 'Новая задача');

    await tester.pumpAndSettle();

    final importanceDropdown = find.byType(DropdownButtonFormField<String>);
    expect(importanceDropdown, findsOneWidget);
    await tester.tap(importanceDropdown);

    await tester.pumpAndSettle();

    final importantOption = find.text('!! Высокий');
    expect(importantOption, findsOneWidget);

    await tester.tap(importantOption);

    await tester.pumpAndSettle();

    final saveButton = find.text('СОХРАНИТЬ');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);

    await tester.pumpAndSettle();
  });
}
