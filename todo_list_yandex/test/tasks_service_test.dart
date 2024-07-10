import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/services/hive_service.dart';
import 'package:todo_list_yandex/features/tasks/data/services/tasks_sevice.dart';

import 'tasks_service_test.mocks.dart';

@GenerateMocks([Dio, HiveService, Connectivity])
void main() {
  late MockDio mockDio;
  late MockHiveService mockHiveService;
  late MockConnectivity mockConnectivity;
  late TasksService tasksService;

  setUp(() {
    mockDio = MockDio();
    mockHiveService = MockHiveService();
    mockConnectivity = MockConnectivity();
    when(mockDio.options).thenReturn(BaseOptions());

    when(mockDio.interceptors).thenReturn(Interceptors());
    tasksService = TasksService(
      dio: mockDio,
      hiveService: mockHiveService,
      connectivity: mockConnectivity,
    );

    when(mockHiveService.getAllTasks()).thenAnswer((_) async => <Task>[]);

    when(mockDio.get(
      any,
      queryParameters: anyNamed('queryParameters'),
      options: anyNamed('options'),
      cancelToken: anyNamed('cancelToken'),
      onReceiveProgress: anyNamed('onReceiveProgress'),
    )).thenAnswer((_) async => Response(
          data: {'list': []},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/list'),
        ));
  });

  group('TasksService', () {
    test('should check connectivity', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      final isConnected = await tasksService.isConnected();

      expect(isConnected, true);
      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    test('should return tasks from server when connected', () async {
      final mockResponse = Response(
        data: {
          'list': [
            {
              'id': '1',
              'text': 'Task 1',
              'importance': 'low',
              'deadline': null,
              'done': false,
              'createdAt': DateTime.now(),
              'changedAt': DateTime.now(),
              'lastUpdatedBy': 'user1',
            },
            {
              'id': '2',
              'text': 'Task 2',
              'importance': 'high',
              'done': true,
              'createdAt': DateTime.now(),
              'changedAt': DateTime.now(),
              'lastUpdatedBy': 'user2',
            },
          ],
          'revision': 1,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/list'),
      );

      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);
      when(mockDio.get('/list')).thenAnswer((_) async => mockResponse);
      when(mockHiveService.clearBox()).thenAnswer((_) async {});
      when(mockHiveService.saveTask(any)).thenAnswer((_) async {});

      final tasks = await tasksService.getAllTasks();

      expect(tasks.length, 2);
      expect(tasks[0].text, 'Task 1');
      expect(tasks[1].text, 'Task 2');
      verify(mockHiveService.clearBox()).called(1);
      verify(mockHiveService.saveTask(any)).called(2);
    });

    test('should add task when connected and server returns success', () async {
      final task = Task(
        id: '1',
        text: 'New Task',
        createdAt: DateTime.now(),
        changedAt: DateTime.now(),
        lastUpdatedBy: 'user1',
      );

      final mockResponse = Response(
        data: {'revision': 2},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/list'),
      );

      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);
      when(mockDio.post(
        '/list',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => mockResponse);
      when(mockHiveService.saveTask(task)).thenAnswer((_) async {});

      await tasksService.addTask(task);

      verify(mockDio.post(
        '/list',
        data: {'element': task.toJson()},
        options: anyNamed('options'),
      )).called(1);
    });

    test('should handle DioException', () async {
      final now = DateTime.now();
      final task = Task(
        id: '1',
        text: 'New Task',
        importance: 'low',
        deadline: null,
        done: false,
        createdAt: now,
        changedAt: now,
        lastUpdatedBy: 'user1',
      );

      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);
      when(mockDio.post(
        '/list',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenThrow(DioException(requestOptions: RequestOptions(path: '/list')));

      await tasksService.addTask(task);

      verify(mockDio.post(
        '/list',
        data: {'element': task.toJson()},
        options: anyNamed('options'),
      )).called(1);
    });

    test('should handle SocketException', () async {
      final now = DateTime.now();
      final task = Task(
        id: '1',
        text: 'New Task',
        importance: 'low',
        deadline: null,
        done: false,
        createdAt: now,
        changedAt: now,
        lastUpdatedBy: 'user1',
      );

      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);
      when(mockDio.post(
        '/list',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenThrow(const SocketException('No Internet'));

      await tasksService.addTask(task);

      verify(mockDio.post(
        '/list',
        data: {'element': task.toJson()},
        options: anyNamed('options'),
      )).called(1);
    });

    test('should throw ArgumentError when taskId is empty', () async {
      expect(() => tasksService.deleteTask(''), throwsArgumentError);
    });

    test('should delete task successfully with internet connection', () async {
      const taskId = '4';
      final mockDeleteResponse = Response(
        data: {
          'revision': 2,
          'status': 'ok',
          'element': {
            'id': taskId,
            'done': true,
            'text': 'text',
            'created_at': 1720554892,
            'last_updated_by': 'aana',
            'changed_at': 1720554892,
            'importance': 'basic'
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/list/$taskId'),
      );

      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      // Мокаем запрос на удаление задачи
      when(mockDio.delete(
        '/list/$taskId',
        options: anyNamed('options'),
      )).thenAnswer((_) async => mockDeleteResponse);

      when(mockHiveService.deleteTask(taskId)).thenAnswer((_) async => {});

      final result = await tasksService.deleteTask(taskId);

      expect(result.id, taskId);
      verify(mockHiveService.deleteTask(taskId)).called(1);
    });

    test('should throw exception when server returns error', () async {
      const taskId = '1';
      final mockResponse = Response(
        data: 'Error',
        statusCode: 500,
        requestOptions: RequestOptions(path: '/list/$taskId'),
      );

      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);
      when(mockDio.delete(
        '/list/$taskId',
        options: anyNamed('options'),
      )).thenAnswer((_) async => mockResponse);

      expect(() => tasksService.deleteTask(taskId), throwsException);
    });
  });

  group('editTask', () {
    final now = DateTime.now();
    final task = Task(
      id: '1',
      text: 'New Task',
      importance: 'low',
      deadline: null,
      done: false,
      createdAt: now,
      changedAt: now,
      lastUpdatedBy: 'user1',
    );

    test('should edit task successfully with internet connection', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);
      when(mockDio.put(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: {
              'id': task.id,
              'revision': 2
            }, // Здесь мы специально указываем null для проверки
            statusCode: 200,
            requestOptions: RequestOptions(path: '/list/${task.id}'),
          ));
      when(mockHiveService.saveTask(any)).thenAnswer((_) async => {});

      final result = await tasksService.editTask(task);

      expect(result.id, task.id);
      verify(mockHiveService.saveTask(task)).called(1);
    });

    test('should throw exception on unknown error', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);
      when(mockDio.put(
        any,
        data: anyNamed('data'),
      )).thenThrow(Exception('Unknown error'));

      expect(() => tasksService.editTask(task), throwsException);
    });
  });
}
