import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;

  const CustomTextField({super.key, required this.hint, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey), // Color del hint más visible
        filled: true, // Habilita el color de fondo
        fillColor: const Color.fromARGB(255, 43, 43, 43), // Fondo blanco
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey), // Borde gris
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 2), // Borde azul al enfocar
        ),
      ),
      style: const TextStyle(color: Color.fromARGB(255, 232, 232, 232)), // Color del texto ingresado
    );
  }
}