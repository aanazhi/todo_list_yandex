import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list_yandex/config/theme/app_theme.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/presentation/screens/add_edit_task_screen.dart';
import 'package:todo_list_yandex/features/tasks/presentation/screens/home_screen.dart';
import 'package:todo_list_yandex/generated/l10n.dart';
import 'package:todo_list_yandex/logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  runApp(ProviderScope(child: TodoApp()));
}

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  static const platform = MethodChannel('com.example.todo_list_yandex/intent');
  late final GoRouter _router;
  bool _initialIntentHandled = false;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomeScreen(),
        ),
        GoRoute(
          path: '/addtask',
          builder: (context, state) {
            final task = state.extra as Task?;
            return AddEditTaskScreen(task: task);
          },
        ),
      ],
    );

    _handleInitialIntent();

    platform.setMethodCallHandler((call) async {
      print('Received method call: ${call.method}');
      if (call.method == "handleUri") {
        final uri = Uri.tryParse(call.arguments);
        print('Received handleUri method call with URI: ${call.arguments}');
        if (uri != null) {
          print('Scheme: ${uri.scheme}');
          print('Host: ${uri.host}');
          if (uri.scheme == 'myapp' && uri.host == 'addtask') {
            if (mounted) {
              setState(() {
                _router.go('/addtask');
              });
            }
          }
        }
      }
    });
  }

  Future<void> _handleInitialIntent() async {
    if (_initialIntentHandled) return;

    try {
      final String? uriString = await platform.invokeMethod('getInitialIntent');
      print('Initial intent URI: $uriString');
      if (uriString != null) {
        final uri = Uri.tryParse(uriString);
        if (uri != null && uri.scheme == 'myapp' && uri.host == 'addtask') {
          if (mounted) {
            setState(() {
              _router.go('/addtask');
            });
          }
        }
      }
    } on PlatformException catch (e) {
      print("Failed to get initial intent: '${e.message}'.");
    } finally {
      _initialIntentHandled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
    );
  }
}
