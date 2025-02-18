import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/models/User.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/provider/project_cubit.dart';
import 'package:taskly/screens/homeScreen.dart';
import 'package:taskly/screens/projectScreen.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<ProjectCubit>(create: (_) => ProjectCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: context.read<AuthCubit>().getUser(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } 
        
        else if (!snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Taskly App',
            home: HomeScreen(),
          );
        } 
        
        else {
          User user = snapshot.data!;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Taskly App',
            home: ProjectScreen(),
            routes: {
              '/login': (context) => HomeScreen(user: user),
              '/signup': (context) => HomeScreen(user: user),
              '/project': (context) => ProjectScreen(),
            },
          );
        }
      },
    );
  }
}