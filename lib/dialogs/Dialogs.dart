import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/models/Project.dart';
import 'package:taskly/models/Task.dart';
import 'package:taskly/models/User.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/provider/project_cubit.dart';
import 'package:taskly/provider/task_cubit.dart';
import 'package:taskly/provider/task_state.dart';

class Dialogs {
  void showUserDialog(BuildContext context) {
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

    void showMemberDialog(BuildContext context, User user, bool canEdit, bool showExit, Project project ,Task? task) async {
      final User? mainUserer = await context.read<AuthCubit>().getUser();
      showDialog(
        context: context,
        builder: (BuildContext context) {
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
              CircleAvatar(
                  radius: 50,
                  backgroundImage: user.profile_image != null &&
                          user.profile_image!.isNotEmpty
                      ? NetworkImage(user.profile_image!)
                      : null,
                  child: user.profile_image == null || user.profile_image!.isEmpty
                      ? const Icon(Icons.camera_alt,
                          size: 50, color: Colors.grey)
                      : null,
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
                children: [(canEdit || mainUserer!.id == user.id ) && showExit? 
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        List<Task> tasks = context.read<TaskCubit>().state is TaskLoaded ? (context.read<TaskCubit>().state as TaskLoaded).tasks : [];
                        if (tasks.length > 0) {
                          for (int i = 0; i < tasks.length; i++) {
                            if (tasks[i].assignedUserId == user.id) {
                              context.read<TaskCubit>().unassignTask(tasks[i], project);
                            }
                          }
                        }
                        context.read<ProjectCubit>().removeMember(user, project, context);
                        Navigator.of(context).pop();
                      },
                      child: mainUserer!.id == user.id ?
                        const Text('Salir del proyecto',
                            style: TextStyle(
                                fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold))
                      :
                        const Text('Eliminar del proyecto',
                            style: TextStyle(
                                fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                      
                    ),
                  ): 
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () { 
                        context.read<TaskCubit>().unassignTask(task!, project);
                        },
                      child: const Text('Desasingar usuario',
                          style: TextStyle(fontSize: 16, color: Colors.blue)),
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
        },
      );
    }

  void showDeleteTaskDialog(BuildContext context, Task task, Project project) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Eliminar Tarea',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: const Text('¿Estás seguro de que deseas eliminar esta tarea?',
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar',
                  style: TextStyle(fontSize: 16, color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                context.read<TaskCubit>().deleteTask(task, project);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar',
                  style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void showAssignTaskDialog(BuildContext context, Project project, Task task){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Asignar Tarea',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: project.members.length,
              itemBuilder: (context, index) {
                final User user = project.members[index]!;
                return ListTile(
                  title: Text(user.name),
                  leading: CircleAvatar(
                    backgroundImage: user.profile_image != null &&
                            user.profile_image!.isNotEmpty
                        ? NetworkImage(user.profile_image!)
                        : null,
                    child: user.profile_image == null || user.profile_image!.isEmpty
                        ? Text(user.name[0].toUpperCase(),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                        : null,
                  ),
                  onTap: () {
                    context.read<TaskCubit>().assignTaskTo(user, task, project);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      }
    );
  }

  void showEditTaskDialog(BuildContext context, Task task, Project project){
    final TextEditingController nameController = TextEditingController(text: task.name);
    final TextEditingController descriptionController = TextEditingController(text: task.description);
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Editar Tarea',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre de la tarea'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción de la tarea'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar',
                  style: TextStyle(fontSize: 16, color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                task.name = nameController.text;
                task.description = descriptionController.text;
                context.read<TaskCubit>().updateTask(task, project);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar',
                  style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

}