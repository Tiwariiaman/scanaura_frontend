import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../auth/data/models/login_request.dart';
import '../../../auth/data/models/register_request.dart';

import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> initialize() async {
    state = const AuthState(
      status: AuthStatus.loading,
    );

    try {
      final storage = ref.read(secureStorageProvider);

      final token = await storage.getAccessToken();

      if (token == null || token.isEmpty) {
        state = const AuthState(
          status: AuthStatus.unauthenticated,
        );
        return;
      }

      state = const AuthState(
        status: AuthStatus.authenticated,
      );
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState(
      status: AuthStatus.loading,
    );

    try {
      final repository = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);

      final response = await repository.login(
        LoginRequest(
          email: email.trim(),
          password: password,
        ),
      );

      await storage.saveAccessToken(
        response.accessToken,
      );

      state = AuthState(
        status: AuthStatus.authenticated,
        userEmail: email.trim(),
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _cleanErrorMessage(e),
      );
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
  }) async {
    state = const AuthState(
      status: AuthStatus.loading,
    );

    try {
      final repository = ref.read(authRepositoryProvider);

      await repository.register(
        RegisterRequest(
          fullName: fullName.trim(),
          email: email.trim(),
          mobile: mobile.trim(),
          password: password,
        ),
      );

      state = const AuthState(
        status: AuthStatus.unauthenticated,
      );

      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _cleanErrorMessage(e),
      );

      return false;
    }
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);

    await storage.deleteAccessToken();

    state = const AuthState(
      status: AuthStatus.unauthenticated,
    );
  }

  void clearError() {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearError: true,
    );
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}

final authNotifierProvider =
NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);