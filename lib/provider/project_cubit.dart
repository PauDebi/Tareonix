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

  ProjectCubit() : super(ProjectInitial());

  /// Cargar la lista de proyectos desde la API.
  Future<void> loadProjects() async {
    emit(ProjectLoading());

    final token = await secureStorage.read(key: "token");
    if (token == null) {
      emit(ProjectError("No se encontró un token de autenticación."));
      return;
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      final List<Project> projects =
          responseData.map((data) => Project.fromJson(data)).toList();
      emit(ProjectLoaded(projects: projects));
    } else {
      emit(ProjectError("Error al cargar proyectos."));
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
        "title": title,
        "description": description,
      }),
    );

    if (response.statusCode == 201) {
      // Vuelve a cargar la lista de proyectos para reflejar los cambios.
      loadProjects();
    } else {
      emit(ProjectError("Error al crear el proyecto."));
    }
  }

  /// Permite recargar los proyectos manualmente con un pull-to-refresh.
  Future<void> refreshProjects() async {
    await loadProjects();
  }
}
