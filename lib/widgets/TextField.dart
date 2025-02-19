import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController controller;
  final String keyboardType;

  const CustomTextField({super.key, required this.hint, this.isPassword = false, required this.controller, this.keyboardType = 'text'});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: _getKeyboardType(), // Tipos de teclado (email, text, number, etc.)
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

  TextInputType _getKeyboardType() {
    switch (keyboardType) {
      case 'email':
        return TextInputType.emailAddress;
      case 'number':
        return TextInputType.number;
      case 'phone':
        return TextInputType.phone;
      case 'multiline':
        return TextInputType.multiline;
      case 'url':
        return TextInputType.url;
      case 'text':
      default:
        return TextInputType.text;
    }
  }
}