import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Tareonix/Palette.dart';
import 'package:Tareonix/models/Project.dart';
import 'package:Tareonix/provider/project_cubit.dart';

class ProjectList extends StatelessWidget {
  final List<Project> projects;
  ProjectList({super.key, required this.projects});

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProjectCubit>().refreshProjects();
      },
      child: Container(
        color: Palette.backgroundColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final Project project = projects[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/projectDetails', arguments: project.id);
              },
              child: FadeInWidget(
                child: Card(
                  color: Palette.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Palette.iconColor,
                          child: const Icon(Icons.work_outline, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Palette.titleTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                project.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Palette.textColor),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Creado: ${formatDate(project.createdAt)}",
                                style: TextStyle(fontSize: 12, color: Palette.textColor),
                              )
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FadeInWidget extends StatefulWidget {
  final Widget child;
  const FadeInWidget({Key? key, required this.child}) : super(key: key);

  @override
  _FadeInWidgetState createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
