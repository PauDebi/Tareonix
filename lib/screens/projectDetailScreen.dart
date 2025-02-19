import 'package:flutter/material.dart';
import 'package:taskly/models/Project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Project? project = ModalRoute.of(context)!.settings.arguments as Project?;

    if (project == null) {
    return Scaffold(
      appBar: AppBar(title: const Text("Error")),
      body: const Center(child: Text("No se encontró el proyecto")),
    );
  }

    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              project.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            const Text(
              "Tareas del Proyecto",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Text("Aquí se mostrarán las tareas (pendiente de implementación)."),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
