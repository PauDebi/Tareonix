import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo semi-transparente para dar efecto de modal
        GestureDetector(
          onTap: () {}, // Bloquea el cierre al tocar fuera
          child: Container(
            color: Colors.black.withAlpha(100), // Oscurece el fondo
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        
        // Contenedor del login alineado abajo
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome to Tareonix',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.none,),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Let's organazing the things.",
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
                  onPressed: () {
                    // Acción para Sign up
                  },
                  child: const Text('Sign up'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                     Navigator.pop(context); 
                  },
                  child: const Text('Sign in'),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
