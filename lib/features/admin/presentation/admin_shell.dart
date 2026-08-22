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
    if (location.startsWith('/admin/businesses')) {
      return 1;
    }

    if (location.startsWith('/admin/subscriptions')) {
      return 2;
    }

    if (location.startsWith('/admin/qr')) {
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
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
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await ref
        .read(authNotifierProvider.notifier)
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
        GoRouterState.of(context).matchedLocation;

    final selectedIndex =
    _selectedIndex(location);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ScanAura Admin',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              _logout(context, ref);
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          _buildRail(
            context,
            selectedIndex,
          ),
          if (MediaQuery.sizeOf(context).width >= 700)
            const VerticalDivider(
              width: 1,
            ),
          Expanded(
            child: child,
          ),
        ],
      ),
      bottomNavigationBar:
      MediaQuery.sizeOf(context).width < 700
          ? NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          _navigate(
            context,
            _items[index].route,
          );
        },
        destinations: _items
            .map(
              (item) =>
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon:
                Icon(item.selectedIcon),
                label: item.label,
              ),
        )
            .toList(),
      )
          : null,
    );
  }

  Widget _buildRail(
      BuildContext context,
      int selectedIndex,
      ) {
    final width =
        MediaQuery.sizeOf(context).width;

    if (width < 700) {
      return const SizedBox.shrink();
    }

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        _navigate(
          context,
          _items[index].route,
        );
      },
      labelType:
      NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 20,
        ),
        child: Icon(
          Icons.admin_panel_settings_outlined,
          size: 30,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),
      ),
      destinations: _items
          .map(
            (item) => NavigationRailDestination(
          icon: Icon(item.icon),
          selectedIcon:
          Icon(item.selectedIcon),
          label: Text(item.label),
        ),
      )
          .toList(),
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