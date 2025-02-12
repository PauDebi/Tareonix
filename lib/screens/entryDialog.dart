import 'package:flutter/material.dart';
import 'package:taskly/screens/SignUp_SignIn/Access.dart';

class EntryDialog extends StatelessWidget {
  const EntryDialog({super.key});

  void _showSignUpSignInForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SignUpSignInForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Let's organize the things.",
                  style: TextStyle(fontSize: 16, color: Colors.white70, decoration: TextDecoration.none),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => _showSignUpSignInForm(context),
                  child: const Text('Sign up'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 10, 10, 10),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => _showSignUpSignInForm(context),
                  child: const Text('Log in'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 10, 10, 10),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    // Acción para Sign in con Google
                  },
                  child: const Text('Sign in with Google'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
