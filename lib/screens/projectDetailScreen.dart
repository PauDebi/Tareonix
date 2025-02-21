import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/models/Project.dart';
import 'package:taskly/models/Task.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/provider/project_cubit.dart';
import 'package:taskly/provider/task_cubit.dart';
import 'package:taskly/provider/task_state.dart';
import 'package:taskly/widgets/Drawer.dart';

class ProjectDetailScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  ProjectDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Project? temp = ModalRoute.of(context)!.settings.arguments as Project?;
  
    if (temp == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("No se encontró el proyecto")),
      );
    }

    final project_id = temp.id;
    final project = context.read<ProjectCubit>().projects!.firstWhere((element) => element.id == project_id);
    final user = (context.read<AuthCubit>().state as AuthLoggedIn).user;
    bool isEditable = project.leaderId == null || project.leaderId == user.id;

    void _showAddTaskDialog(BuildContext context, Project project) {
      final TextEditingController nameController = TextEditingController();
      final TextEditingController descriptionController = TextEditingController();

      showDialog(
        context: context,
        builder: (dialogContext) {
          return BlocProvider.value(
            value: BlocProvider.of<TaskCubit>(context), // Mantiene la misma instancia de TaskCubit
            child: AlertDialog(
              title: Text("Añadir Tarea"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Nombre de la tarea"),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: "Descripción de la tarea"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Cerrar diálogo
                  },
                  child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final description = descriptionController.text.trim();
                    if (name.isNotEmpty && description.isNotEmpty) {
                      await BlocProvider.of<TaskCubit>(dialogContext)
                          .addTask(name, description, project);
                    }
                    Navigator.of(dialogContext).pop(); // Cerrar diálogo
                  },
                  child: Text("Añadir", style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
          );
        },
      );
    }


  return BlocProvider(
    create: (context) => TaskCubit()..fetchTasks(project),
    child: Scaffold(
        key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();  // Abrir el Drawer con la clave global
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddTaskDialog(context, project);
            },
          ),
        ],
        title: Text(
          project.name[0].toUpperCase() + project.name.substring(1),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: BlocProvider.value(
        value: BlocProvider.of<ProjectCubit>(context),
        child: CustomDrawer(project: project, user: user, isEditable: isEditable, context: context)
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tareas del Proyecto",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<TaskCubit, TaskState>(
                builder: (context, state) {
                  if (state.tasks.isEmpty) {
                    return const Center(child: Text("No hay tareas disponibles"));
                  }
                  return ListView.builder(
                    itemCount: state.tasks.length,
                    itemBuilder: (context, index) {
                      final task = state.tasks[index];
                      return ListTile(
                        title: Text(task.name),
                        subtitle: Text(task.description),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );}
}
