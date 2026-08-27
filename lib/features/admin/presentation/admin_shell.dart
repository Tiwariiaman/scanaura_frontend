import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/providers/auth_notifier.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({
    super.key,
    required this.child,
  });

  final Widget child;

  static const _items = [
    _AdminNavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      route: '/admin',
    ),
    _AdminNavItem(
      label: 'Businesses',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront,
      route: '/admin/businesses',
    ),
    _AdminNavItem(
      label: 'Subscriptions',
      icon: Icons.card_membership_outlined,
      selectedIcon: Icons.card_membership,
      route: '/admin/subscriptions',
    ),
    _AdminNavItem(
      label: 'QR Inventory',
      icon: Icons.qr_code_2_outlined,
      selectedIcon: Icons.qr_code_2,
      route: '/admin/qr',
    ),
  ];

  int _selectedIndex(String location) {
    if (location.startsWith(
      '/admin/businesses',
    )) {
      return 1;
    }

    if (location.startsWith(
      '/admin/subscriptions',
    )) {
      return 2;
    }

    if (location.startsWith(
      '/admin/qr',
    )) {
      return 3;
    }

    return 0;
  }

  void _navigate(
      BuildContext context,
      String route,
      ) {
    context.go(route);
  }

  Future<void> _logout(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          title: const Text(
            'Logout?',
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !context.mounted) {
      return;
    }

    await ref
        .read(
      authNotifierProvider
          .notifier,
    )
        .logout();

    if (!context.mounted) {
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final location =
        GoRouterState.of(context)
            .matchedLocation;

    final selectedIndex =
    _selectedIndex(location);

    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final width =
            constraints.maxWidth;

        final isMobile =
            width < 700;

        final isCompactDesktop =
            width >= 700 &&
                width < 1000;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                if (isMobile)
                  Padding(
                    padding:
                    const EdgeInsets
                        .only(
                      right: 10,
                    ),
                    child:
                    Image.asset(
                      'assets/images/scanaura_logo.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Icon(
                          Icons
                              .qr_code_rounded,
                          size: 30,
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: Text(
                    'ScanAura Admin',
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip:
                'Logout',
                onPressed: () {
                  _logout(
                    context,
                    ref,
                  );
                },
                icon:
                const Icon(
                  Icons.logout,
                ),
              ),
              SizedBox(
                width:
                isMobile ? 4 : 8,
              ),
            ],
          ),

          body: Row(
            children: [
              if (!isMobile)
                _buildRail(
                  context,
                  selectedIndex,
                  isCompactDesktop,
                ),

              if (!isMobile)
                const VerticalDivider(
                  width: 1,
                ),

              Expanded(
                child: child,
              ),
            ],
          ),

          bottomNavigationBar:
          isMobile
              ? NavigationBar(
            selectedIndex:
            selectedIndex,
            onDestinationSelected:
                (index) {
              _navigate(
                context,
                _items[index]
                    .route,
              );
            },
            labelBehavior:
            NavigationDestinationLabelBehavior
                .alwaysShow,
            destinations:
            _items.map(
                  (item) {
                return NavigationDestination(
                  icon:
                  Icon(
                    item.icon,
                  ),
                  selectedIcon:
                  Icon(
                    item.selectedIcon,
                  ),
                  label:
                  item.label,
                );
              },
            ).toList(),
          )
              : null,
        );
      },
    );
  }

  Widget _buildRail(
      BuildContext context,
      int selectedIndex,
      bool compactDesktop,
      ) {
    return NavigationRail(
      selectedIndex:
      selectedIndex,
      onDestinationSelected:
          (index) {
        _navigate(
          context,
          _items[index].route,
        );
      },
      labelType: compactDesktop
          ? NavigationRailLabelType
          .selected
          : NavigationRailLabelType
          .all,
      minWidth:
      compactDesktop
          ? 72
          : 88,
      minExtendedWidth:
      compactDesktop
          ? 72
          : 88,
      leading: Padding(
        padding:
        const EdgeInsets.only(
          top: 12,
          bottom: 20,
        ),
        child: Image.asset(
          'assets/images/scanaura_logo.png',
          width: 34,
          height: 34,
          fit: BoxFit.contain,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return Icon(
              Icons
                  .admin_panel_settings_outlined,
              size: 30,
              color: Theme.of(
                context,
              )
                  .colorScheme
                  .primary,
            );
          },
        ),
      ),
      destinations:
      _items.map(
            (item) {
          return NavigationRailDestination(
            icon: Icon(
              item.icon,
            ),
            selectedIcon:
            Icon(
              item.selectedIcon,
            ),
            label: Text(
              item.label,
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
              textAlign:
              TextAlign.center,
            ),
          );
        },
      ).toList(),
    );
  }
}

class _AdminNavItem {
  const _AdminNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}