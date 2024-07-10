import 'dart:convert';
import 'dart:io';
import 'package:dio/io.dart';
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
        logger.d('Ответ от сервера: $data');

        if (data is Map<String, dynamic> && data['list'] is List<dynamic>) {
          final List<dynamic> list = data['list'];
          revision = response.data['revision'];
          logger.d('Обновленная ревизия: $revision');
          return list
              .map((item) => Task.fromJson(item as Map<String, dynamic>))
              .toList();
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

      logger.d('Запрос на добавление задачи: ${jsonEncode(requestData)}');

        TaskLogger().logDebug('Запрос $response');
        TaskLogger().logDebug('Ответ сервера: ${response.data}');

      logger.d('Ответ сервера: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        revision = response.data['revision'];
        logger.d('Обновленная ревизия: $revision');
        final List<Task> currentTasks = await getAllTasks();
        currentTasks.add(task);

        await updateTasks(currentTasks);
      } else {
        throw Exception('Ошибка при добавлении задачи: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Ошибка при добавлении задачи: $e');
      throw Exception('Ошибка при добавлении задачи: $e');
    }
  }

  Future<Task> deleteTask(String taskId) async {
    if (taskId.isEmpty) {
      throw ArgumentError('Идентификатор задачи не может быть пустым');
    }

      logger.d('Ответ сервера на удаление задачи: ${response.data}');

      if (response.statusCode == 200) {
        revision = response.data['revision'];
        logger.d('Обновленная ревизия после удаления задачи: $revision');
        final List<Task> currentTasks = await getAllTasks();
        currentTasks.removeWhere((task) => task.id == taskId);

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

          await hiveService.deleteTask(taskId);

          return Task.fromJson(response.data);
        } else {
          throw Exception('Ошибка при удалении задачи: ${response.statusCode}');
        }
      } catch (e, stackTrace) {
        TaskLogger().logError('Ошибка при удалении задачи: $e', stackTrace);
        throw Exception('Ошибка при удалении задачи: $e');
      }
    } catch (e) {
      logger.e('Ошибка при удалении задачи: $e');
      throw Exception('Ошибка при удалении задачи: $e');
    }
  }

  Future<Task> editTask(Task task) async {
    if (await isConnected()) {
      try {
        final requestData = {
          'element': task.toJson(),
        };

        final taskID = task.id.replaceAll(RegExp(r'[\\[\\]#]'), '');

      logger.d('Запрос на редактирование задачи: ${jsonEncode(requestData)}');

        final response = await dio.put(
          '/list/$taskID',
          data: requestData,
        );

      logger.d('Ответ сервера: ${response.data}');

      if (response.statusCode == 200) {
        revision = response.data['revision'];
        logger.d('Обновленная ревизия: $revision');
        final List<Task> currentTasks = await getAllTasks();

          final int index = currentTasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            currentTasks[index] = task;
          }

          await updateTasks(currentTasks);

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

        await updateTasks(currentTasks);
        return Task.fromJson(response.data);
      } else {
        throw Exception(
            'Ошибка при редактировании задачи: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('Ошибка при редактировании задачи (DioException): $e');
      if (e.response != null) {
        logger.e('Response data: ${e.response?.data}');
        logger.e('Response headers: ${e.response?.headers}');
        logger.e('Response status code: ${e.response?.statusCode}');

        if (e.response?.statusCode == 400 &&
            e.response?.data == 'unsynchronized data') {
          await getAllTasks();
          await editTask(task);
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
        logger.d('Ответ от сервера: $data');

        if (data is Map<String, dynamic> && data['list'] is List<dynamic>) {
          final List<dynamic> list = data['list'];
          revision = response.data['revision'];
          logger.d('Обновленная ревизия: $revision');
          return list
              .map((item) => Task.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
              'Ошибка при обновлении задач: ${response.statusCode}');
        }
      } catch (e) {
        TaskLogger().logDebug('Ошибка при выполнении запроса: $e');
        throw Exception('Ошибка при выполнении запроса: $e');
      }
    } catch (e) {
      logger.d('Ошибка при выполнении запроса: $e');
      throw Exception('Ошибка при выполнении запроса: $e');
    }
  }
}
