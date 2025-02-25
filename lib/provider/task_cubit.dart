import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:Tareonix/models/Project.dart';
import 'package:Tareonix/models/Task.dart';
import 'package:Tareonix/models/User.dart';
import 'package:Tareonix/provider/task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskLoading());

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final String baseUrl = "http://worldgames.es/api/tasks/";

  // Función para agregar una tarea
  Future<void> addTask(String name, String? description, Project project) async {
    description ??= "";
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

  Future<void> updateTask(Task task, Project project) async {

    final token = await secureStorage.read(key: "token");
    if (token == null) {
      emit(TaskError("No hay token de autenticación"));
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(baseUrl + task.id.toString()),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": task.name,
          "description": task.description,
          "status": task.status,
        }),
      );

      if (response.statusCode == 200) {
        fetchTasks(project);
      } else {
        emit(TaskError("Error al actualizar la tarea (Código: ${response.statusCode})"));
      }
    } catch (e) {
      emit(TaskError("Error de conexión: $e"));
    }
  }

  Future<void> deleteTask(Task task, Project project) async {
    emit(TaskLoading());

    final token = await secureStorage.read(key: "token");
    if (token == null) {
      emit(TaskError("No hay token de autenticación"));
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(baseUrl + task.id.toString()),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        fetchTasks(project);
      } else {
        emit(TaskError("Error al actualizar la tarea (Código: ${response.statusCode})"));
      }
    } catch (e) {
      emit(TaskError("Error de conexión: $e"));
    }
  }

  Future<void> assignTaskTo(User user, Task task, Project project) async {
    emit(TaskLoading());
    final token = await secureStorage.read(key: "token");
    if (token == null) {
      emit(TaskError("No hay token de autenticación"));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(baseUrl + "assign-user-to/"+ task.id),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "user_id": user.id,
        }),
      );

      if (response.statusCode == 200) {
        fetchTasks(project);
      } else {
        emit(TaskError("Error al asignar la tarea (Código: ${response.statusCode})"));
      }
    } catch (e) {
      emit(TaskError("Error de conexión: $e"));
    }
  }

  Future<void> unassignTask(Task task, Project project) async {
    emit(TaskLoading());
    final token = await secureStorage.read(key: "token");
    if (token == null) {
      emit(TaskError("No hay token de autenticación"));
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(baseUrl + "unassign-user-from/"+ task.id),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "user_id": task.assignedUserId,
        }),
      );

      if (response.statusCode == 200) {
        fetchTasks(project);
      } else {
        emit(TaskError("Error al desasignar la tarea (Código: ${response.statusCode}), ${response.body}"));
      }
    } catch (e) {
      emit(TaskError("Error de conexión: $e"));
    }

  }
}
