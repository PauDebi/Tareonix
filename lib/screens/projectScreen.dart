import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/models/Project.dart';
import 'package:taskly/provider/project_cubit.dart';

class ProjectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Proyectos")),
      body: BlocProvider(
        create: (context) => ProjectCubit()..loadProjects(),
        child: BlocBuilder<ProjectCubit, ProjectState>(
          builder: (context, state) {
            if (state is ProjectLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ProjectLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProjectCubit>().refreshProjects();
                },
                child: ListView.builder(
                  itemCount: state.projects.length,
                  itemBuilder: (context, index) {
                    final Project project = state.projects[index];
                    return ListTile(
                      title: Text(project.name),
                      subtitle: Text(project.description),
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
      ),
    );
  }
}
