import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/models/Project.dart';
import 'package:taskly/models/User.dart';
import 'package:taskly/provider/project_cubit.dart';
import 'package:taskly/provider/auth_cubit.dart';

class ProjectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read<ProjectCubit>().loadProjects();
    void _showUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Perfil de Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            GestureDetector(
                //onTap: () => _pickImage(context, user),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: user.imageUrl != null && user.imageUrl!.isNotEmpty
                      ? NetworkImage(user.imageUrl!)
                      : null,
                  child: user.imageUrl == null || user.imageUrl!.isEmpty
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              Text("Nombre: ${user.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Email: ${user.email}"),
              Text("Fecha de Creacion: ${user.createdAt}")
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthCubit>().logout();
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trello's Competency"),
        actions: [
          FutureBuilder<User?>(
            future: context.read<AuthCubit>().getUser(), // Llamar a getUser()
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Muestra un indicador de carga
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return IconButton(
                  icon: Icon(Icons.error, color: Colors.red),
                  onPressed: () {
                  }, // Acción en caso de error
                );
              }

              final user = snapshot.data!;
              return IconButton(
                icon: user.imageUrl != null
                    ? CircleAvatar(backgroundImage: NetworkImage(user.imageUrl!))
                    : CircleAvatar(
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                onPressed: () {
                  _showUserDialog(context, user);
                },
              );
            },
          ),
        ],
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, authState) {
          if (authState is AuthLoggedOut) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home',
                      (Route<dynamic> route) => false
                );
          }
        },
        child: BlocBuilder<ProjectCubit, ProjectState>(
          builder: (context, state) {
            if (state is ProjectLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ProjectLoaded) {
              state.projects.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProjectCubit>().refreshProjects();
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: state.projects.length,
                  itemBuilder: (context, index) {
                    final Project project = state.projects[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.folder, color: Colors.white),
                        ),
                        title: Text(
                          project.name,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          project.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                        onTap: () {
                          // Acción al tocar el proyecto
                        },
                      ),
                    );
                  },
                ),
              );
            } else if (state is ProjectError) {
              return Center(child: Text(state.message));
            } else {
              return Center(child: Text("No hay proyectos disponibles."));
            }
          },
        ),
      ),
    );
  }
}
