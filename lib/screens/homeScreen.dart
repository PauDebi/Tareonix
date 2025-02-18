import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/models/User.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/provider/project_cubit.dart';
import 'package:taskly/screens/SignUp_SignIn/entryDialog.dart';
import 'package:taskly/screens/projectScreen.dart';

class HomeScreen extends StatelessWidget {
  final User? user;

  const HomeScreen({Key? key, this.user}) : super(key: key);


  void _showLoginDialog(BuildContext context) {
    if (user != null) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PopScope(
          canPop: false,
          child: const EntryDialog(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Proyecto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre del proyecto'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final String name = nameController.text.trim();
                final String description = descriptionController.text.trim();
                if (name.isNotEmpty && description.isNotEmpty) {
                  context.read<ProjectCubit>().createProject(name, description);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _showUserDialog(BuildContext context, User user) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Perfil de Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           GestureDetector(
              //onTap: () => _pickImage(context, user),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: user.imageUrl != null && user.imageUrl!.isNotEmpty
                    ? NetworkImage(user.imageUrl!)
                    : null,
                child: user.imageUrl == null || user.imageUrl!.isEmpty
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Text("Nombre: ${user.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Email: ${user.email}"),
            Text("Fecha de Creacion: ${user.createdAt}")
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.of(context).pop(); // Cerrar el diálogo
              _showLoginDialog(context);
            },
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    // Verifica si el usuario está logueado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthLoggedIn) {
        _showLoginDialog(context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trello's Competency"),
        actions: [
          if (user != null)
            IconButton(
              icon: user!.imageUrl != null
            ? CircleAvatar(backgroundImage: NetworkImage(user!.imageUrl!))
            : CircleAvatar(
                child: Text(
            user!.name[0].toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              onPressed: () {
                _showUserDialog(context, user!);
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context),
        child: const Icon(Icons.add),
      ),
      body: ProjectScreen(), // Aquí conectamos con ProjectScreen
    );
  }
}