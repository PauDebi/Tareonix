import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskly/models/Project.dart';

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
  /*
// Esta es una función asincrónica que agrega un usuario a un proyecto usando su email.
Future<void> addUserToProjectByEmail(String projectId, String email) async {
  // Se obtiene el token de autenticación desde el almacenamiento seguro.
  final token = await secureStorage.read(key: "token");

  // Si no se encuentra un token, se emite un error indicando que no se encontró un token de autenticación.
  if (token == null) {
    emit(ProjectError("No se encontró un token de autenticación."));
    return;
  }

  try {
    // 1. Obtener el ID del usuario usando su email.
    final userResponse = await http.get(
      // Se hace una solicitud GET a la API para obtener el usuario con el email proporcionado.
      // ***Falta esta solicitud en la API***
      Uri.parse("$baseUrl/users?email=$email"),
      headers: {
        // Se envía el token de autorización en los encabezados de la solicitud.
        "Authorization": "Bearer $token",
      },
    );

    // Si la respuesta no es 200 (OK), significa que no se encontró al usuario.
    if (userResponse.statusCode != 200) {
      emit(ProjectError("Usuario no encontrado."));
      return;
    }

    // Si se encuentra al usuario, se decodifica la respuesta JSON para obtener los datos del usuario.
    final userData = jsonDecode(userResponse.body);
    // Se extrae el ID del usuario.
    final userId = userData["id"];

    // 2. Agregar el usuario al proyecto usando su ID.
    final addUserResponse = await http.post(
      // Se hace una solicitud POST a la API para agregar el usuario al proyecto.
      Uri.parse("$baseUrl/$projectId/add-user"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      // El cuerpo de la solicitud contiene el ID del usuario que se va a agregar al proyecto.
      body: jsonEncode({"user_id": userId}),
    );

    // Si la respuesta es 201 (Creado), el usuario se agregó correctamente al proyecto.
    if (addUserResponse.statusCode == 201) {
      emit(ProjectUserAdded("Usuario añadido correctamente."));
      // Se refrescan los proyectos para reflejar los cambios.
      await refreshProjects();
    } 
    // Si la respuesta es 400, significa que el usuario ya es miembro del proyecto.
    else if (addUserResponse.statusCode == 400) {
      emit(ProjectError("El usuario ya es miembro del proyecto."));
    } 
    // Si la respuesta es 403, significa que no tienes permisos para agregar usuarios al proyecto.
    else if (addUserResponse.statusCode == 403) {
      emit(ProjectError("No tienes permisos para añadir usuarios a este proyecto."));
    } 
    // Si ocurre cualquier otro error, se emite un error general.
    else {
      emit(ProjectError("Error al añadir el usuario al proyecto."));
    }
  } catch (e) {
    // Si ocurre un error al procesar la solicitud, se emite un mensaje de error.
    emit(ProjectError("Error al procesar la solicitud."));
  }
}

*/

}
