import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/models/Project.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/provider/project_cubit.dart';
import 'package:taskly/provider/task_cubit.dart';
import 'package:taskly/provider/task_state.dart';

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

    void _showProjectDetails() {

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Detalles del Proyecto',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📌 Nombre: ${project.name}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('📝 Descripción: ${project.description}', style: TextStyle(fontSize: 14)),
                  SizedBox(height: 8),
                  Text('📅 Fecha de inicio: ${project.createdAt.day.toString().padLeft(2, '0')}-'
                      '${project.createdAt.month.toString().padLeft(2, '0')}-'
                      '${project.createdAt.year}', style: TextStyle(fontSize: 14)),
                  SizedBox(height: 12),
                  if (project.leaderId != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('👤 Creador del Proyecto:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: project.members
                                          .firstWhere((member) => member!.id == project.leaderId)
                                          ?.profile_image !=
                                      null
                                  ? NetworkImage(project.members
                                          .firstWhere((member) => member!.id == project.leaderId)
                                          !.profile_image!)
                                  : AssetImage('assets/default_avatar.png') as ImageProvider,
                            ),
                            SizedBox(width: 12),
                            Text(
                              project.members
                                  .firstWhere((member) => member!.id == project.leaderId)
                                  ?.name ?? 'Desconocido',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              if (isEditable)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/editProject', arguments: project);
                  },
                  child: Text('Editar', style: TextStyle(color: Colors.green)),
                ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar', style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        },
      );
    }

void _showAddUserDialog(BuildContext context, String projectId) {
  final TextEditingController emailController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Añadir Usuario"),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: "Email del usuario"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
            },
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                context.read<ProjectCubit>().addUserToProjectByEmail(projectId, email);
              }
              Navigator.of(context).pop(); // Cerrar diálogo
            },
            child: Text("Añadir", style: TextStyle(color: Colors.green)),
          ),
        ],
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
                // Acción para agregar tareas
              },
            ),
          ],
          title: Text(
            project.name[0].toUpperCase() + project.name.substring(1),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(user.name),
                accountEmail: Text(user.email),
                currentAccountPicture: user.profile_image != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(user.profile_image!),
                      )
                    : CircleAvatar(
                        child: Text(user.name[0].toUpperCase()),
                ),
              ),
              // Usuarios
              ExpansionTile(
                title: Text('Usuarios'),
                leading: Icon(Icons.people),
                children: <Widget>[
                  // Lista de usuarios dentro del drawer
          ...project.members.map((member) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: member!.profile_image != null
                      ? NetworkImage(member.profile_image!)
                      : AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                title: Text(member.name),
                subtitle: Text(member.email),
                )),
                  ListTile(
                    title: Text('Añadir usuario'),
                    onTap: () {
                      Navigator.pop(context); // Cierra el Drawer
                      _showAddUserDialog(context, project.id);
                    },
                  ),
                ],
              ),
              // Detalles
              ListTile(
                title: Text('Detalles'),
                leading: Icon(Icons.info),
                  onTap: () {
                    Navigator.pop(context); // Cierra el Drawer
                    _showProjectDetails();
                  },
              ),
              // Eliminar proyecto
              if (isEditable)
              ListTile(
                title: Text('Eliminar proyecto'),
                leading: Icon(Icons.delete, color: Colors.red),
                onTap: () {
                  context.read<ProjectCubit>().deleteProject(project);
                  Navigator.pop(context); // Cierra el Drawer
                  Navigator.pop(context); // Cierra la pantalla de detalles
                },
              ),
            ],
          ),
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
    );
  }
}
