

import '../../data/models/user_role.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.userName,
    this.userEmail,
    this.role = UserRole.unknown,
  });

  final AuthStatus status;
  final String? errorMessage;
  final String? userName;
  final String? userEmail;
  final UserRole role;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated;

  bool get isLoading =>
      status == AuthStatus.loading;

  bool get isAdmin =>
      role == UserRole.admin;

  bool get isBusinessOwner =>
      role == UserRole.businessOwner;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? userName,
    String? userEmail,
    UserRole? role,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      role: role ?? this.role,
    );
  }
}