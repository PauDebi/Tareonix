import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taskly/models/User.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

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

  /// Registra al usuario y, en lugar de iniciar sesión automáticamente,
  /// emite un estado indicando que se debe verificar el email.
  Future<void> signUp(String name, String email, String password) async {
    final url = Uri.parse('http://worldgames.es/api/auth/register');
    
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      // El registro fue exitoso, pero se requiere verificación de email.
      final responseData = jsonDecode(response.body);
      String message = responseData['message'] ??
          'Registro exitoso. Revisa tu email para verificar la cuenta.';
      emit(AuthEmailVerificationRequired(message: message));
    } else {
      // Ocurrió un error en el registro.
      final responseData = jsonDecode(response.body);
      String errorMessage =
          responseData['error'] ?? 'Error desconocido en el registro';
      emit(AuthError(errorMessage: errorMessage));
    }
  }

  /// Realiza el login. Si el usuario no ha verificado el email,
  /// se emite un estado indicando que debe verificarlo.
  Future<void> logIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(AuthShowLogIn());
      return;
    }

    final url = Uri.parse('http://worldgames.es/api/auth/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final String token = responseData['token'];
      final user = User.fromJson(responseData['user']);

      // Guardar el token y los datos del usuario de forma segura.
      await secureStorage.write(key: "token", value: token);
      await saveUser(user);

      emit(AuthLoggedIn(userName: user.name, userImageUrl: user.imageUrl));
    } else {
      final responseData = jsonDecode(response.body);
      String errorMessage =
          responseData['error'] ?? 'Error desconocido en el login';
      // Si el mensaje de error indica que el email no ha sido verificado.
      if (errorMessage.toLowerCase().contains('verify')) {
        emit(AuthEmailVerificationRequired(
            message:
                'Por favor, verifica tu email antes de iniciar sesión.'));
      } else {
        emit(AuthError(errorMessage: errorMessage));
      }
    }
  }

  Future<void> logout() async {
    await secureStorage.delete(key: "token");
    await deleteUser();
    emit(AuthLoggedOut());
    
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: "token");
  }

  Future<void> saveUser(User user) async {
    String userJson = jsonEncode(user.toJson());
    await secureStorage.write(key: "user_data", value: userJson);
  }

  Future<User?> getUser() async {
    String? userJson = await secureStorage.read(key: "user_data");
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<void> deleteUser() async {
    await secureStorage.delete(key: "user_data");
  }
}
