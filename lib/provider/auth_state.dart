part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthShowSignUp extends AuthState {}

class AuthShowLogIn extends AuthState {}

class AuthShowGoogleSignIn extends AuthState {}

class AuthLoggedIn extends AuthState {
  final User user;

  AuthLoggedIn({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthLoading extends AuthState {}

class AuthLoggedOut extends AuthState {}

/// Estado que indica que se requiere verificar el email antes de iniciar sesión.
class AuthEmailVerificationRequired extends AuthState {
  final String message;

  AuthEmailVerificationRequired({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado para manejar errores en el registro o login.
class AuthError extends AuthState {
  final String errorMessage;

  AuthError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
