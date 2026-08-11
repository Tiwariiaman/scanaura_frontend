import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/menu/presentation/menu_screen.dart';
import '../../features/business/presentation/business_screen.dart';
import '../../features/ai/presentation/ai_import_screen.dart';
import '../../features/qr/presentation/qr_screen.dart';
import '../../features/subscription/presentation/subscription_screen.dart';
import '../shell/app_shell.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',

    routes: [
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