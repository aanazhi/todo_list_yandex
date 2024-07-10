import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/providers/tasks_provider.dart';
import 'package:todo_list_yandex/features/tasks/data/services/hive_service.dart';
import 'package:todo_list_yandex/logger/logger.dart';

import 'hive_service_test.mocks.dart';

class MockPathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.';
  }
}

@GenerateMocks([TaskLogger],
    customMocks: [MockSpec<TaskLogger>(as: #MockTaskLoggerForTest)])
void main() {
  late ProviderContainer container;
  late MockTaskLoggerForTest mockTaskLogger;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    PathProviderPlatform.instance = MockPathProviderPlatform();

    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());

    mockTaskLogger = MockTaskLoggerForTest();

    container = ProviderContainer(
      overrides: [
        taskLoggerProvider.overrideWithValue(mockTaskLogger),
      ],
    );
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    container.dispose();
  });

  tearDown(() async {
    await Hive.close();
  });

  test('should save task', () async {
    final hiveService = HiveService(mockTaskLogger, boxNameOverride: 'testBox');
    await hiveService.openBox();

    final task = Task(
        id: '987',
        text: 'text',
        createdAt: DateTime.now(),
        changedAt: DateTime.now(),
        lastUpdatedBy: 'anaz');

    await hiveService.saveTask(task);

    final box = await Hive.openBox<Task>('testBox');
    expect(box.get(task.id), equals(task));

    verify(mockTaskLogger.logDebug('Task saved in box : ${task.id}')).called(1);

    await hiveService.closeBox();
  });

  test('should delete task', () async {
    final hiveService = HiveService(mockTaskLogger, boxNameOverride: 'testBox');
    await hiveService.openBox();

    final task = Task(
        id: '987',
        text: 'text',
        createdAt: DateTime.now(),
        changedAt: DateTime.now(),
        lastUpdatedBy: 'anaz');

    await hiveService.saveTask(task);
    await hiveService.deleteTask(task.id);

    final box = await Hive.openBox<Task>('testBox');
    expect(box.get(task.id), isNull);

    verify(mockTaskLogger.logDebug('Task delete in box : ${task.id}'))
        .called(1);

    await hiveService.closeBox();
  });

  test('should get all tasks', () async {
    final hiveService = HiveService(mockTaskLogger, boxNameOverride: 'testBox');
    await hiveService.openBox();

    final task1 = Task(
        id: '987',
        text: 'text1',
        createdAt: DateTime.now(),
        changedAt: DateTime.now(),
        lastUpdatedBy: 'anaz');

    final task2 = Task(
        id: '988',
        text: 'text2',
        createdAt: DateTime.now(),
        changedAt: DateTime.now(),
        lastUpdatedBy: 'anaz');

    await hiveService.saveTask(task1);
    await hiveService.saveTask(task2);

    final tasks = await hiveService.getAllTasks();

    expect(tasks.length, equals(2));
    expect(tasks.contains(task1), isTrue);
    expect(tasks.contains(task2), isTrue);

    const expectedLogMessage = 'All tasks from box';
    verify(mockTaskLogger.logDebug(expectedLogMessage)).called(1);

    await hiveService.closeBox();
  });

  test('should clear box', () async {
    final hiveService = HiveService(mockTaskLogger, boxNameOverride: 'testBox');
    await hiveService.openBox();

    final task = Task(
        id: '987',
        text: 'text',
        createdAt: DateTime.now(),
        changedAt: DateTime.now(),
        lastUpdatedBy: 'anaz');

    await hiveService.saveTask(task);
    await hiveService.clearBox();

    final box = await Hive.openBox<Task>('testBox');
    expect(box.isEmpty, isTrue);

    await hiveService.closeBox();
  });
}
