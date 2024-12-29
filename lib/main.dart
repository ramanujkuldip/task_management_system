import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'constants/constants.dart';
import 'helper/hive_db_helper.dart';
import 'helper/sql_db_helper.dart';
import 'model/user_model.dart';
import 'view/login_view.dart';
import 'view/tasks_view.dart';
import 'view_model/user_prefs_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDbHelper.initHive();
  DatabaseHelper.instance.initDb();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userView = ref.watch(userProvider) ?? UserModel();

    final lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor)),
      ),
    );
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor)),
      ),
    );
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: userView.isLightTheme != null && (userView.isLightTheme == false) ? ThemeMode.dark : ThemeMode.light,
      darkTheme: darkTheme,
      theme: lightTheme,
      home: HiveDbHelper.userData != null ? const TasksView() : const LoginView(),
      // home: const TasksView(),
    );
  }
}
