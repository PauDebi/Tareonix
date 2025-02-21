import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/models/User.dart';
import 'package:taskly/provider/auth_cubit.dart';

class Dialogs {
  void showUserDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is AuthLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (authState is AuthLoggedIn) {
                final user = authState.user;
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Center(
                    child: Text('Perfil de Usuario',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => context.read<AuthCubit>().updateProfileImage(),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: user.profile_image != null &&
                                  user.profile_image!.isNotEmpty
                              ? NetworkImage(user.profile_image!)
                              : null,
                          child: user.profile_image == null ||
                                  user.profile_image!.isEmpty
                              ? const Icon(Icons.camera_alt,
                                  size: 50, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(user.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(user.email,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 14)),
                      const SizedBox(height: 10),
                      Text("Fecha de Creación:",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        "${user.createdAt.day.toString().padLeft(2, '0')}-"
                        "${user.createdAt.month.toString().padLeft(2, '0')}-"
                        "${user.createdAt.year}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  actions: [
                    Column(
                      children: [
                        Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            context.read<AuthCubit>().logout();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cerrar sesión',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cerrar',
                                style: TextStyle(fontSize: 16, color: Colors.blue)),
                          ),
                        ),
                      ]
                    ),
                  ],
                );
              } else if (authState is AuthError) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('Error',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  content: Text(authState.errorMessage,
                      style: const TextStyle(fontSize: 16)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar',
                          style: TextStyle(fontSize: 16, color: Colors.blue)),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink(); // Estado por defecto vacío
            },
          );
        },
      );
    }

    void showMemberDialog(BuildContext context, User user, bool canEdit) async {
      final User? mainUserer = await context.read<AuthCubit>().getUser();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Center(
              child: Text('Perfil de Usuario',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              CircleAvatar(
                  radius: 50,
                  backgroundImage: user.profile_image != null &&
                          user.profile_image!.isNotEmpty
                      ? NetworkImage(user.profile_image!)
                      : null,
                  child: user.profile_image == null || user.profile_image!.isEmpty
                      ? const Icon(Icons.camera_alt,
                          size: 50, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 15),
                Text(user.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                Text(user.email,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 10),
                Text("Fecha de Creación:",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  "${user.createdAt.day.toString().padLeft(2, '0')}-"
                  "${user.createdAt.month.toString().padLeft(2, '0')}-"
                  "${user.createdAt.year}",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            actions: [
              Column(
                children: [ canEdit || mainUserer!.id == user.id ? 
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        //context.read<ProjectCubit>().removeMember(user.id);
                        Navigator.of(context).pop();
                      },
                      child: mainUserer!.id == user.id ?
                        const Text('Salir del proyecto',
                            style: TextStyle(
                                fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold))
                      :
                        const Text('Eliminar del proyecto',
                            style: TextStyle(
                                fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                      
                    ),
                  ): Placeholder(),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar',
                          style: TextStyle(fontSize: 16, color: Colors.blue)),
                    ),
                  ),
                ]
              ),
            ],
          );
        },
      );
    }

}