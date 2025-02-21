import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/models/Project.dart';
import 'package:taskly/provider/project_cubit.dart';

class ProjectList extends StatelessWidget {
  final List<Project> projects;
  const ProjectList({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return 
      RefreshIndicator(
        onRefresh: () async {
          context.read<ProjectCubit>().refreshProjects();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final Project project = projects[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.folder, color: Colors.white),
                ),
                title: Text(
                  project.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/projectDetails', arguments: project.id);
                },
              ),
            );
          },
        ),
      );
  }
}