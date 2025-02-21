import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:taskly/models/Project.dart';
import 'package:taskly/models/Task.dart';
import 'package:taskly/provider/task_state.dart';


// Task cubit
class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskState(tasks: []));
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final String baseUrl = "http://worldgames.es/api/tasks/";

  addTask(String name, String descriptionm, Project project) async {
    final token = await secureStorage.read(key: "token");
    if (token == null) {
      fetchTasks(project);
      return;
    }

    final response = await http.post(
      Uri.parse(baseUrl + project.id.toString()), // Convertir ID a String
      headers: {
        "Content-Type": "application/json",
        "Authorization"
        : "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "description": descriptionm,
      }),
    );
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      print('Tarea creada');
      fetchTasks(project);
      return;
    } else if (response.statusCode == 500) {
      print('Error en el servidor');
      emit(TaskState(tasks: state.tasks));
      return;
    }

    fetchTasks(project);
  }

  Future<void> fetchTasks(Project project) async {
    final token = await secureStorage.read(key: "token");
    if (token == null) {
      emit(TaskState(tasks: [])); // Si no hay token, emitimos una lista vacía
      return;
    }

    final response = await http.get(
      Uri.parse(baseUrl + project.id.toString()), // Convertir ID a String
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      print('Cargo las tareas');
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey('tasks') && data['tasks'] is List) {
        List<Task> fetchedTasks = (data['tasks'] as List)
            .map((json) => Task.fromJson(json))
            .toList();

        emit(TaskState(tasks: fetchedTasks)); // Se emite el nuevo estado con las tareas
        print('Tareas cargadas');
      } else {
        emit(TaskState(tasks: [])); // En caso de error en la estructura de datos
        throw Exception('Formato de respuesta inesperado');
      }
    } else {
      emit(TaskState(tasks: [])); // En caso de error en la petición
      throw Exception('Error al cargar las tareas');
    }
  }

}