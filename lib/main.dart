import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/router/app_router.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  await container
      .read(authNotifierProvider.notifier)
      .initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
        child: ScanAuraApp(
          router: AppRouter.createRouter(container),
        ),
    ),
  );
}