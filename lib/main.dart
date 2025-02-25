import 'package:Tareonix/models/Task.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Tareonix/models/User.dart';
import 'package:Tareonix/provider/auth_cubit.dart';
import 'package:Tareonix/provider/project_cubit.dart';
import 'package:Tareonix/provider/task_cubit.dart';
import 'package:Tareonix/screens/SignUp_SignIn/singInScreen.dart';
import 'package:Tareonix/screens/SignUp_SignIn/singUpScreen.dart';
import 'package:Tareonix/screens/homeScreen.dart';
import 'package:Tareonix/screens/Project_Screens/projectDetailScreen.dart';
import 'package:Tareonix/screens/Project_Screens/projectScreen.dart';
import 'package:Tareonix/screens/taskDetailScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
          BlocProvider<ProjectCubit>(create: (_) => ProjectCubit()),
          BlocProvider<TaskCubit>(create: (_) => TaskCubit()),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: context.read<AuthCubit>().getUser(),
      builder: (context, snapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Tareonix App',
          home: Stack(
            children: [
              if (snapshot.connectionState == ConnectionState.waiting)
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (!snapshot.hasData)
                HomeScreen()
              else
                ProjectScreen(),
            ],
          ),
          routes: {
            '/login': (context) => SignInScreen(),
            '/signup': (context) => SignUpScreen(),
            '/home': (context) => HomeScreen(),
            '/project': (context) => ProjectScreen(),
            '/projectDetails': (context) => ProjectDetailScreen(),
            '/taskDetails': (context) => TaskDetailScreen(task: ModalRoute.of(context)!.settings.arguments as Task,),
          },
        );
      },
    );
  }
}