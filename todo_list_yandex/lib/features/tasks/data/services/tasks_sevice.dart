import 'dart:convert';
import 'dart:io';
import 'package:dio/io.dart';
import 'package:hive/hive.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:dio/dio.dart';
import 'package:todo_list_yandex/logger/logger.dart';

class TasksService {
  final Dio dio;
  int revision = 0;

  TasksService({required this.dio}) {
    dio.options.baseUrl = 'https://beta.mrdekk.ru/todo';
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['Authorization'] = 'Bearer Ailinel';
      options.headers['X-Last-Known-Revision'] = revision.toString();
      return handler.next(options);
    }));

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<List<Task>> getAllTasks() async {
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
          final box = await Hive.openBox<Task>('my_tasks_box1');
          await box.clear();
          for (var task in tasks) {
            await box.put(task.id, task);
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
  }

  Future<void> addTask(Task task) async {
    try {
      final requestData = {
        'element': task.toJson(),
      };

      TaskLogger()
          .logDebug('Запрос на добавление задачи: ${jsonEncode(requestData)}');

      final response = await dio.post(
        '/list',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      TaskLogger().logDebug('Ответ сервера: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        revision = response.data['revision'];
        TaskLogger().logDebug('Обновленная ревизия: $revision');
        final List<Task> currentTasks = await getAllTasks();
        currentTasks.add(task);

        await updateTasks(currentTasks);
      } else {
        throw Exception('Ошибка при добавлении задачи: ${response.statusCode}');
      }
    } catch (e) {
      TaskLogger().logError('Ошибка при добавлении задачи: $e');
      throw Exception('Ошибка при добавлении задачи: $e');
    }
  }

  Future<Task> deleteTask(String taskId) async {
    if (taskId.isEmpty) {
      throw ArgumentError('Идентификатор задачи не может быть пустым');
    }
    try {
      final taskID = taskId.replaceAll(RegExp(r'[\[\]#]'), '');
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
        revision = response.data['revision'];
        TaskLogger()
            .logDebug('Обновленная ревизия после удаления задачи: $revision');
        final List<Task> currentTasks = await getAllTasks();
        currentTasks.removeWhere((task) => task.id == taskId);

        await updateTasks(currentTasks);
        return Task.fromJson(response.data);
      } else {
        throw Exception('Ошибка при удалении задачи: ${response.statusCode}');
      }
    } catch (e) {
      TaskLogger().logError('Ошибка при удалении задачи: $e');
      throw Exception('Ошибка при удалении задачи: $e');
    }
  }

  Future<Task> editTask(Task task) async {
    try {
      final requestData = {
        'element': task.toJson(),
      };

      final taskID = task.id.replaceAll(RegExp(r'[\[\]#]'), '');

      TaskLogger().logDebug(
          'Запрос на редактирование задачи: ${jsonEncode(requestData)}');

      final response = await dio.put(
        '/list/$taskID',
        data: requestData,
      );

      TaskLogger().logDebug('Ответ сервера: ${response.data}');

      if (response.statusCode == 200) {
        revision = response.data['revision'];
        TaskLogger().logDebug('Обновленная ревизия: $revision');
        final List<Task> currentTasks = await getAllTasks();

        final int index = currentTasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          currentTasks[index] = task;
        }

        await updateTasks(currentTasks);
        return Task.fromJson(response.data);
      } else {
        throw Exception(
            'Ошибка при редактировании задачи: ${response.statusCode}');
      }
    } on DioException catch (e) {
      TaskLogger()
          .logError('Ошибка при редактировании задачи (DioException): $e');
      if (e.response != null) {
        TaskLogger().logError('Response data: ${e.response?.data}');
        TaskLogger().logError('Response headers: ${e.response?.headers}');
        TaskLogger()
            .logError('Response status code: ${e.response?.statusCode}');

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
  }

  Future<List<Task>> updateTasks(List<Task> tasks) async {
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
          return list
              .map((item) => Task.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Некорректный формат данных');
        }
      } else {
        throw Exception('Ошибка при обновлении задач: ${response.statusCode}');
      }
    } catch (e) {
      TaskLogger().logDebug('Ошибка при выполнении запроса: $e');
      throw Exception('Ошибка при выполнении запроса: $e');
    }
  }

  Future<List<Task>> getTasksFromLocalStorage() async {
    final box = await Hive.openBox<Task>('my_tasks_box1');
    return box.values.toList();
  }
}
