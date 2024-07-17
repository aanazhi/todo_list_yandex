import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list_yandex/config/theme/app_theme.dart';
import 'package:todo_list_yandex/features/tasks/data/models/task_model.dart';
import 'package:todo_list_yandex/features/tasks/data/router/app_router.dart';
import 'package:todo_list_yandex/generated/l10n.dart';
import 'package:todo_list_yandex/logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitDown,
  ]);
  runApp(ProviderScope(child: TodoApp()));
}

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  static const platform = MethodChannel('com.example.todo_list_yandex/intent');
  late final AppRouter _appRouter;
  bool _initialIntentHandled = false;

  @override
  void initState() {
    super.initState();

    _appRouter = AppRouter();

    _handleInitialIntent();

    platform.setMethodCallHandler((call) async {
      if (call.method == "handleUri") {
        final uri = Uri.tryParse(call.arguments);

        if (uri != null) {
          if (uri.scheme == 'myapp' && uri.host == 'addtask') {
            if (mounted) {
              setState(() {
                _appRouter.navigateToAddTask(context);
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

      if (uriString != null) {
        final uri = Uri.tryParse(uriString);
        if (uri != null && uri.scheme == 'myapp' && uri.host == 'addtask') {
          if (mounted) {
            setState(() {
              _appRouter.navigateToAddTask(context);
            });
          }
        }
      }
    } on PlatformException catch (e) {
      TaskLogger().logDebug("Failed to get initial intent: '${e.message}'.");
    } finally {
      _initialIntentHandled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.router,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
    );
  }
}
