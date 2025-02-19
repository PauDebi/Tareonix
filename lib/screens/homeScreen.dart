import 'package:flutter/material.dart';
import 'package:taskly/screens/SignUp_SignIn/singInScreen.dart';
import 'package:taskly/screens/SignUp_SignIn/singUpScreen.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInScreen()),
                      );
                    },
                    child: const Text('Iniciar Sesión'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text('Registrarse'),
                  ),
                ],
              )
      ),
    );
  }
}
