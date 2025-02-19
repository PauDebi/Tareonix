import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/widgets/TextField.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar Sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: emailController,
              keyboardType: 'email',
              hint: 'Correo Electrónico',
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: passwordController,
              hint: 'Contraseña',
              isPassword: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String email = emailController.text.trim();
                final String password = passwordController.text.trim();

                if (email.isNotEmpty && password.isNotEmpty) {
                  await context.read<AuthCubit>().logIn(email, password);
                  if (context.read<AuthCubit>().state is AuthLoggedIn) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/project',
                      (Route<dynamic> route) => false
                    );
                  }
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, rellene todos los campos')),
                  );
                }
              },
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}