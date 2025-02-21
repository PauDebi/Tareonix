import 'package:equatable/equatable.dart';
import 'package:taskly/models/Task.dart';

class TaskState extends Equatable {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;

  TaskState({required this.tasks, this.isLoading = false, this.error});

  @override
  List<Object?> get props => [tasks, isLoading, error];

  TaskState copyWith({List<Task>? tasks, bool? isLoading, String? error}) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'TaskState{tasks: $tasks, isLoading: $isLoading, error: $error}';
  }
}

// Estados específicos
class TaskLoading extends TaskState {
  TaskLoading() : super(tasks: [], isLoading: true);
}

class TaskAdded extends TaskState {
  TaskAdded(List<Task> tasks) : super(tasks: tasks);
}

class TaskError extends TaskState {
  TaskError(String error) : super(tasks: [], error: error);
}

class TaskLoaded extends TaskState {
  TaskLoaded(List<Task> tasks) : super(tasks: tasks);
}
