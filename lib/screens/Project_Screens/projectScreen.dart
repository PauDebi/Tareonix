import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/dialogs/Dialogs.dart';
import 'package:taskly/models/User.dart';
import 'package:taskly/provider/project_cubit.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/widgets/ProjectList.dart';

class ProjectScreen extends StatelessWidget {
  void _showAddProjectDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Proyecto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del proyecto'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final String name = nameController.text.trim();
                final String description = descriptionController.text.trim();
                if (name.isNotEmpty && description.isNotEmpty) {
                  context.read<ProjectCubit>().createProject(name, description);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<ProjectCubit>().loadProjects();
    context.read<AuthCubit>().getUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trello's Competency"),
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
                if (authState is AuthLoading) {
                return IconButton(
                  icon: const Icon(Icons.person, color: Colors.grey),
                  onPressed: () => {},
                );
                } else if (authState is AuthLoggedIn) {
                final User user = authState.user; 
                return IconButton(
                  icon: user.profile_image != null && user.profile_image!.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(user.profile_image!))
                      : CircleAvatar(
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                  onPressed: () => Dialogs().showUserDialog(context),
                );
              } else if (authState is AuthError) {
                return IconButton(
                  icon: const Icon(Icons.error, color: Colors.red),
                  onPressed: () {},
                );
              }
              return IconButton(
                icon: const Icon(Icons.verified_user, color: Colors.red),
                onPressed: () {},
              );
            },
          ),
        ],
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, authState) {
          if (authState is AuthLoggedOut) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (route) => false);
          }
        },
        child: BlocBuilder<ProjectCubit, ProjectState>(
          builder: (context, state) {
            if (state is ProjectLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProjectLoaded) {
              state.projects.sort((a, b) =>
                  a.name.toLowerCase().compareTo(b.name.toLowerCase()));
              return ProjectList(projects: state.projects);
            } else if (state is ProjectError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text("No hay proyectos disponibles."));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
