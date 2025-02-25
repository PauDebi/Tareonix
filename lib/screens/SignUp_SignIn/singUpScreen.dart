import 'package:Tareonix/Palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Tareonix/provider/auth_cubit.dart';
import 'package:Tareonix/widgets/TextField.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        title: const Text("Registrarse", style: TextStyle(color: Palette.titleTextColor)),
        backgroundColor: Palette.appBarColor,
        iconTheme: const IconThemeData(color: Palette.iconColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: nameController,
              hint: 'Nombre',
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: emailController,
              hint: 'Correo Electrónico',
              keyboardType: 'email',
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: passwordController,
              isPassword: true,
              hint: 'Contraseña',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Palette.cardColor,
                foregroundColor: Palette.textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                final String name = nameController.text.trim();
                final String email = emailController.text.trim();
                final String password = passwordController.text.trim();

                if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
                  await context.read<AuthCubit>().signUp(name, email, password);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario registrado correctamente, se ha enviado un correo de verificación')),
                  );
                  Navigator.of(context).pushReplacementNamed('/login');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, rellene todos los campos')),
                  );
                }
              },
              child: const Text(
                'Registrarse',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}