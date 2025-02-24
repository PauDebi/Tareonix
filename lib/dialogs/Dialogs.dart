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
                  backgroundColor: Palette.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Center(
                    child: Text('Perfil de Usuario',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Palette.titleTextColor)),
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
                            fontWeight: FontWeight.bold, fontSize: 18, color: Palette.titleTextColor)),
                      Text(user.email,
                          style: TextStyle(
                              color: Palette.textColor, fontSize: 14,)),
                      const SizedBox(height: 10),
                      Text("Fecha de Creación:",
                          style: const TextStyle(
                            color: Palette.textColor,
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        "${user.createdAt.day.toString().padLeft(2, '0')}-"
                        "${user.createdAt.month.toString().padLeft(2, '0')}-"
                        "${user.createdAt.year}",
                        style: TextStyle(color: Palette.textColor),
                      ),
                    ],
                  ),
                  actions: [
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () => showEditUserDialog(context, user),
                            child: const Text('Cambiar datos',
                                style: TextStyle(fontSize: 16, color: Palette.textColor)),
                          ),
                        ),
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
                                style: TextStyle(fontSize: 16, color: Palette.textColor)),
                          ),
                        ),
                      ]
                    ),
                  ],
                );
              } else if (authState is AuthError) {
                return AlertDialog(
                  backgroundColor: Palette.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('Error',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Palette.textColor)),
                  content: Text(authState.errorMessage,
                      style: const TextStyle(fontSize: 16)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar',
                          style: TextStyle(fontSize: 16, color: Palette.textColor)),
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
      final User? mainUser = await context.read<AuthCubit>().getUser();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Palette.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Center(
              child: Text('Perfil de Usuario',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Palette.titleTextColor)),
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
                        fontWeight: FontWeight.bold, fontSize: 18, color: Palette.titleTextColor)),
                Text(user.email,
                    style: TextStyle(
                        color: Palette.textColor, fontSize: 14)),
                const SizedBox(height: 10),
                Text("Fecha de Creación:",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14, color: Palette.titleTextColor)),
                Text(
                  "${user.createdAt.day.toString().padLeft(2, '0')}-"
                  "${user.createdAt.month.toString().padLeft(2, '0')}-"
                  "${user.createdAt.year}",
                  style: TextStyle(color: Palette.textColor),
                ),
              ],
            ),
            actions: [
              Column(
                children: [ 
                  (mainUser!.id == user.id && mainUser.id != project.leaderId) && showExit ?
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
                        Navigator.of(context).pushNamedAndRemoveUntil('/project' , (route) => false);
                      },
                      child:
                        const Text('Salir del proyecto',
                            style: TextStyle(
                                fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold))
                    ),
                  ): (user.id != mainUser.id && canEdit)?Align(
                    alignment: Alignment.center,
                    child: 
                    TextButton(
                      onPressed: (){
                        List<Task> tasks = context.read<TaskCubit>().state is TaskLoaded ? (context.read<TaskCubit>().state as TaskLoaded).tasks : [];
                        if (tasks.length > 0) {
                          for (int i = 0; i < tasks.length; i++) {
                            if (tasks[i].assignedUserId == user.id) {
                              context.read<TaskCubit>().unassignTask(tasks[i], project);
                            }
                          }
                        }
                        context.read<ProjectCubit>().removeMember(user, project, context);
                        Navigator.of(context).pushNamedAndRemoveUntil('/project' , (route) => false);
                      }, 
                      child:   
                        const Text('Eliminar del proyecto',
                          style: TextStyle(
                            fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),),
                  ): const SizedBox.shrink(),
                  showExit ? const SizedBox.shrink() :
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () { 
                        context.read<TaskCubit>().unassignTask(task!, project);
                        Navigator.of(context).pop();
                        },
                      child: const Text('Desasingar usuario',
                          style: TextStyle(fontSize: 16, color: Palette.textColor)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar',
                          style: TextStyle(fontSize: 16, color: Palette.textColor)),
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
          backgroundColor: Palette.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Eliminar Tarea',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Palette.textColor)),
          content: const Text('¿Estás seguro de que deseas eliminar esta tarea?',
              style: TextStyle(fontSize: 16, color: Palette.textColor)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar',
                  style: TextStyle(fontSize: 16, color: Palette.textColor)),
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
          backgroundColor: Palette.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Asignar Tarea',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Palette.textColor)),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: project.members.length,
              itemBuilder: (context, index) {
                final User user = project.members[index]!;
                return ListTile(
                  title: Text(user.name, style: TextStyle(color: Palette.textColor)),
                  leading: CircleAvatar(
                    backgroundImage: user.profile_image != null &&
                            user.profile_image!.isNotEmpty
                        ? NetworkImage(user.profile_image!)
                        : null,
                    child: user.profile_image == null || user.profile_image!.isEmpty
                        ? Text(user.name[0].toUpperCase(),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Palette.textColor))
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
          backgroundColor: Palette.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Editar Tarea',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Palette.textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre de la tarea', labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Palette.textColor),
              ),
              const SizedBox(height: 10),
              TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción de la tarea', labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Palette.textColor),
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

  void showEditProjectDialog(BuildContext context, Project project){
    final TextEditingController nameController = TextEditingController(text: project.name);
    final TextEditingController descriptionController = TextEditingController(text: project.description);
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Palette.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Editar Tarea',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Palette.textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre de la tarea', labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Palette.textColor),
              ),
              const SizedBox(height: 10),
              TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción de la tarea', labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Palette.textColor),
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
                project.name = nameController.text;
                project.description = descriptionController.text;
                context.read<ProjectCubit>().updateProject(context, project);
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


  void showEditUserDialog(BuildContext context, User user) {
    final TextEditingController nameController = TextEditingController(text: user.name);
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Palette.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Editar Usuario',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Palette.textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: user.name, labelStyle: TextStyle(color: Colors.white) ,hintText: 'Nombre'),
                style: const TextStyle(color: Palette.textColor),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: '', labelStyle: TextStyle(color: Colors.white), hintText: 'Contraseña'),
                style: const TextStyle(color: Palette.textColor),
                obscureText: true,
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
                if (!passwordController.text.isEmpty && passwordController.text.length < 8) {
                  SnackBar(content: Text('La contraseña debe tener al menos 8 caracteres (si no desea cambiarla, déjela en blanco)'));
                  return;
                }
                context.read<AuthCubit>().updateUser(nameController.text, passwordController.text, user);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar',
                  style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}