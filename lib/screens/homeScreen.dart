import 'package:Tareonix/Palette.dart';
import 'package:flutter/material.dart';
import 'package:Tareonix/screens/SignUp_SignIn/singInScreen.dart';
import 'package:Tareonix/screens/SignUp_SignIn/singUpScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo o icono
            Icon(
              Icons.task_alt,
              size: 100,
              color: Palette.iconColor,
            ),
            SizedBox(height: 20),
            // Título
            Text(
              'Bienvenido a Tareonix',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Palette.titleTextColor,
              ),
            ),
            SizedBox(height: 40),
            // Botones estilizados
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Palette.cardColor,
                foregroundColor: Palette.textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              child: Text(
                'Iniciar Sesión',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Palette.textColor),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Palette.cardColor,
                foregroundColor: Palette.textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: Text(
                'Registrarse',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Palette.textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
