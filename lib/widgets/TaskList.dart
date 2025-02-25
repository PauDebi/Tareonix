import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Tareonix/Palette.dart';
import 'package:Tareonix/dialogs/Dialogs.dart';
import 'package:Tareonix/models/Project.dart';
import 'package:Tareonix/models/Task.dart';
import 'package:Tareonix/provider/task_cubit.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Project project;

  TaskList({required this.tasks, required this.project});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TaskCubit>().fetchTasks(project);
      },
      child: Container(
        color: Palette.backgroundColor,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.25,
          ),
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return FadeInWidget(
              child: Card(
                color: Palette.cardColor,
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
                            Expanded( // Evita overflow del título
                              child: Text(
                                task.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Palette.titleTextColor,
                                ),
                                overflow: TextOverflow.ellipsis, // Recorta si es muy largo
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: _buildAssignedUser(context, task),
                            ),
                          ],
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
              ),
            );
          },
        ),
      ),
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
          color: Palette.backgroundColor,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Pendiente', style: TextStyle(color: task.status == 'TO_DO' ? Colors.grey : Palette.textColor)),
                onTap: () => _updateTaskStatus(context, task, 'TO_DO'),
              ),
              ListTile(
                title: Text('En Progreso', style: TextStyle(color: task.status == 'IN_PROGRESS' ? Colors.orange : Palette.textColor)),
                onTap: () => _updateTaskStatus(context, task, 'IN_PROGRESS'),
              ),
              ListTile(
                title: Text('Completado', style: TextStyle(color: task.status == 'DONE' ? Colors.green : Palette.textColor)),
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
      return CircleAvatar(
        radius: 20,
        backgroundColor: Palette.cardColor,
      );
    }

    final user = project.members.firstWhere((u) => u!.id == task.assignedUserId);
    return GestureDetector(
      onTap: () {
        Dialogs().showMemberDialog(context, user, false, false, project, task);
      },
      child: user?.profile_image != null
          ? CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(user!.profile_image!),
            )
          : CircleAvatar(
              radius: 20,
              child: Text(
                user!.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}

class FadeInWidget extends StatefulWidget {
  final Widget child;
  const FadeInWidget({Key? key, required this.child}) : super(key: key);

  @override
  _FadeInWidgetState createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
