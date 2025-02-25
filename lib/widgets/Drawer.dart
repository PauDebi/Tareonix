import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Tareonix/Palette.dart';
import 'package:Tareonix/dialogs/Dialogs.dart';
import 'package:Tareonix/models/Project.dart';
import 'package:Tareonix/models/User.dart';
import 'package:Tareonix/provider/project_cubit.dart';

class CustomDrawer extends StatelessWidget {
  final Project project;
  final User user;
  final bool isEditable;
  final context;
  
  const CustomDrawer({super.key, required this.project, required this.user, required this.isEditable, required this.context});

  @override
  Widget build(context) {
    return Drawer(
        backgroundColor: Palette.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(user.name),
              accountEmail: Text(user.email),
              currentAccountPicture: user.profile_image != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user.profile_image!),
                    )
                  : CircleAvatar(
                      child: Text(user.name[0].toUpperCase()),
              ),
              decoration: BoxDecoration(
                color: Palette.cardColor, // Cambia este color según tus necesidades
              ),
            ),
            // Usuarios
            ExpansionTile(
              title: Text('Usuarios', style: TextStyle(color: Palette.titleTextColor)),
              leading: Icon(Icons.people),
              children: <Widget>[
                // Lista de usuarios dentro del drawer
        ...project.members.map((member) => ListTile(
              leading: member!.profile_image != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(member.profile_image!),
                    )
                  : CircleAvatar(
                      child: Text(user.name[0].toUpperCase()),
              ),
              onTap: () => Dialogs().showMemberDialog(context, member, isEditable, true, project, null),
              title: Text(member.name, style: TextStyle(color: Palette.textColor)),
              )),
                ListTile(
                  leading: Icon(Icons.add, color: Palette.iconColor),
                  title: Text('Añadir usuario', style: TextStyle(color: Palette.textColor)),
                  onTap: () {
                    Navigator.pop(context); // Cierra el Drawer
                    _showAddUserDialog(context, project.id);
                  },
                ),
              ],
            ),
            // Detalles
            ListTile(
              title: Text('Detalles', style: TextStyle(color: Palette.titleTextColor)),
              leading: Icon(Icons.info),
                onTap: () {
                  Navigator.pop(context); // Cierra el Drawer
                  _showProjectDetails();
                },
            ),
            // Eliminar proyecto
            if (isEditable)
            ListTile(
              title: Text('Eliminar proyecto', style: TextStyle(color: Palette.titleTextColor)),
              leading: Icon(Icons.delete, color: Colors.red),
              onTap: () {
                context.read<ProjectCubit>().deleteProject(project);
                Navigator.pop(context); // Cierra el Drawer
                Navigator.pop(context); // Cierra la pantalla de detalles
              },
            ),
          ],
        ),
      );
  }

   void _showAddUserDialog(BuildContext context, String projectId) {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette.backgroundColor,
          title: Text("Añadir Usuario", style: TextStyle(color: Palette.textColor)),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: "Email del usuario", labelStyle: TextStyle(color: Palette.textColor)),
            style: TextStyle(color: Palette.textColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  context.read<ProjectCubit>().addUserToProjectByEmail(projectId, email);
                }
                Navigator.of(context).pop(); // Cerrar diálogo
              },
              child: Text("Añadir", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _showProjectDetails() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Palette.backgroundColor,
            title: Text(
              'Detalles del Proyecto',
              style: TextStyle(fontWeight: FontWeight.bold, color: Palette.textColor),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📌 Nombre: ${project.name}', style: TextStyle(fontSize: 16, color: Palette.textColor)),
                  SizedBox(height: 8),
                  Text('📝 Descripción: ${project.description}', style: TextStyle(fontSize: 14, color: Palette.textColor)),
                  SizedBox(height: 8),
                  Text('📅 Fecha de inicio: ${project.createdAt.day.toString().padLeft(2, '0')}-'
                      '${project.createdAt.month.toString().padLeft(2, '0')}-'
                      '${project.createdAt.year}', style: TextStyle(fontSize: 14, color: Palette.textColor)),
                  SizedBox(height: 12),
                  if (project.leaderId != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('👤 Creador del Proyecto:', style: TextStyle(fontWeight: FontWeight.bold, color: Palette.textColor)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: project.members
                                          .firstWhere((member) => member!.id == project.leaderId)
                                          ?.profile_image !=
                                      null
                                  ? NetworkImage(project.members
                                          .firstWhere((member) => member!.id == project.leaderId)
                                          !.profile_image!)
                                  : AssetImage('assets/default_avatar.png') as ImageProvider,
                            ),
                            SizedBox(width: 12),
                            Text(
                              project.members
                                  .firstWhere((member) => member!.id == project.leaderId)
                                  ?.name ?? 'Desconocido',
                              style: TextStyle(fontSize: 16, color: Palette.textColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              if (isEditable)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Dialogs().showEditProjectDialog(context, project);
                  },
                  child: Text('Editar', style: TextStyle(color: Colors.green)),
                ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar', style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        },
      );
    }
}