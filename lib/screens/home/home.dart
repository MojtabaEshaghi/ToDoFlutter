import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/data/data.dart';
import 'package:todo_list/data/repo/repository.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/screens/edit/edit.dart';
import 'package:todo_list/screens/edit/edit_task_cubit.dart';
import 'package:todo_list/screens/home/bloc/task_list_bloc.dart';
import 'package:todo_list/widgets/widgets.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => BlocProvider(
                      create: (context) => EditTaskCubit(
                          Task(), context.read<Repository<Task>>()),
                      child: const EditTaskScreen(),
                    )));
          },
          label: Row(
            children: const [
              Text('Add New Task '),
              SizedBox(
                width: 12,
              ),
              Icon(CupertinoIcons.add),
            ],
          )),
      body: BlocProvider<TaskListBloc>(
        create: (context) => TaskListBloc(context.read<Repository<Task>>()),
        child: SafeArea(
            child: Column(
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
                        context.read<TaskListBloc>().add(TaskListSearch(value));
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
            Expanded(child: Consumer<Repository<Task>>(
              builder: (context, repository, child) {
                context.read<TaskListBloc>().add(TaskListStarted());
                return BlocBuilder<TaskListBloc, TaskListState>(
                    builder: (context, state) {
                  if (state is TaskListSuccess) {
                    return TaskList(items: state.items, themeData: themeData);
                  } else if (state is TaskListEmptyDb) {
                    return const EmptyState();
                  } else if (state is TaskListLoading ||
                      state is TaskListInitial) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is TaskListError) {
                    return Center(
                      child: Text(
                        state.message,
                      ),
                    );
                  } else {
                    throw Exception("state is not valid");
                  }
                });
              },
            )),
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
                    context.read<TaskListBloc>().add(TaskListDeleteAll());
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
            builder: (context) => BlocProvider<EditTaskCubit>(
                  create: (context) => EditTaskCubit(
                      widget.taskEntity, context.read<Repository<Task>>()),
                  child: const EditTaskScreen(),
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
