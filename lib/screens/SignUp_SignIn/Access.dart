import 'package:flutter/material.dart';
import 'package:taskly/widgets/TextField.dart';

class SignUpSignInForm extends StatelessWidget {
  const SignUpSignInForm({super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.7, // Ocupa el 70% de la pantalla
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 27, 27, 27),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            CustomTextField(hint: "Name"),
            const SizedBox(height: 10),
            CustomTextField(hint: "Email"),
            const SizedBox(height: 10),
            CustomTextField(hint: "Password", isPassword: true),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                // Acción para iniciar sesión o registrarse
              },
              child: const Text('Continue'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context), // Cierra el modal
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}