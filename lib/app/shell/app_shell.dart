import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.child,
    super.key,
  });

  final Widget child;

  static const List<_NavigationItem> _items = [
    _NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      route: '/dashboard',
    ),
    _NavigationItem(
      label: 'Business',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront_rounded,
      route: '/business',
    ),
    _NavigationItem(
      label: 'Menu',
      icon: Icons.restaurant_menu_outlined,
      selectedIcon: Icons.restaurant_menu_rounded,
      route: '/menu',
    ),
    _NavigationItem(
      label: 'AI Import',
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      route: '/ai-import',
    ),
    _NavigationItem(
      label: 'QR',
      icon: Icons.qr_code_2_outlined,
      selectedIcon: Icons.qr_code_2_rounded,
      route: '/qr',
    ),
    _NavigationItem(
      label: 'Subscription',
      icon: Icons.credit_card_outlined,
      selectedIcon: Icons.credit_card_rounded,
      route: '/subscription',
    ),
    _NavigationItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      route: '/profile',
    ),
  ];

  int _selectedIndex(String location) {
    final index = _items.indexWhere(
          (item) => location.startsWith(item.route),
    );

    return index == -1 ? 0 : index;
  }

  void _navigate(
      BuildContext context,
      int index,
      ) {
    context.go(_items[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(location);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                _DesktopNavigation(
                  items: _items,
                  selectedIndex: selectedIndex,
                  onSelected: (index) {
                    _navigate(context, index);
                  },
                ),

                Expanded(
                  child: Column(
                    children: [
                      const _DesktopHeader(),
                      Expanded(
                        child: child,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: const _MobileHeader(),
          body: child,
          bottomNavigationBar: _MobileNavigation(
            items: _items,
            selectedIndex: selectedIndex,
            onSelected: (index) {
              _navigate(context, index);
            },
          ),
        );
      },
    );
  }
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                28,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'ScanAura',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = index == selectedIndex;

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4,
                    ),
                    child: ListTile(
                      onTap: () => onSelected(index),
                      selected: selected,
                      selectedTileColor: AppColors.primaryLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(
                        selected
                            ? item.selectedIcon
                            : item.icon,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text(
                  'Restaurant Owner',
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: const Text(
                  'Account',
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
                onTap: () => onSelected(
                  items.length - 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),

          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),

          const SizedBox(width: 8),

          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Icon(
              Icons.person_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const _MobileHeader();

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'ScanAura',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
          ),
        ),
      ],
    );
  }
}

class _MobileNavigation extends StatelessWidget {
  const _MobileNavigation({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(5).toList();

    return NavigationBar(
      selectedIndex: selectedIndex >= 5 ? 0 : selectedIndex,
      onDestinationSelected: onSelected,
      destinations: visibleItems
          .map(
            (item) => NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: item.label,
        ),
      )
          .toList(),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
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