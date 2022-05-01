part of 'task_list_bloc.dart';

@immutable
abstract class TaskListEvent {}

class TaskListStarted extends TaskListEvent {}

class TaskListSearch extends TaskListEvent {
  final String searchString;

  TaskListSearch(this.searchString);
}

class TaskListDeleteAll extends TaskListEvent {}

class TaskListDeleteByTask extends TaskListEvent {
  final Task task;

  TaskListDeleteByTask(this.task);
}
