import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/Palette.dart';
import 'package:taskly/dialogs/Dialogs.dart';
import 'package:taskly/models/Task.dart';
import 'package:taskly/models/User.dart';
import 'package:taskly/provider/project_cubit.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'DONE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectCubit>().projects!.firstWhere((p) => p.id == task.projectId);
    User? user;
    if (task.assignedUserId != null) {
      user = project.members.firstWhere((u) => u!.id == task.assignedUserId);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(task.name, style: TextStyle(color: Palette.titleTextColor)),
        backgroundColor: Palette.appBarColor,
        iconTheme: IconThemeData(color: Palette.iconColor),
        actions: [
          PopupMenuButton<int>(
            color: Palette.cardColor,
            onSelected: (value) {},
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text("Aisgnar tarea", style: TextStyle(color: Palette.textColor)),
                onTap: () => Dialogs().showAssignTaskDialog(context, project, task),
              ),
              PopupMenuItem(
                value: 2,
                child: Text("Borrar tarea", style: TextStyle(color: Palette.textColor)),
                onTap: () {
                  final dialogs = Dialogs();
                  dialogs.showDeleteTaskDialog(context, task, project);
                },
              ),
              PopupMenuItem(
                value: 3,
                child: Text("Editar tarea", style: TextStyle(color: Palette.textColor)),
                onTap: () => Dialogs().showEditTaskDialog(context, task, project),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: Palette.backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Palette.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Palette.titleTextColor
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Descripcion:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Palette.textColor),
                ),
                const SizedBox(height: 5),
                Text(
                  task.description,
                  style: TextStyle(fontSize: 14, color: Palette.textColor),
                ),
                const SizedBox(height: 10),
                if (user != null)
                  Row(
                    children: [
                      user.profile_image != null 
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user.profile_image!),
                          )
                        : CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                      const SizedBox(width: 10),
                      Text("Assigned to: ${user.name}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Palette.textColor)),
                    ],
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Status: ",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Palette.textColor),
                    ),
                    Chip(
                      label: Text(task.status),
                      backgroundColor: _getStatusColor(task.status).withOpacity(0.2),
                      labelStyle: TextStyle(color: _getStatusColor(task.status)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
