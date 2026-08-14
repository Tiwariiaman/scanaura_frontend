
import 'package:go_router/go_router.dart';


import '../../features/auth/presentation/ai_import_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/business/presentation/business_onboarding_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/menu/presentation/menu_screen.dart';
import '../../features/business/presentation/business_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';

import '../../features/qr/presentation/qr_screen.dart';
import '../../features/subscription/presentation/subscription_screen.dart';
import '../shell/app_shell.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(ProviderContainer container,) {
    return GoRouter(
      initialLocation: '/login',

      redirect: (context, state) {
        final authState =
        container.read(authNotifierProvider);

        final isAuthenticated =
            authState.status == AuthStatus.authenticated;

        final isAuthRoute =
            state.matchedLocation == '/login' ||
                state.matchedLocation == '/register';

        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        if (isAuthenticated && isAuthRoute) {
          return '/dashboard';
        }

        return null;
      },

      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) {
            return const LoginScreen();
          },
        ),

        GoRoute(
          path: '/register',
          builder: (context, state) {
            return const RegisterScreen();
          },
        ),


        ShellRoute(
          builder: (context, state, child) {
            return AppShell(
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) {
                return const DashboardScreen();
              },
            ),

            GoRoute(
              path: '/business',
              builder: (context, state) {
                return const BusinessScreen();
              },
            ),
            GoRoute(
              path: '/business-onboarding',
              builder: (context, state) {
                return const BusinessOnboardingScreen();
              },
            ),

            GoRoute(
              path: '/menu',
              builder: (context, state) {
                return const MenuScreen();
              },
            ),

            GoRoute(
              path: '/ai-import',
              builder: (context, state) {
                return const AiImportScreen();
              },
            ),

            GoRoute(
              path: '/qr',
              builder: (context, state) {
                return const QrScreen();
              },
            ),

            GoRoute(
              path: '/subscription',
              builder: (context, state) {
                return const SubscriptionScreen();
              },
            ),

            GoRoute(
              path: '/profile',
              builder: (context, state) {
                return const ProfileScreen();
              },
            ),
          ],
        ),
      ],
    );
  }
}