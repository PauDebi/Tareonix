import 'package:equatable/equatable.dart';
import 'package:taskly/models/Task.dart';

class TaskState extends Equatable {
  final List<Task> tasks;

  TaskState({required this.tasks});

  @override
  List<Object?> get props => [tasks];

  TaskState copyWith({List<Task>? tasks}) {
    return TaskState(tasks: tasks ?? this.tasks);
  }

  @override
  String toString() {
    return 'TaskState{tasks: $tasks}';
  }
}