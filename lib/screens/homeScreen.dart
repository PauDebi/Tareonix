import 'package:flutter/material.dart';
import 'package:taskly/screens/login_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _showLoginDialog(context));
  }

 void _showLoginDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false, // Bloquea el cierre al tocar fuera
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const LoginPage(); // Usa el LoginPage modificado
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1), // Empieza desde abajo
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Trello competency',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
      ),
    );
  }
}