import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/data.dart';

const taskBoxName = 'tasks';
const primaryTextColor = Color(0xff1D2830);
const primaryColor = Color(0xff794CFF);
const secondaryTextColor = Color(0xffAFBED0);
const primaryContainerColor = Color(0xff5C0AFF);

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<Task>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: primaryContainerColor));
  runApp(const MyApp());
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>(taskBoxName);
    final themeData = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.0),
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  themeData.colorScheme.primary,
                  themeData.colorScheme.primaryContainer
                ],
              )),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "To Do List",
                        style: themeData.textTheme.headline6!
                            .apply(color: Colors.white),
                      ),
                      Icon(
                        CupertinoIcons.share,
                        color: themeData.colorScheme.onPrimary,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    height: 38,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: themeData.colorScheme.onPrimary,
                        boxShadow: [
                          BoxShadow(
                              color: themeData.colorScheme.onPrimary,
                              blurRadius: 12)
                        ]),
                    child: const TextField(
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                          ),
                          label: Text("Search Tasks ... ")),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<Box<Task>>(
                  valueListenable: box.listenable(),
                  builder: (context, box, child) {
                    return ListView.builder(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: box.values.length + 1,
                        itemBuilder: (ctx, index) {
                          if (index == 0) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Today",
                                      style: themeData.textTheme.headline6!
                                          .apply(fontSizeFactor: 0.9),
                                    ),
                                    Container(
                                      width: 70,
                                      height: 3,
                                      decoration: BoxDecoration(
                                          color: themeData.colorScheme.primary,
                                          borderRadius:
                                              BorderRadius.circular(1.5)),
                                      margin: EdgeInsets.only(top: 4),
                                    )
                                  ],
                                ),
                                MaterialButton(
                                  color: const Color(0xffEAEFF5),
                                  textColor: secondaryTextColor,
                                  onPressed: () {},
                                  elevation: 0,
                                  child: Row(
                                    children: const [
                                      Text("Delete All"),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Icon(
                                        CupertinoIcons.delete_solid,
                                        size: 16,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            );
                          } else {
                            Task taskEntity = box.values.toList()[index - 1];
                            return TaskItem(taskEntity: taskEntity);
                          }
                        });
                  }),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EditTaskScreen()));
            },
            label: const Text('Add New Task ')),
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  const TaskItem({
    Key? key,
    required this.taskEntity,
  }) : super(key: key);

  final Task taskEntity;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: themeData.colorScheme.surface,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)
            ]),
        child: Row(
          children: [
            Text(taskEntity.name),
            MyCheckBox(value: taskEntity.isCompleted)
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  EditTaskScreen({Key? key}) : super(key: key);
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration:
                const InputDecoration(label: Text("Add a task for today...")),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Task task = Task();
            task.name = _controller.text;
            task.priority = Priority.low;
            task.isCompleted = false;
            if (task.isInBox) {
              task.save();
            } else {
              final Box<Task> box = Hive.box(taskBoxName);
              box.add(task);
            }
            Navigator.of(context).pop();
          },
          label: const Text('Save Changes')),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  MyCheckBox({Key? key, required this.value}) : super(key: key);
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: value ? Border.all(color: secondaryTextColor) : null,
            color: value ? primaryColor : null),
        child: value
            ? Icon(
                CupertinoIcons.check_mark,
                color: Colors.white,
              )
            : null);
  }
}
