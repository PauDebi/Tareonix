import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:taskly/models/Project.dart';
import 'package:taskly/models/Task.dart';
import 'package:taskly/provider/task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskLoading());

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final String baseUrl = "http://worldgames.es/api/tasks/";

  // Función para agregar una tarea
  Future<void> addTask(String name, String description, Project project) async {
    emit(TaskLoading());

    final token = await secureStorage.read(key: "token");
    if (token == null) {
      emit(TaskError("No hay token de autenticación"));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(baseUrl + project.id.toString()),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "description": description,
        }),
      );

      if (response.statusCode == 200) {
        // Recargar tareas después de agregar una nueva
        await fetchTasks(project);
      } else {
        emit(TaskError("Error al agregar la tarea (Código: ${response.statusCode})"));
      }
    } catch (e) {
      emit(TaskError("Error de conexión: $e"));
    }
  }

  // Función para obtener las tareas del proyecto
  Future<void> fetchTasks(Project project) async {
    emit(TaskLoading());

    final token = await secureStorage.read(key: "token");
    if (token == null) {
      emit(TaskError("No hay token de autenticación"));
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(baseUrl + project.id.toString()),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('tasks') && data['tasks'] is List) {
          List<Task> fetchedTasks = (data['tasks'] as List)
              .map((json) => Task.fromJson(json))
              .toList();

          emit(TaskLoaded(fetchedTasks)); // Emitimos el estado con las tareas cargadas
        } else {
          emit(TaskError("Formato de respuesta inesperado"));
        }
      } else {
        emit(TaskError("Error al cargar las tareas (Código: ${response.statusCode})"));
      }
    } catch (e) {
      emit(TaskError("Error de conexión: $e"));
    }
  }
}
