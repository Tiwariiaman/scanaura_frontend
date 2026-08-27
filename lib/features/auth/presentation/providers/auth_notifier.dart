import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../auth/data/models/login_request.dart';
import '../../../auth/data/models/register_request.dart';
import '../../data/models/user_role.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> initialize() async {
    // This should only be called once during app startup.
    state = const AuthState(
      status: AuthStatus.loading,
    );

    try {
      final storage =
      ref.read(secureStorageProvider);

      final token =
      await storage.getAccessToken();

      if (token == null || token.isEmpty) {
        state = const AuthState(
          status: AuthStatus.unauthenticated,
        );
        return;
      }

      final role = _extractRole(token);

      state = AuthState(
        status: AuthStatus.authenticated,
        role: role,
      );

      debugPrint(
        'AUTH INITIALIZED: role=$role',
      );
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
      );

      debugPrint(
        'AUTH INITIALIZE FAILED: $e',
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
      final repository =
      ref.read(authRepositoryProvider);

      final storage =
      ref.read(secureStorageProvider);

      final response =
      await repository.login(
        LoginRequest(
          email: email.trim(),
          password: password,
        ),
      );

      final role =
      _extractRole(response.accessToken);

      await storage.saveAccessToken(
        response.accessToken,
      );

      state = AuthState(
        status:
        AuthStatus.authenticated,
        userEmail:
        email.trim(),
        role: role,
      );

      debugPrint(
        'LOGIN SUCCESS: '
            'email=${email.trim()} '
            'role=$role',
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage:
        _cleanErrorMessage(e),
      );

      debugPrint(
        'LOGIN FAILED: $e',
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
      final repository =
      ref.read(authRepositoryProvider);

      await repository.register(
        RegisterRequest(
          fullName: fullName.trim(),
          email: email.trim(),
          mobile: mobile.trim(),
          password: password,
        ),
      );

      state = const AuthState(
        status:
        AuthStatus.unauthenticated,
      );

      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage:
        _cleanErrorMessage(e),
      );

      return false;
    }
  }

  Future<void> logout() async {
    final storage =
    ref.read(secureStorageProvider);

    await storage.deleteAccessToken();

    // Explicitly clear the previous user's
    // role and identity.
    state = const AuthState(
      status:
      AuthStatus.unauthenticated,
      role: UserRole.unknown,
    );

    debugPrint(
      'LOGOUT COMPLETE',
    );
  }

  UserRole _extractRole(
      String token,
      ) {
    try {
      final decoded =
      JwtDecoder.decode(token);

      final role =
      decoded['role'];

      if (role is String) {
        return UserRole.fromString(role);
      }
    } catch (e) {
      debugPrint(
        'ROLE EXTRACTION FAILED: $e',
      );
    }

    return UserRole.unknown;
  }

  void clearError() {
    state = state.copyWith(
      status:
      AuthStatus.unauthenticated,
      clearError: true,
      role: UserRole.unknown,
    );
  }

  String _cleanErrorMessage(
      Object error,
      ) {
    final message =
    error.toString();

    if (message.startsWith(
      'Exception: ',
    )) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  Future<bool> resendVerificationEmail({
    required String email,
  }) async {
    state = const AuthState(
      status: AuthStatus.loading,
    );

    try {
      final repository =
      ref.read(
        authRepositoryProvider,
      );

      await repository
          .resendVerificationEmail(
        email.trim(),
      );

      state = const AuthState(
        status:
        AuthStatus.unauthenticated,
      );

      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage:
        _cleanErrorMessage(e),
      );

      return false;
    }
  }

  Future<bool> forgotPassword({
    required String email,
  }) async {
    state = const AuthState(
      status: AuthStatus.loading,
    );

    try {
      final repository =
      ref.read(
        authRepositoryProvider,
      );

      await repository.forgotPassword(
        email.trim(),
      );

      state = const AuthState(
        status:
        AuthStatus.unauthenticated,
      );

      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage:
        _cleanErrorMessage(e),
      );

      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = const AuthState(
      status: AuthStatus.loading,
    );

    try {
      final repository =
      ref.read(
        authRepositoryProvider,
      );

      await repository.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      state = const AuthState(
        status:
        AuthStatus.unauthenticated,
      );

      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage:
        _cleanErrorMessage(e),
      );

      return false;
    }
  }
}

final authNotifierProvider =
NotifierProvider<
    AuthNotifier,
    AuthState>(
  AuthNotifier.new,
);