import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/models/Project.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/provider/task_cubit.dart';
import 'package:taskly/provider/task_state.dart';

class ProjectDetailScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  ProjectDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Project? project = ModalRoute.of(context)!.settings.arguments as Project?;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("No se encontró el proyecto")),
      );
    }
    final user = (context.read<AuthCubit>().state as AuthLoggedIn).user;

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
                  ListTile(
                    title: Text('Ver usuarios'),
                    onTap: () {
                      // Acción para ver los usuarios
                      Navigator.pop(context); // Cierra el Drawer
                    },
                  ),
                  ListTile(
                    title: Text('Añadir usuario'),
                    onTap: () {
                      // Acción para añadir usuario
                      Navigator.pop(context); // Cierra el Drawer
                    },
                  ),
                ],
              ),
              // Detalles
              ExpansionTile(
                title: Text('Detalles'),
                leading: Icon(Icons.info),
                children: <Widget>[
                  ListTile(
                    title: Text('Ver detalles del proyecto'),
                    onTap: () {
                      // Acción para ver los detalles del proyecto
                      Navigator.pop(context); // Cierra el Drawer
                    },
                  ),
                ],
              ),
              // Eliminar proyecto
              ListTile(
                title: Text('Eliminar proyecto'),
                leading: Icon(Icons.delete, color: Colors.red),
                onTap: () {
                  // Acción para eliminar el proyecto
                  Navigator.pop(context); // Cierra el Drawer
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
