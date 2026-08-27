import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/router/app_router.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';
import 'features/auth/presentation/providers/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  await container
      .read(authNotifierProvider.notifier)
      .initialize();

  final preferences =
  await SharedPreferences.getInstance();

  final introSeen =
      preferences.getBool(
        'scanaura_intro_seen',
      ) ??
          false;

  final authState =
  container.read(
    authNotifierProvider,
  );

  final isAuthenticated =
      authState.status ==
          AuthStatus.authenticated;

  String initialLocation;

  // ------------------------------------------------------------
  // IMPORTANT:
  // On Flutter Web, preserve a deep link such as:
  //
  // /verify-email?token=...
  // /reset-password?token=...
  //
  // Do NOT replace it with /landing.
  // ------------------------------------------------------------

  final browserPath =
      Uri.base.path;

  final browserQuery =
      Uri.base.query;

  final isWebDeepLink =
      kIsWeb &&
          browserPath.isNotEmpty &&
          browserPath != '/';

  if (isWebDeepLink) {
    initialLocation =
    browserQuery.isEmpty
        ? browserPath
        : '$browserPath?$browserQuery';
  } else if (isAuthenticated) {
    initialLocation =
    authState.isAdmin
        ? '/admin'
        : '/dashboard';
  } else if (introSeen) {
    initialLocation = '/login';
  } else {
    initialLocation = '/landing';
  }

  debugPrint(
    'STARTUP: '
        'authenticated=$isAuthenticated '
        'introSeen=$introSeen '
        'browserPath=$browserPath '
        'initialLocation=$initialLocation',
  );

  final router =
  AppRouter.createRouter(
    container,
    initialLocation:
    initialLocation,
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: ScanAuraApp(
        router: router,
      ),
    ),
  );
}