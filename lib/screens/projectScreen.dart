import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/models/Project.dart';
import 'package:taskly/provider/project_cubit.dart';

class ProjectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read<ProjectCubit>().loadProjects();
    return Scaffold(
      appBar: AppBar(title: Text("Proyectos")),
      body: BlocBuilder<ProjectCubit, ProjectState>(
        builder: (context, state) {
          if (state is ProjectLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProjectLoaded) {
            // Ordenamos los proyectos por nombre alfabéticamente sin distinguir mayúsculas
            state.projects.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProjectCubit>().refreshProjects();
              },
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: state.projects.length,
                itemBuilder: (context, index) {
                  final Project project = state.projects[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.folder, color: Colors.white),
                      ),
                      title: Text(
                        project.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        project.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      onTap: () {
                        // Acción al tocar el proyecto
                      },
                    ),
                  );
                },
              ),
            );
          } else if (state is ProjectError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text("No hay proyectos disponibles."));
          }
        },
      ),
    );
  }
}