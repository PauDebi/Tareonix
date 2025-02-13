import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
    void showSignUp() {
    emit(AuthShowSignUp());
  }

  void showLogIn() {
    emit(AuthShowLogIn());
  }

  void showGoogleSignIn() {
    emit(AuthShowGoogleSignIn());
  }

  void signUp(String name, String email, String password) {
    // Aquí iría la lógica para registrar un usuario (Firebase, API, etc.)
    emit(AuthLoggedIn(userName: name));
  }

  void logIn(String email, String password) {
  if (email.isEmpty || password.isEmpty) {
    emit(AuthShowLogIn()); // No cambia a `AuthLoggedIn` si los datos son inválidos
    return;
  }
    // Aquí iría la lógica para iniciar sesión (Firebase, API, etc.)
    emit(AuthLoggedIn(userName: email.split('@').first)); // Simulación usando el nombre del email
  }

  void logout() {
    emit(AuthLoggedOut());
  }
}
