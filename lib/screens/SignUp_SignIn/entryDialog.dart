import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/screens/SignUp_SignIn/Access.dart';

class EntryDialog extends StatelessWidget {
  const EntryDialog({super.key});

  void _showSignUpSignInForm(BuildContext context, AuthState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (state is AuthShowSignUp) {
          return SignUpSignInForm(signUp: true);
        } else if (state is AuthShowLogIn) {
          return SignUpSignInForm(signUp: false);
        } else {
          return SignUpSignInForm(signUp: false); // Default
        }
      },
    );
  }

  /// Cierra los modales abiertos:
  void _closeDialogs(BuildContext context) {
    // Si se encuentra un bottom sheet (o cualquier ruta extra), se cierra.
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    // Se cierra el diálogo general.
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthShowSignUp || state is AuthShowLogIn) {
          _showSignUpSignInForm(context, state);
        } else if (state is AuthLoggedIn) {
          // Cuando se logea correctamente, se cierran ambos modales:
          _closeDialogs(context);
        }
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {}, // Evita que se cierre al tocar fuera
            child: Container(
              color: Colors.black26, // Oscurece el fondo
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 27, 27, 27),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome to Tareonix',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Let's organize the things.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => context.read<AuthCubit>().showSignUp(),
                    child: const Text('Sign up'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 10, 10, 10),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => context.read<AuthCubit>().showLogIn(),
                    child: const Text('Log in'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 10, 10, 10),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      context.read<AuthCubit>().showGoogleSignIn();
                    },
                    child: const Text('Sign in with Google'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
