import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskly/models/Project.dart';
import 'package:taskly/models/Task.dart';
import 'package:taskly/models/User.dart';
import 'package:taskly/provider/task_cubit.dart';
import 'package:taskly/provider/task_state.dart';

part 'project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final String baseUrl = "http://worldgames.es/api/projects";
  List<Project>? projects = [];

  ProjectCubit() : super(ProjectInitial());


  /// Cargar la lista de proyectos desde la API.
  Future<void> loadProjects() async {
    emit(ProjectLoading());

    print('loading projects');

    projects = await _fetchProjects();
    

    print('projects loaded');

    if (projects == null) {
      emit(ProjectError("Error al cargar los proyectos."));
      return;
    }
    emit(ProjectLoaded(projects: projects!));
  }

  Future<List<Project>?> _fetchProjects() async {

    final token = await secureStorage.read(key: "token");
    if (token == null) {
      return null;
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Verifica que la clave correcta es "projects"
      if (data.containsKey('projects') && data['projects'] is List) {
        List<dynamic> jsonList = data['projects']; // Extraemos la lista de proyectos
        return jsonList.map((json) => Project.fromJson(json)).toList();
      } else {
        throw Exception('Formato de respuesta inesperado');
      }
    } else {
      throw Exception('Error al cargar los proyectos');
    }
  }

    

  /// Crear un nuevo proyecto y recargar la lista.
  Future<void> createProject(String title, String description) async {
    final token = await secureStorage.read(key: "token");
    if (token == null) {
      emit(ProjectError("No se encontró un token de autenticación."));
      return;
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": title,
        "description": description,
      }),
    );

    print (response.statusCode);
    

    if (response.statusCode == 201) {
      print('Proyecto creado con éxito.');
      // Vuelve a cargar la lista de proyectos para reflejar los cambios.
      await refreshProjects();
    } else {
      emit(ProjectError("Error al crear el proyecto."));
    }
  }
  void moveProject(int oldIndex, int newIndex) {
    if (projects == null || projects!.isEmpty) return;

    final project = projects!.removeAt(oldIndex);
    projects!.insert(newIndex, project);

    // Emitir un nuevo estado con la lista actualizada
    emit(ProjectLoaded(projects: List.from(projects!)));
  }


  /// Permite recargar los proyectos manualmente con un pull-to-refresh.
  Future<void> refreshProjects() async {
    await loadProjects();
  }

  /// Eliminar un proyecto y recargar la lista.
  Future<void> deleteProject(Project project) async {
    final token = await secureStorage.read(key: "token");
    if (token == null) {
      emit(ProjectError("No se encontró un token de autenticación."));
      return;
    }

    final response = await http.delete(
      Uri.parse("$baseUrl/${project.id}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      print('Proyecto eliminado con éxito.');
      emit(ProjectLoading()); // Emite un estado de carga mientras se elimina el proyecto
      // Filtrar el proyecto eliminado de la lista local
      projects?.removeWhere((p) => p.id == project.id);

      // Emite el estado actualizado con la lista de proyectos
      emit(ProjectLoaded(projects: List.from(projects!))); // Emite los proyectos actualizados
    } else if (response.statusCode == 403) {
      emit(ProjectError("No tienes permiso para eliminar este proyecto."));
    } else if (response.statusCode == 404) {
      emit(ProjectError("El proyecto no fue encontrado."));
    } else {
      emit(ProjectError("Error al eliminar el proyecto."));
    }
  }
    
  // Esta es una función asincrónica que agrega un usuario a un proyecto usando su email.
  Future<void> addUserToProjectByEmail(String projectId, String email) async {
    final token = await secureStorage.read(key: "token");
    if (token == null) {
      emit(ProjectError("No se encontró un token de autenticación."));
      return;
    }

    try {
      print("comienza la solicitud");
      // Ahora enviamos el email
      final addUserResponse = await http.post(
        Uri.parse("$baseUrl/$projectId/add-user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"user_email": email}),
      );

      if (addUserResponse.statusCode == 201) {
        print('Usuario añadido correctamente.');
        refreshProjects();
        emit(ProjectUserAdded("Usuario añadido correctamente."));
        await refreshProjects(); // Refrescar la lista de proyectos si es necesario
      } else if (addUserResponse.statusCode == 400) {
        emit(ProjectError("El usuario ya es miembro del proyecto."));
      } else if (addUserResponse.statusCode == 403) {
        emit(ProjectError("No tienes permisos para añadir usuarios a este proyecto."));
      } else {
        emit(ProjectError("Error al añadir el usuario al proyecto."));
      }
    } catch (e) {
      emit(ProjectError("Error al procesar la solicitud."));
    }
  }

  void removeMember(User user, Project project, BuildContext context) async {
    final taskState = context.read<TaskCubit>();
    final List<Task> tasks = taskState is TaskLoaded ? taskState.state.tasks : [];
    if (!tasks.isEmpty) {
      for (Task task in tasks) {
        if (task.assignedUserId != null) {
          
        }
      }
    }
    emit(ProjectLoading());
    final token = await secureStorage.read(key: "token");
    if (token == null) {
      emit(ProjectError("No se encontró un token de autenticación."));
      return;
    }

    final response = await http.delete(
      Uri.parse("$baseUrl/${project.id}/remove-user"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"user_email": user.email}),
    );

    if (response.statusCode == 200) {
      print('Usuario eliminado correctamente.');
      await loadProjects();
    } else if (response.statusCode == 403) {
      emit(ProjectError("No tienes permisos para eliminar usuarios de este proyecto."));
    } else {
      emit(ProjectError("Error al eliminar el usuario del proyecto."));
    }
  }

    Future<void> updateProject(BuildContext context, Project project) async {
    
    final token = await secureStorage.read(key: "token");
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: No se encontró el token de autenticación")),
      );
      return;
    }

    final response = await http.put(
      Uri.parse("http://worldgames.es/api/projects/${project.id}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": project.name,
        "description": project.description,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Proyecto actualizado exitosamente")),
      );
      await loadProjects();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar el proyecto")),
      );
    }
  }

}
