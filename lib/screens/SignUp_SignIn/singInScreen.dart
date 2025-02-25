import 'package:Tareonix/Palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Tareonix/provider/auth_cubit.dart';
import 'package:Tareonix/widgets/TextField.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        title: const Text("Iniciar Sesión", style: TextStyle(color: Palette.titleTextColor)),
        backgroundColor: Palette.appBarColor,
        iconTheme: const IconThemeData(color: Palette.iconColor),
      ),
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
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Palette.cardColor,
                foregroundColor: Palette.textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                final String email = emailController.text.trim();
                final String password = passwordController.text.trim();

                if (email.isNotEmpty && password.isNotEmpty) {
                  await context.read<AuthCubit>().logIn(email, password);
                  if (context.read<AuthCubit>().state is AuthLoggedIn ||
                      context.read<AuthCubit>().state is! AuthEmailVerificationRequired) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/project',
                        (Route<dynamic> route) => false);
                  } else if (context.read<AuthCubit>().state is AuthEmailVerificationRequired) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, verifica tu email antes de iniciar sesión')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al iniciar sesión')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, rellene todos los campos')),
                  );
                }
              },
              child: const Text(
                'Iniciar Sesión',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}