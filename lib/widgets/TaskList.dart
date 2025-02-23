import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/dialogs/Dialogs.dart';
import 'package:taskly/models/Project.dart';
import 'package:taskly/models/Task.dart';
import 'package:taskly/provider/task_cubit.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Project project;

  TaskList({required this.tasks, required this.project});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/taskDetails', arguments: task),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        task.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: _buildAssignedUser(context, task)
                      )
                    ]
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      task.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: _buildStatusChip(context, task),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, Task task) {
    Color chipColor;
    String label;

    switch (task.status) {
      case 'IN_PROGRESS':
        chipColor = Colors.orange;
        label = 'En Progreso';
        break;
      case 'DONE':
        chipColor = Colors.green;
        label = 'Completado';
        break;
      default:
        chipColor = Colors.grey;
        label = 'Pendiente';
        break;
    }

    return GestureDetector(
      onTap: () => _showStatusMenu(context, task),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: chipColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  void _showStatusMenu(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Pendiente'),
                onTap: () => _updateTaskStatus(context, task, 'TO_DO'),
              ),
              ListTile(
                title: Text('En Progreso'),
                onTap: () => _updateTaskStatus(context, task, 'IN_PROGRESS'),
              ),
              ListTile(
                title: Text('Completado'),
                onTap: () => _updateTaskStatus(context, task, 'DONE'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateTaskStatus(BuildContext context, Task task, String newStatus) {
    task.status = newStatus;
    context.read<TaskCubit>().updateTask(task, project);
    Navigator.pop(context);
  }

  Widget _buildAssignedUser(BuildContext context, Task task) {
    if (task.assignedUserId == null) {
      return const SizedBox.shrink();
    }

    final user = project.members.firstWhere((u) => u!.id == task.assignedUserId);
    return 
      GestureDetector(
        onTap: () {
          // Handle the tap event, e.g., navigate to user profile
          Dialogs().showMemberDialog(context, user, false, false, project ,task);
        },
        child: user?.profile_image != null ?
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(user!.profile_image!),
          ):
          CircleAvatar(
            radius: 20,
            child: Text(
              user!.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          )
      );
  }
}
