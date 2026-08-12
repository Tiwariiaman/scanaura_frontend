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
  });

  final AuthStatus status;
  final String? errorMessage;
  final String? userName;
  final String? userEmail;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated;

  bool get isLoading =>
      status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? userName,
    String? userEmail,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage:
      clearError ? null : errorMessage ?? this.errorMessage,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}