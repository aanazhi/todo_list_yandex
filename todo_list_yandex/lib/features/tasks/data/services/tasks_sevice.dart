import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:dio/dio.dart';
import 'package:todo_list_yandex/features/tasks/data/services/hive_service.dart';
import 'package:todo_list_yandex/logger/logger.dart';

class TasksService {
  final Dio dio;
  final HiveService hiveService;
  final Connectivity connectivity;

  int revision = 0;

  TasksService({
    required this.dio,
    required this.hiveService,
    required this.connectivity,
  }) {
    dio.options.baseUrl = 'https://hive.mrdekk.ru/todo/';
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['Authorization'] = 'Bearer Ailinel';
      options.headers['X-Last-Known-Revision'] = revision.toString();
      return handler.next(options);
    }));

    // (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    //   final client = HttpClient();
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true;
    //   return client;
    // };
  }

  Future<bool> isConnected() async {
    final connectivityResults = await connectivity.checkConnectivity();

    return connectivityResults
        .any((result) => result != ConnectivityResult.none);
  }

  Future<List<Task>> getTasksFromLocalStorage() async {
    return await hiveService.getAllTasks();
  }

  Future<void> addTaskToLocalStorage(Task task) async {
    await hiveService.saveTask(task);
  }

  Future<void> deleteTaskFromLocalStorage(String taskId) async {
    await hiveService.deleteTask(taskId);
  }

  Future<void> updateTaskInLocalStorage(Task task) async {
    await hiveService.saveTask(task);
  }

  Future<void> updateTasksInLocalStorage(List<Task> tasks) async {
    for (var task in tasks) {
      await hiveService.saveTask(task);
    }
  }

  Future<List<Task>> getAllTasks() async {
    if (await isConnected()) {
      try {
        final Response response = await dio.get('/list');

        if (response.statusCode == 200) {
          final data = response.data;
          TaskLogger().logDebug('Ответ от сервера: $data');

          if (data is Map<String, dynamic> && data['list'] is List<dynamic>) {
            final List<dynamic> list = data['list'];
            revision = response.data['revision'];
            TaskLogger().logDebug('Обновленная ревизия: $revision');
            final tasks = list
                .map((item) => Task.fromJson(item as Map<String, dynamic>))
                .toList();
            await hiveService.clearBox();
            for (var task in tasks) {
              await hiveService.saveTask(task);
            }
            return tasks;
          } else {
            throw Exception('Некорректный формат данных');
          }
        } else {
          throw Exception('Ошибка при получении задач: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Ошибка при выполнении запроса: $e');
      }
    } else {
      return await getTasksFromLocalStorage();
    }
  }

  Future<void> addTask(Task task) async {
    if (await isConnected()) {
      try {
        final requestData = {'element': task.toJson()};
        TaskLogger().logDebug(
            'Запрос на добавление задачи: ${jsonEncode(requestData)}');

        final response = await dio.post(
          '/list',
          data: requestData,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        TaskLogger().logDebug('Запрос $response');
        TaskLogger().logDebug('Ответ сервера: ${response.data}');

        if (response.statusCode == 200) {
          revision = response.data['revision'];
          TaskLogger().logDebug('Обновленная ревизия: $revision');
          final List<Task> currentTasks = await getAllTasks();
          currentTasks.add(task);

          await updateTasks(currentTasks);
          await hiveService.saveTask(task);
        } else {
          throw Exception(
              'Ошибка при добавлении задачи: ${response.statusCode}');
        }
      } on DioException catch (dioError, stackTrace) {
        TaskLogger()
            .logError('DioError при добавлении задачи: $dioError', stackTrace);
      } on SocketException catch (socketError, stackTrace) {
        TaskLogger().logError(
            'SocketException при добавлении задачи: $socketError', stackTrace);
      } catch (e, stackTrace) {
        TaskLogger().logError(
            'Неизвестная ошибка при добавлении задачи: $e', stackTrace);
      }
    } else {
      TaskLogger()
          .logDebug('Нет подключения к интернету, сохраняем задачу локально.');
      await hiveService.saveTask(task);
    }
  }

  Future<Task> deleteTask(String taskId) async {
    if (taskId.isEmpty) {
      throw ArgumentError('Идентификатор задачи не может быть пустым');
    }

    if (await isConnected()) {
      try {
        final taskID = taskId.replaceAll(RegExp(r'[\\[\\]#]'), '');
        final response = await dio.delete(
          '/list/$taskID',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

        TaskLogger()
            .logDebug('Ответ сервера на удаление задачи: ${response.data}');

        if (response.statusCode == 200) {
          if (response.data['revision'] != null &&
              response.data['revision'] is int) {
            revision = response.data['revision'] as int;
          } else {
            revision = 1;
          }
          TaskLogger()
              .logDebug('Обновленная ревизия после удаления задачи: $revision');
          final List<Task> currentTasks = await getAllTasks();
          currentTasks.removeWhere((task) => task.id == taskId);

          await updateTasks(currentTasks);

          // Удаление задачи из локального хранилища
          await hiveService.deleteTask(taskId);

          return Task.fromJson(response.data);
        } else {
          throw Exception('Ошибка при удалении задачи: ${response.statusCode}');
        }
      } catch (e, stackTrace) {
        TaskLogger().logError('Ошибка при удалении задачи: $e', stackTrace);
        throw Exception('Ошибка при удалении задачи: $e');
      }
    } else {
      await hiveService.deleteTask(taskId);
      return Task(
        id: taskId,
        text: '',
        importance: '',
        deadline: null,
        done: false,
        createdAt: DateTime.now(),
        changedAt: DateTime.now(),
        lastUpdatedBy: '',
      );
    }
  }

  Future<Task> editTask(Task task) async {
    if (await isConnected()) {
      try {
        final requestData = {
          'element': task.toJson(),
        };

        final taskID = task.id.replaceAll(RegExp(r'[\\[\\]#]'), '');

        TaskLogger().logDebug(
            'Запрос на редактирование задачи: ${jsonEncode(requestData)}');

        final response = await dio.put(
          '/list/$taskID',
          data: requestData,
        );

        TaskLogger().logDebug('Ответ сервера: ${response.data}');

        if (response.statusCode == 200) {
          final revisionData = response.data['revision'];
          if (revisionData != null && revisionData is int) {
            revision = revisionData;
          } else {
            revision = 2;
          }
          TaskLogger().logDebug('Обновленная ревизия: $revision');
          final List<Task> currentTasks = await getAllTasks();

          final int index = currentTasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            currentTasks[index] = task;
          }

          await updateTasks(currentTasks);

          // Сохранение обновленной задачи в локальное хранилище
          await hiveService.saveTask(task);

          return Task.fromJson(response.data);
        } else {
          throw Exception(
              'Ошибка при редактировании задачи: ${response.statusCode}');
        }
      } on DioException catch (e, stackTrace) {
        TaskLogger().logError(
            'Ошибка при редактировании задачи (DioException): $e', stackTrace);
        if (e.response != null) {
          TaskLogger()
              .logError('Response data: ${e.response?.data}', stackTrace);
          TaskLogger()
              .logError('Response headers: ${e.response?.headers}', stackTrace);
          TaskLogger().logError(
              'Response status code: ${e.response?.statusCode}', stackTrace);

          if (e.response?.statusCode == 400 &&
              e.response?.data == 'unsynchronized data') {
            await getAllTasks();
            await editTask(task);
          }
        }
        throw Exception('Ошибка при редактировании задачи (DioException): $e');
      } catch (e) {
        throw Exception('Неизвестная ошибка: $e');
      }
    } else {
      await hiveService.saveTask(task);
      return task;
    }
  }

  Future<List<Task>> updateTasks(List<Task> tasks) async {
    if (await isConnected()) {
      try {
        final List<Map<String, dynamic>> tasksJson =
            tasks.map((task) => task.toJson()).toList();

        final Response response =
            await dio.patch('/list', data: {'list': tasksJson});

        if (response.statusCode == 200) {
          final data = response.data;
          TaskLogger().logDebug('Ответ от сервера: $data');

          if (data is Map<String, dynamic> && data['list'] is List<dynamic>) {
            final List<dynamic> list = data['list'];
            revision = response.data['revision'];
            TaskLogger().logDebug('Обновленная ревизия: $revision');

            final updatedTasks = list
                .map((item) => Task.fromJson(item as Map<String, dynamic>))
                .toList();

            // Сохранение задач в локальное хранилище
            await hiveService.clearBox();
            for (var task in updatedTasks) {
              await hiveService.saveTask(task);
            }

            return updatedTasks;
          } else {
            throw Exception('Некорректный формат данных');
          }
        } else {
          throw Exception(
              'Ошибка при обновлении задач: ${response.statusCode}');
        }
      } catch (e) {
        TaskLogger().logDebug('Ошибка при выполнении запроса: $e');
        throw Exception('Ошибка при выполнении запроса: $e');
      }
    } else {
      // Сохраняем обновленные задачи в локальное хранилище для последующей синхронизации
      for (var task in tasks) {
        await hiveService.saveTask(task);
      }
      return tasks;
    }
  }

  Future<void> saveTasksToLocalStorage(List<Task> tasks) async {
    await hiveService.clearBox();
    for (var task in tasks) {
      await hiveService.saveTask(task);
    }
  }

  Future<void> syncWithServer() async {
    if (await isConnected()) {
      final localTasks = await getTasksFromLocalStorage();

      try {
        final serverTasks = await getAllTasks();

        for (var localTask in localTasks) {
          if (!serverTasks.any((task) => task.id == localTask.id)) {
            await addTask(localTask);
          }
        }

        for (var serverTask in serverTasks) {
          if (!localTasks.any((task) => task.id == serverTask.id)) {
            await deleteTask(serverTask.id);
          }
        }
      } catch (e, stackTrace) {
        TaskLogger()
            .logError('Ошибка синхронизации с сервером: $e', stackTrace);
      }
    }
  }
}
