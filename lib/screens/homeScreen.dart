import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/screens/SignUp_SignIn/entryDialog.dart';

class HomeScreen extends StatelessWidget {
  final String? userImageUrl; // URL de imagen de usuario opcional
  final String userName;

  HomeScreen({this.userImageUrl, required this.userName, Key? key}) : super(key: key);


  void _showLoginDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false, // Bloquea el cierre al tocar fuera
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PopScope(
          canPop: false, // Bloquea el botón de retroceso
          child: const EntryDialog(), // Usa el EntryDialog
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // Empieza desde abajo
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Después de construir el widget, comprobamos si el usuario está logueado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthLoggedIn) {
        _showLoginDialog(context);
      }
    });

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String displayUserName = "Usuario";
        String? displayUserImageUrl;

        if (state is AuthLoggedIn) {
          displayUserName = state.userName;
          displayUserImageUrl = state.userImageUrl;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Trello's Competency"),
            actions: [
              IconButton(
                icon: displayUserImageUrl?.isNotEmpty == true
                    ? CircleAvatar(backgroundImage: NetworkImage(displayUserImageUrl!))
                    : CircleAvatar(
                        child: Text(
                          displayUserName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                onPressed: () {
                  print("Usuario clickeado");
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
