import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/provider/auth_cubit.dart';
import 'package:taskly/provider/project_cubit.dart';
import 'package:taskly/screens/homeScreen.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taskly App',
      home: HomeScreen(userName: 'Usuario'),
    );
  }
}
