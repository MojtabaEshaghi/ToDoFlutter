import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/data/data.dart';
import 'package:todo_list/data/repo/repository.dart';
import 'package:todo_list/data/source/task/hive_task_source.dart';
import 'package:todo_list/screens/home/home.dart';

const taskBoxName = 'tasks';
const primaryTextColor = Color(0xff1D2830);
const primaryColor = Color(0xff794CFF);
const secondaryTextColor = Color(0xffAFBED0);
const primaryContainerColor = Color(0xff5C0AFF);
const lowPriority = Color(0xff3BE1F1);
const normalPriority = Color(0xffF09819);
const highPriority = primaryColor;

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<Task>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: primaryContainerColor));
  runApp(ChangeNotifierProvider<Repository<Task>>(
    create: (context) =>
        Repository<Task>((HiveTaskDataSource(Hive.box(taskBoxName)))),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(
              TextTheme(headline6: TextStyle(fontWeight: FontWeight.bold))),
          inputDecorationTheme: const InputDecorationTheme(
              border: InputBorder.none,
              labelStyle: TextStyle(
                color: secondaryTextColor,
              ),
              iconColor: secondaryTextColor),
          colorScheme: const ColorScheme.light(
              primary: primaryColor,
              secondary: primaryColor,
              primaryContainer: primaryContainerColor,
              background: Color(0xffF3F5F8),
              onPrimary: Colors.white,
              onSurface: primaryTextColor,
              onBackground: primaryTextColor,
              onSecondary: Colors.white)),
      home: MyHomePage(),
    );
  }
}
