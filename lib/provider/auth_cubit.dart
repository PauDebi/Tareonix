import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:taskly/models/User.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  AuthCubit() : super(AuthInitial());

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

    final url = Uri.parse('http://worldgames.es/api/auth/login');
    final requestBody = jsonEncode({
      "email": email,
      "password": password,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final String token = responseData['token'];
      final user = User.fromJson(responseData['user']);
      if (!user.isVerified) {
        emit(AuthEmailVerificationRequired(
            message:
                'Por favor, verifica tu email antes de iniciar sesión.'));
        return;
      }

      // Guardar el token y los datos del usuario de forma segura.
      await secureStorage.write(key: "token", value: token);
      await saveUser(user);

      emit(AuthLoggedIn(user: user));
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
    print("Saving user");
    String userJson = jsonEncode(user.toJson());
    await secureStorage.write(key: "user_data", value: userJson);
  }

  Future<User?> getUser() async {
    print("Getting user from API");
    emit(AuthLoading());

    // Obtener el token desde el almacenamiento seguro
    String? token = await getToken();

    if (token == null) {
      // Si no hay token, el usuario no está autenticado
      emit(AuthError(errorMessage: "Usuario no autenticado"));
      return null;
    }

    // Realizar la solicitud GET para obtener los datos del usuario desde la API
    final url = Uri.parse('http://worldgames.es/api/user');
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, parseamos los datos del usuario
      final responseData = jsonDecode(response.body);
      final user = User.fromJson(responseData);

      // Guardar los datos del usuario en el almacenamiento seguro
      await saveUser(user);
      emit(AuthLoggedIn(user: user));

      return user;
    } else {
      // Si la solicitud falla, intentamos obtener el usuario guardado localmente
      print("Error al obtener datos de la API. Intentando recuperar datos locales...");
      
      // Recuperamos el usuario guardado en local
      User? localUser = await getUserFromStorage();

      if (localUser != null) {
        print("Usuario recuperado desde almacenamiento local.");
        if (!localUser.isVerified) {
          emit(AuthEmailVerificationRequired(
              message:
                  'Por favor, verifica tu email antes de iniciar sesión.'));
          return null;
        } 
        print(localUser.toJson());
        emit(AuthLoggedIn(user: localUser));
        return localUser;
      } else {
        // Si no hay usuario local, emitimos un error
        final responseData = jsonDecode(response.body);
        String errorMessage = responseData['error'] ?? 'Error al obtener los datos del usuario';
        emit(AuthError(errorMessage: errorMessage));
        return null;
      }
    }
  }

  Future<User?> getUserFromStorage() async {
    String? userJson = await secureStorage.read(key: "user_data");
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }


  Future<void> deleteUser() async {
    await secureStorage.delete(key: "user_data");
  }

  Future<void> updateProfileImage() async {
    print("Updating profile image");
    emit(AuthLoading());
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return; // Usuario canceló la selección

    final File imageFile = File(pickedFile.path);
    final String? token = await getToken();

    if (token == null) {
      emit(AuthError(errorMessage: "Usuario no autenticado"));
      return;
    }
    print("Image selected, uploading...");

    final url = Uri.parse('http://worldgames.es/api/user/profile-image');
    final request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    try {
      print("Sending request...");
      final response = await request.send();
      print("Request sent");
      print(response.statusCode);

      if (response.statusCode == 200) {
        // Obtener el usuario actual y actualizar su imagen
        final user = await getUser();

        emit(AuthLoggedIn(user: user!));
      } else {
        emit(AuthError(errorMessage: "Error al subir la imagen"));
      }
    } catch (e) {
      print(e);
      emit(AuthError(errorMessage: "Error de conexión"));
    }
  }

  Future<void> updateUser(String name, String password, User user) async {
    emit(AuthLoading());
    final url = Uri.parse('http://worldgames.es/api/user');
    final token = await getToken();
    http.Response? response = null;
    if (password.isEmpty) {
      final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name
      }),
    );
    }
    else {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "password": password,
        }),
      );
    }

    if (response!.statusCode == 200) {
      user.name = name;
      emit(AuthLoggedIn(user: user));
    } else {
      final responseData = jsonDecode(response.body);
      String errorMessage = responseData['error'] ?? 'Error al verificar el email';
      emit(AuthError(errorMessage: errorMessage));
    }
  }
}
