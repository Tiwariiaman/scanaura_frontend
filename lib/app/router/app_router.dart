
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/presentation/screens/admin_businesses_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_qr_details_screen.dart';
import '../../features/admin/presentation/screens/admin_qr_inventory_screen.dart';
import '../../features/admin/presentation/screens/admin_qr_scanner_screen.dart';
import '../../features/admin/presentation/screens/admin_subscriptions_screen.dart';
import '../../features/ai/presentation/ai_import_screen.dart';
import '../../features/auth/presentation/screens/email_verification_page.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/business/presentation/business_onboarding_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/landing/presentation/ScanAuraNotFoundScreen.dart';
import '../../features/landing/presentation/landing_gate.dart';
import '../../features/menu/presentation/add_menu_item_screen.dart';
import '../../features/menu/presentation/category_management_screen.dart';
import '../../features/menu/presentation/menu_edit_loader_screen.dart';

import '../../features/menu/presentation/menu_screen.dart';
import '../../features/business/presentation/business_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';

import '../../features/public_menu/presentation/public_landing_screen.dart';
import '../../features/public_menu/presentation/public_menu_screen.dart';
import '../../features/public_menu/presentation/public_payment_screen.dart';
import '../../features/qr/presentation/qr_screen.dart';
import '../../features/subscription/presentation/subscription_screen.dart';
import '../shell/app_shell.dart';
import 'auth_router_refresh.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(
      ProviderContainer container, {
        required String initialLocation,
      }) {
    final authRefresh =
    AuthRouterRefresh(container);

    return GoRouter(
      initialLocation: initialLocation,


      refreshListenable: authRefresh,

      redirect: (context, state) {
        final authState =
        container.read(authNotifierProvider);

        final isAuthenticated =
            authState.status ==
                AuthStatus.authenticated;

        final path =
            state.matchedLocation;

        final isPublicRoute =
            path == '/q' ||
                path.startsWith('/q/');

        final isAuthRoute =
            path == '/login' ||
                path == '/register' ||
                path == '/verify-email' ||
                path == '/forgot-password' ||
                path == '/reset-password';

        final isLandingRoute =
            path == '/landing';



        // Public customer pages never require login.
        if (isPublicRoute) {
          return null;
        }

        // Landing / onboarding route.
        if (isLandingRoute) {
          if (isAuthenticated) {
            return authState.isAdmin
                ? '/admin'
                : '/dashboard';
          }

          return null;
        }

        // Not logged in.
        if (!isAuthenticated) {
          if (isAuthRoute) {
            return null;
          }

          return '/login';
        }

        // ADMIN
        if (authState.isAdmin) {
          if (isAuthRoute ||
              path == '/dashboard' ||
              path.startsWith('/dashboard/')) {
            return '/admin';
          }

          return null;
        }

        // BUSINESS OWNER
        if (authState.isBusinessOwner) {
          if (isAuthRoute ||
              path == '/admin' ||
              path.startsWith('/admin/')) {
            return '/dashboard';
          }

          return null;
        }

        // Authenticated but role is unknown.
        return '/login';
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

        GoRoute(
          path: '/verify-email',
          builder: (
              context,
              state,
              ) {
            final token =
            state.uri.queryParameters['token'];

            final email =
            state.uri.queryParameters['email'];

            if (token != null &&
                token.trim().isNotEmpty) {
              return EmailVerificationPage(
                token: token,
              );
            }

            if (email != null &&
                email.trim().isNotEmpty) {
              return VerifyEmailScreen(
                email: email,
              );
            }

            return const Scaffold(
              body: Center(
                child: Text(
                  'Verification information is missing.',
                ),
              ),
            );
          },
        ),

        GoRoute(
          path: '/forgot-password',
          builder: (
              context,
              state,
              ) {
            return const ForgotPasswordScreen();
          },
        ),

        GoRoute(
          path: '/reset-password',
          builder: (
              context,
              state,
              ) {
            final token =
            state.uri.queryParameters['token'];

            if (token == null ||
                token.trim().isEmpty) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Password reset token is missing.',
                  ),
                ),
              );
            }

            return ResetPasswordScreen(
              token: token,
            );
          },
        ),

        GoRoute(
          path: '/landing',
          builder: (
              context,
              state,
              ) {
            return LandingGate();
          },
        ),
        GoRoute(
          path: '/q/:qrCode',
          builder: (context, state) {
            final qrCode = state.pathParameters['qrCode'];

            if (qrCode == null || qrCode.isEmpty) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Invalid QR code.',
                  ),
                ),
              );
            }

            return PublicLandingScreen(
              qrCode: qrCode,
              onOpenMenu: () {
                context.push(
                  '/q/$qrCode/menu',
                );
              },
              onOpenPayment: () {
                context.push(
                  '/q/$qrCode/payment',
                );
              },
            );
          },
        ),

        GoRoute(
          path: '/q/:qrCode/menu',
          builder: (context, state) {
            final qrCode = state.pathParameters['qrCode'];

            if (qrCode == null || qrCode.isEmpty) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Invalid QR code.',
                  ),
                ),
              );
            }

            return PublicMenuScreen(
              qrCode: qrCode,
            );
          },
        ),

        GoRoute(
          path: '/q/:qrCode/payment',
          builder: (context, state) {
            final qrCode = state.pathParameters['qrCode'];

            if (qrCode == null || qrCode.isEmpty) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Invalid QR code.',
                  ),
                ),
              );
            }

            return PublicPaymentScreen(
              qrCode: qrCode,
            );
          },
        ),

         //Admin Shell
        ShellRoute(
          builder: (context, state, child) {
            return AdminShell(
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/admin',
              builder: (context, state) {
                return const AdminDashboardScreen();
              },
            ),

            GoRoute(
              path: '/admin/businesses',
              builder: (context, state) {
                return const AdminBusinessesScreen();
              },
            ),

            GoRoute(
              path: '/admin/qr',
              builder: (context, state) {
                return const AdminQrInventoryScreen();
              },
            ),

            GoRoute(
              path: '/admin/subscriptions',
              builder: (context, state) {
                return const AdminSubscriptionsScreen();
              },
            ),
            GoRoute(
              path: '/admin/qr/scan',
              builder: (context, state) {
                return const AdminQrScannerScreen();
              },
            ),

            GoRoute(
              path: '/admin/qr/details',
              builder: (context, state) {
                final qrCode =
                state.extra as String?;

                if (qrCode == null ||
                    qrCode.isEmpty) {
                  return const Scaffold(
                    body: Center(
                      child: Text(
                        'Invalid QR code.',
                      ),
                    ),
                  );
                }

                return AdminQrDetailsScreen(
                  qrCode: qrCode,
                );
              },
            ),

          ],
        ),

        //Business Shell
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
                final isEditMode =
                    state.uri.queryParameters['edit'] ==
                        'true';

                return BusinessOnboardingScreen(
                  isEditMode: isEditMode,
                );
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
              path: '/qr',
              builder: (context, state) {
                return const QrScreen();
              },
            ),

            GoRoute(
              path: '/menu/add',
              builder: (context, state) {
                return const AddMenuItemScreen();
              },
            ),

            GoRoute(
              path: '/menu/edit/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'];

                return MenuEditLoaderScreen(
                  catalogId: id!,
                );
              },
            ),

            GoRoute(
              path: '/menu/categories',
              builder: (context, state) {
                return const CategoryManagementScreen();
              },
            ),

          ],
        ),
      ],
      errorBuilder: (context, state) {
        return const ScanAuraNotFoundScreen();
      },
    );
  }
}