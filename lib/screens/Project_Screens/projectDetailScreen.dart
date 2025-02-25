import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/Palette.dart';
import 'package:taskly/models/Project.dart';
import 'package:taskly/models/Task.dart';
import 'package:taskly/models/User.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/provider/project_cubit.dart';
import 'package:taskly/provider/task_cubit.dart';
import 'package:taskly/provider/task_state.dart';
import 'package:taskly/widgets/Drawer.dart';
import 'package:taskly/widgets/TaskList.dart';

class ProjectDetailScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProjectDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? projectId = ModalRoute.of(context)!.settings.arguments as String?;

    if (projectId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("No se encontró el proyecto")),
      );
    }

    final project = context.watch<ProjectCubit>().projects!.firstWhere((p) => p.id == projectId);
    final authState = context.read<AuthCubit>().state;
    User? user;
    if (authState is AuthLoggedIn){
      user = authState.user;
    } else {
      return Container(
        color: Palette.backgroundColor,
      );
    }
    final tasksCubit = context.read<TaskCubit>();
    bool isEditable = project.leaderId == null || project.leaderId == user.id;


    List<Task> tasks = tasksCubit.state is TaskLoaded ? (tasksCubit.state as TaskLoaded).tasks : [];
    if (tasks.length == 0 || tasks[0].projectId != project.id) {
      Future.microtask(() => tasksCubit.fetchTasks(project));
    }

    void _showAddTaskDialog(BuildContext context, Project project) {
      final TextEditingController nameController = TextEditingController();
      final TextEditingController descriptionController = TextEditingController();

      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: Palette.backgroundColor,
            title: Text("Añadir Tarea", style: TextStyle(color: Palette.textColor)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Nombre de la tarea", labelStyle: TextStyle(color: Palette.textColor)),
                  style: TextStyle(color: Palette.textColor),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: "Descripción de la tarea", labelStyle: TextStyle(color: Palette.textColor)),
                  style: TextStyle(color: Palette.textColor)
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final description = descriptionController.text.trim();
                  if (name.isNotEmpty && description.isNotEmpty) {
                    await context.read<TaskCubit>().addTask(name, description, project);
                  }
                  Navigator.of(dialogContext).pop();
                },
                child: Text("Añadir", style: TextStyle(color: Colors.green)),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Palette.appBarColor,
          leading: IconButton(
            icon: Icon(Icons.menu),
            color: Palette.iconColor,
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              color: Palette.iconColor,
              onPressed: () => _showAddTaskDialog(context, project),
            ),
          ],
          title: Text(
            project.name[0].toUpperCase() + project.name.substring(1),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Palette.titleTextColor),
          ),
        ),
        drawer: BlocProvider.value(
          value: BlocProvider.of<ProjectCubit>(context),
          child: CustomDrawer(
            project: project,
            user: user,
            isEditable: isEditable,
            context: context,
          ),
        ),
        body: BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return Container(
                color: Palette.backgroundColor,
                child: Center(),
              );
            } else if (state is TaskError) {
              return Center(child: Text("Error: ${state.error}"));
            } else if (state is TaskLoaded) {
              final tasks = state.tasks;
              return TaskList(tasks: tasks, project: project);
            }
            return Center(child: Text("No hay tareas disponibles"));
          },
        ),
      );
  }
}
