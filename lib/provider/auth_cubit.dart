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

  void signUp(String name, String email, String password) async {
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final String token = responseData['token']; // Asegúrate de que el JSON devuelva "token"
      final user = User.fromJson(responseData['user']);

      // Guardar el token de forma segura
      await secureStorage.write(key: "token", value: token);
      await saveUser(user);

      emit(AuthLoggedIn(userName: responseData['name']));
    } else {
      print("Error: ${response.body}");
    }
  }

  void logIn(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      emit(AuthShowLogIn()); // No cambia a `AuthLoggedIn` si los datos son inválidos
      return;
    }

    final url = Uri.parse('http://worldgames.es/api/auth/login');
    http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    ).then((response) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final String token = responseData['token']; // Asegúrate de que el JSON devuelva "token"
        final user = User.fromJson(responseData['user']);

        // Guardar el token de forma segura
        secureStorage.write(key: "token", value: token);
        saveUser(user);

        emit(AuthLoggedIn(userName: user.name));
      } else {
        print("Error: ${response.body}");
      }
    });

    emit(AuthLoggedIn(userName: email.split('@').first)); // Simulación usando el nombre del email
  }

  Future<void> logout() async{
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
