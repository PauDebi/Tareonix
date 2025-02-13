import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/widgets/TextField.dart';

class SignUpSignInForm extends StatefulWidget {
  final bool signUp;
  const SignUpSignInForm({super.key, required this.signUp});

  @override
  _SignUpSignInFormState createState() => _SignUpSignInFormState();
}

class _SignUpSignInFormState extends State<SignUpSignInForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

void _onSubmit() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String? name = widget.signUp ? _nameController.text.trim() : null;

    if (widget.signUp) {
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
              widget.signUp ? 'Create an account' : 'Log in',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
             if (widget.signUp)
              CustomTextField(
                hint: "Name", controller: _nameController),
            const SizedBox(height: 10),
            CustomTextField(hint: "Email" , controller: _emailController),
            const SizedBox(height: 10),
            CustomTextField(hint: "Password", isPassword: true, controller: _passwordController),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed:  _onSubmit,
              child: Text(widget.signUp ? 'Sign up' : 'Log in'),
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
