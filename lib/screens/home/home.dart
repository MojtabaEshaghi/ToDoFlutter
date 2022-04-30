import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/data/data.dart';
import 'package:todo_list/data/repo/repository.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/screens/edit/edit.dart';
import 'package:todo_list/widgets/widgets.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);
  final ValueNotifier<String> searchKeywordNotifier = ValueNotifier('');
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                builder: (context, value, child) {
                  final repository = Provider.of<Repository<Task>>(context);
                  return Consumer<Repository<Task>>(
                    builder: (ctx, repository, child) {
                      return FutureBuilder<List<Task>>(
                        future:
                            repository.getAll(searchKeyword: controller.text),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.isNotEmpty) {
                              return TaskList(
                                  items: snapshot.data!, themeData: themeData);
                            } else {
                              return const EmptyState();
                            }
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      );
                    },
                  );
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

class TaskList extends StatelessWidget {
  const TaskList({
    Key? key,
    required this.items,
    required this.themeData,
  }) : super(key: key);

  final List<Task> items;
  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: items.length + 1,
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
                          borderRadius: BorderRadius.circular(1.5)),
                      margin: EdgeInsets.only(top: 4),
                    )
                  ],
                ),
                MaterialButton(
                  color: const Color(0xffEAEFF5),
                  textColor: secondaryTextColor,
                  onPressed: () {
                    final repository = Provider.of<Repository<Task>>(context,listen: false);
                    repository.deleteAll();
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
