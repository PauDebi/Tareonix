import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/widgets/TextField.dart';

class SignUpSignInForm extends StatelessWidget {
  final bool signUp;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  SignUpSignInForm({Key? key, required this.signUp}) : super(key: key);

  void _onSubmit(BuildContext context) {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String? name = signUp ? _nameController.text.trim() : null;

    if (signUp) {
      context.read<AuthCubit>().signUp(name!, email, password);
    } else {
      context.read<AuthCubit>().logIn(email, password);
    }
  }

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
            Text(
              signUp ? 'Create an account' : 'Log in',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            if (signUp)
              CustomTextField(
                hint: "Name",
                controller: _nameController,
              ),
            const SizedBox(height: 10),
            CustomTextField(
              hint: "Email",
              controller: _emailController,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              hint: "Password",
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => _onSubmit(context),
              child: Text(signUp ? 'Sign up' : 'Log in'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
