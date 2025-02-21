import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/models/Project.dart';
import 'package:taskly/models/User.dart';
import 'package:taskly/provider/project_cubit.dart';
import 'package:taskly/provider/auth_cubit.dart';

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
    void _showUserDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is AuthLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (authState is AuthLoggedIn) {
                final user = authState.user;
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Center(
                    child: Text('Perfil de Usuario',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => context.read<AuthCubit>().updateProfileImage(),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: user.profile_image != null &&
                                  user.profile_image!.isNotEmpty
                              ? NetworkImage(user.profile_image!)
                              : null,
                          child: user.profile_image == null ||
                                  user.profile_image!.isEmpty
                              ? const Icon(Icons.camera_alt,
                                  size: 50, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(user.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(user.email,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 14)),
                      const SizedBox(height: 10),
                      Text("Fecha de Creación:",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        "${user.createdAt.day.toString().padLeft(2, '0')}-"
                        "${user.createdAt.month.toString().padLeft(2, '0')}-"
                        "${user.createdAt.year}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  actions: [
                    Column(
                      children: [
                        Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            context.read<AuthCubit>().logout();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cerrar sesión',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cerrar',
                                style: TextStyle(fontSize: 16, color: Colors.blue)),
                          ),
                        ),
                      ]
                    ),
                  ],
                );
              } else if (authState is AuthError) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('Error',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  content: Text(authState.errorMessage,
                      style: const TextStyle(fontSize: 16)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar',
                          style: TextStyle(fontSize: 16, color: Colors.blue)),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink(); // Estado por defecto vacío
            },
          );
        },
      );
    }
    

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
                  onPressed: () => _showUserDialog(context),
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

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProjectCubit>().refreshProjects();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: state.projects.length,
                  itemBuilder: (context, index) {
                    final Project project = state.projects[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.folder, color: Colors.white),
                        ),
                        title: Text(
                          project.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          project.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.grey),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed('/projectDetails', arguments: project.id);
                        },
                      ),
                    );
                  },
                ),
              );
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
