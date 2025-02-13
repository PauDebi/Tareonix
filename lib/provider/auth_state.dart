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
  final String userName;
  final String? userImageUrl;

  AuthLoggedIn({required this.userName, this.userImageUrl});

  @override
  List<Object?> get props => [userName, userImageUrl];
}

class AuthLoggedOut extends AuthState {}
