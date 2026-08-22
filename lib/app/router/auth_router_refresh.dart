import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';

class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(
      ProviderContainer container,
      ) {
    _subscription = container.listen<AuthState>(
      authNotifierProvider,
          (previous, next) {
        debugPrint(
          'AUTH ROUTER REFRESH: '
              'status=${next.status} '
              'role=${next.role}',
        );

        notifyListeners();
      },
    );
  }

  late final ProviderSubscription<AuthState>
  _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}