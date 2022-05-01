import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/data/data.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/screens/edit/edit_task_cubit.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({Key? key}) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(
        text: context.read<EditTaskCubit>().state.task.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.surface,
        foregroundColor: themeData.colorScheme.onSurface,
        elevation: 0,
        title: const Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            BlocBuilder<EditTaskCubit, EditTaskState>(
              builder: (context, state) {
                final priority = state.task.priority;
                return Flex(
                  direction: Axis.horizontal,
                  children: [
                    Flexible(
                        flex: 1,
                        child: PriorityCheckBox(
                          label: 'High',
                          color: primaryColor,
                          isSelected: priority == Priority.high,
                          callback: () {
                            context
                                .read<EditTaskCubit>()
                                .onPriorityChange(Priority.high);
                          },
                        )),
                    SizedBox(
                      width: 8,
                    ),
                    Flexible(
                        flex: 1,
                        child: PriorityCheckBox(
                          label: 'Normal',
                          color: normalPriority,
                          isSelected: priority == Priority.normal,
                          callback: () {
                            context
                                .read<EditTaskCubit>()
                                .onPriorityChange(Priority.normal);
                          },
                        )),
                    SizedBox(
                      width: 8,
                    ),
                    Flexible(
                        flex: 1,
                        child: PriorityCheckBox(
                          label: 'Low',
                          color: lowPriority,
                          isSelected:  priority == Priority.low,
                          callback: () {
                            context
                                .read<EditTaskCubit>()
                                .onPriorityChange(Priority.normal);
                          },
                        )),
                  ],
                );
              },
            ),
            TextField(
              controller: _controller,
              onChanged: (value){
                context
                    .read<EditTaskCubit>()
                    .onTextChange(value);
              },
              decoration: const InputDecoration(
                  label: Text(
                "Add a task for today...",
                style: TextStyle(color: primaryTextColor, fontSize: 16),
              )),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.read<EditTaskCubit>().onSaveChangesClick();
            Navigator.of(context).pop();
          },
          label: Row(
            children: const [
              Text('Save Changes'),
              SizedBox(
                width: 8,
              ),
              Icon(
                CupertinoIcons.check_mark,
                size: 16,
              )
            ],
          )),
    );
  }
}

class PriorityCheckBox extends StatelessWidget {
  const PriorityCheckBox(
      {Key? key,
      required this.label,
      required this.color,
      required this.isSelected,
      required this.callback})
      : super(key: key);
  final String label;
  final Color color;
  final bool isSelected;
  final GestureTapCallback callback;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                width: 2, color: secondaryTextColor.withOpacity(0.2))),
        child: Stack(
          children: [
            Center(
              child: Text(label),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _PriorityCheckMark(
                  value: isSelected,
                  color: color,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _PriorityCheckMark extends StatelessWidget {
  const _PriorityCheckMark({Key? key, required this.value, required this.color})
      : super(key: key);
  final bool value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), color: color),
        child: value
            ? Icon(
                CupertinoIcons.check_mark,
                color: themeData.colorScheme.onPrimary,
                size: 12,
              )
            : null);
  }
}
