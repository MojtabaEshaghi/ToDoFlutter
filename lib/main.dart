import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/data.dart';
import 'package:todo_list/edit.dart';
import 'package:todo_list/generated/assets.dart';

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
  MyHomePage({Key? key}) : super(key: key);
  final ValueNotifier<String> searchKeywordNotifier = ValueNotifier('');
  final TextEditingController controller = TextEditingController();

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
                    child: TextField(
                      onChanged: (value) {
                        searchKeywordNotifier.value = controller.text;
                      },
                      controller: controller,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                          ),
                          hintText: "Search Tasks ... "),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: searchKeywordNotifier,
                builder: (context,value,child){
                  return ValueListenableBuilder<Box<Task>>(
                      valueListenable: box.listenable(),
                      builder: (context, box, child) {
                        final List<Task> items;
                        if(controller.text.isEmpty){
                          items=box.values.toList();
                        }else{
                          items=box.values.where((element) => element.name.contains(controller.text)).toList();
                          items.forEach((element) {log(element.name.toString());});
                        }


                        if (items.isNotEmpty) {
                          return ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: items.length + 1,
                              itemBuilder: (ctx, index) {
                                if (index == 0) {
                                  return Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                color:
                                                themeData.colorScheme.primary,
                                                borderRadius:
                                                BorderRadius.circular(1.5)),
                                            margin: EdgeInsets.only(top: 4),
                                          )
                                        ],
                                      ),
                                      MaterialButton(
                                        color: const Color(0xffEAEFF5),
                                        textColor: secondaryTextColor,
                                        onPressed: () {
                                          box.clear();
                                        },
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
                                  Task taskEntity = items[index - 1];
                                  return TaskItem(taskEntity: taskEntity);
                                }
                              });
                        } else {
                          return const EmptyState();
                        }
                      });
                },
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditTaskScreen(
                        task: Task(),
                      )));
            },
            label: Row(
              children: [
                Text('Add New Task '),
                SizedBox(
                  width: 12,
                ),
                Icon(CupertinoIcons.add),
              ],
            )),
      ),
    );
  }
}

class TaskItem extends StatefulWidget {
  const TaskItem({
    Key? key,
    required this.taskEntity,
  }) : super(key: key);

  final Task taskEntity;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final taskColor;
    switch (widget.taskEntity.priority) {
      case Priority.high:
        taskColor = highPriority;
        break;
      case Priority.normal:
        taskColor = normalPriority;
        break;
      case Priority.low:
        taskColor = lowPriority;
        break;
    }
    return InkWell(
      onLongPress: () {
        widget.taskEntity.delete();
      },
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditTaskScreen(
                  task: widget.taskEntity,
                )));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.only(left: 16),
        height: 80,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: themeData.colorScheme.surface,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)
            ]),
        child: Row(
          children: [
            MyCheckBox(
                value: widget.taskEntity.isCompleted,
                onTap: () {
                  setState(() {
                    widget.taskEntity.isCompleted =
                        !widget.taskEntity.isCompleted;
                  });
                }),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Text(
                widget.taskEntity.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 18,
                    decoration: widget.taskEntity.isCompleted
                        ? TextDecoration.lineThrough
                        : null),
              ),
            ),
            Container(
              width: 6,
              height: 84,
              decoration: BoxDecoration(
                  color: taskColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8))),
            )
          ],
        ),
      ),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  const MyCheckBox({Key? key, required this.value, required this.onTap})
      : super(key: key);
  final bool value;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: !value
                  ? Border.all(color: secondaryTextColor, width: 2)
                  : null,
              color: value ? primaryColor : null),
          child: value
              ? Icon(
                  CupertinoIcons.check_mark,
                  color: themeData.colorScheme.onPrimary,
                  size: 14,
                )
              : null),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          Assets.assetsEmptyState,
          width: 120,
        ),
        SizedBox(
          height: 14,
        ),
        Text("Your Task is Empty")
      ],
    );
  }
}
