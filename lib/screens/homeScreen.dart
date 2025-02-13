import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/screens/SignUp_SignIn/entryDialog.dart';

class HomeScreen extends StatefulWidget {
  final String? userImageUrl; // URL de imagen de usuario opcional
  final String userName;

  HomeScreen({this.userImageUrl, required this.userName});

  final List<String> buttonLabels = [
    "Proyecto 1",
    "Proyecto 2",
    "Proyecto 3",
    "Proyecto 4",
  ];
  

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
  super.initState();
  Future.microtask(() {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthLoggedIn) {
      _showLoginDialog(context);
    }
  });
}

 void _showLoginDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false, // Bloquea el cierre al tocar fuera
    transitionDuration: const Duration(milliseconds: 300),
     pageBuilder: (context, animation, secondaryAnimation) {
      return WillPopScope(
        onWillPop: () async => false, // Bloquea el botón de retroceso
        child: const EntryDialog(), // Usa el LoginPage
      );
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
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String userName = "Usuario";
        String? userImageUrl;

        if (state is AuthLoggedIn) {
          userName = state.userName;
          userImageUrl = state.userImageUrl;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Trello's Competency"),
            actions: [
              IconButton(
               icon: userImageUrl?.isNotEmpty == true
                      ? CircleAvatar(backgroundImage: NetworkImage(userImageUrl!))
                      : CircleAvatar(
                        child: Text(
                          userName[0].toUpperCase(),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                onPressed: () {
                  print("Usuario clickeado");
                },
              ),
            ],
          ),
          body: ListView(
            children: [
              ListTile(title: Text("Proyecto 1"), trailing: Icon(Icons.arrow_forward)),
              ListTile(title: Text("Proyecto 2"), trailing: Icon(Icons.arrow_forward)),
              ListTile(title: Text("Proyecto 3"), trailing: Icon(Icons.arrow_forward)),
              ListTile(title: Text("Proyecto 4"), trailing: Icon(Icons.arrow_forward)),
            ],
          ),
        );
      },
    );
  }
}