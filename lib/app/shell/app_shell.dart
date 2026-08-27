import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/business/presentation/providers/business_notifier.dart';
import '../../features/business/presentation/providers/business_state.dart';
import '../theme/app_colors.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<AppShell> createState() =>
      _AppShellState();
}

class _AppShellState
    extends ConsumerState<AppShell> {
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
      label: 'Catalog',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
      route: '/menu',
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
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final businessState =
      ref.read(businessNotifierProvider);

      if (businessState.status ==
          BusinessStatus.initial) {
        ref
            .read(
          businessNotifierProvider.notifier,
        )
            .loadMyBusiness();
      }
    });
  }

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
    context.go(
      _items[index].route,
    );
  }

  Future<void> _logout() async {
    await ref
        .read(
      authNotifierProvider.notifier,
    )
        .logout();

    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location =
        GoRouterState.of(context).uri.path;

    final selectedIndex =
    _selectedIndex(location);

    final businessState =
    ref.watch(
      businessNotifierProvider,
    );

    final business =
        businessState.business;

    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final width =
            constraints.maxWidth;

        // ============================================================
        // MOBILE
        // < 600
        // ============================================================

        if (width < 600) {
          return Scaffold(
            appBar: _MobileHeader(
              logoUrl: business?.logoUrl,
              onLogout: _logout,
            ),
            body: SafeArea(
              top: false,
              child: widget.child,
            ),
            bottomNavigationBar:
            _MobileNavigation(
              items: _items,
              selectedIndex:
              selectedIndex,
              onSelected: (index) {
                _navigate(
                  context,
                  index,
                );
              },
            ),
          );
        }

        // ============================================================
        // TABLET
        // 600 - 999
        // ============================================================

        if (width < 1000) {
          return Scaffold(
            body: Row(
              children: [
                _TabletNavigation(
                  items: _items,
                  selectedIndex:
                  selectedIndex,
                  logoUrl:
                  business?.logoUrl,
                  onSelected: (index) {
                    _navigate(
                      context,
                      index,
                    );
                  },
                ),

                Expanded(
                  child: Column(
                    children: [
                      _DesktopHeader(
                        logoUrl:
                        business?.logoUrl,
                        onLogout: _logout,
                      ),
                      Expanded(
                        child: widget.child,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // ============================================================
        // DESKTOP
        // >= 1000
        // ============================================================

        return Scaffold(
          body: Row(
            children: [
              _DesktopNavigation(
                items: _items,
                selectedIndex:
                selectedIndex,
                logoUrl:
                business?.logoUrl,
                onSelected: (index) {
                  _navigate(
                    context,
                    index,
                  );
                },
                onLogout: _logout,
              ),

              Expanded(
                child: Column(
                  children: [
                    _DesktopHeader(
                      logoUrl:
                      business?.logoUrl,
                      onLogout: _logout,
                    ),
                    Expanded(
                      child: widget.child,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// DESKTOP NAVIGATION
// ============================================================

class _DesktopNavigation
    extends StatelessWidget {
  const _DesktopNavigation({
    required this.items,
    required this.selectedIndex,
    required this.logoUrl,
    required this.onSelected,
    required this.onLogout,
  });

  final List<_NavigationItem> items;
  final int selectedIndex;
  final String? logoUrl;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

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
            // ========================================================
            // SCANAURA BRAND
            // ========================================================

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                28,
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/scanaura_logo.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  const Text(
                    'ScanAura',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // ========================================================
            // NAVIGATION
            // ========================================================

            Expanded(
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                itemCount: items.length,
                itemBuilder:
                    (context, index) {
                  final item =
                  items[index];

                  final selected =
                      index ==
                          selectedIndex;

                  return Padding(
                    padding:
                    const EdgeInsets.only(
                      bottom: 4,
                    ),
                    child: ListTile(
                      onTap: () =>
                          onSelected(index),
                      selected: selected,
                      selectedTileColor:
                      AppColors
                          .primaryLight,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                      leading: Icon(
                        selected
                            ? item.selectedIcon
                            : item.icon,
                        color: selected
                            ? AppColors
                            .primary
                            : AppColors
                            .textSecondary,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? AppColors
                              .primary
                              : AppColors
                              .textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ========================================================
            // BUSINESS FOOTER
            // ========================================================

            Padding(
              padding:
              const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                  AppColors.primaryLight,
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _BusinessAvatar(
                          logoUrl: logoUrl,
                          size: 42,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Expanded(
                          child: Text(
                            'Business',
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight:
                              FontWeight.w700,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      'Powered by ScanAura',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w500,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    SizedBox(
                      width:
                      double.infinity,
                      child:
                      OutlinedButton.icon(
                        onPressed: onLogout,
                        icon: const Icon(
                          Icons
                              .logout_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Logout',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TABLET NAVIGATION
// ============================================================

class _TabletNavigation
    extends StatelessWidget {
  const _TabletNavigation({
    required this.items,
    required this.selectedIndex,
    required this.logoUrl,
    required this.onSelected,
  });

  final List<_NavigationItem> items;
  final int selectedIndex;
  final String? logoUrl;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
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
            // ========================================================
            // LOGO
            // ========================================================

            Padding(
              padding:
              const EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Image.asset(
                'assets/images/scanaura_logo.png',
                width: 34,
                height: 34,
                fit: BoxFit.contain,
              ),
            ),

            // ========================================================
            // ICON NAVIGATION
            // ========================================================

            Expanded(
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                itemCount: items.length,
                itemBuilder:
                    (context, index) {
                  final item =
                  items[index];

                  final selected =
                      index ==
                          selectedIndex;

                  return Padding(
                    padding:
                    const EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: Tooltip(
                      message:
                      item.label,
                      child: Material(
                        color: Colors
                            .transparent,
                        child: InkWell(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                          onTap: () =>
                              onSelected(
                                index,
                              ),
                          child: Container(
                            height: 52,
                            decoration:
                            BoxDecoration(
                              color: selected
                                  ? AppColors
                                  .primaryLight
                                  : Colors
                                  .transparent,
                              borderRadius:
                              BorderRadius
                                  .circular(
                                12,
                              ),
                            ),
                            child: Icon(
                              selected
                                  ? item
                                  .selectedIcon
                                  : item.icon,
                              color: selected
                                  ? AppColors
                                  .primary
                                  : AppColors
                                  .textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ========================================================
            // BUSINESS AVATAR
            // ========================================================

            Padding(
              padding:
              const EdgeInsets.only(
                bottom: 16,
              ),
              child: _BusinessAvatar(
                logoUrl: logoUrl,
                size: 42,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DESKTOP HEADER
// ============================================================

class _DesktopHeader
    extends StatelessWidget {
  const _DesktopHeader({
    required this.logoUrl,
    required this.onLogout,
  });

  final String? logoUrl;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      decoration:
      const BoxDecoration(
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

          _BusinessAvatar(
            logoUrl: logoUrl,
            size: 38,
          ),

          const SizedBox(
            width: 12,
          ),

          IconButton(
            tooltip: 'Logout',
            onPressed: onLogout,
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MOBILE HEADER
// ============================================================

class _MobileHeader
    extends StatelessWidget
    implements PreferredSizeWidget {
  const _MobileHeader({
    required this.logoUrl,
    required this.onLogout,
  });

  final String? logoUrl;
  final VoidCallback onLogout;

  @override
  Size get preferredSize =>
      const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 16,

      title: Row(
        children: [
          Image.asset(
            'assets/images/scanaura_logo.png',
            width: 34,
            height: 34,
            fit: BoxFit.contain,
          ),

          const SizedBox(
            width: 10,
          ),

          const Flexible(
            child: Text(
              'ScanAura',
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ],
      ),

      actions: [
        _BusinessAvatar(
          logoUrl: logoUrl,
          size: 36,
        ),

        const SizedBox(
          width: 2,
        ),

        IconButton(
          tooltip: 'Logout',
          onPressed: onLogout,
          icon: const Icon(
            Icons.logout_rounded,
          ),
        ),

        const SizedBox(
          width: 4,
        ),
      ],
    );
  }
}

// ============================================================
// MOBILE NAVIGATION
// ============================================================

class _MobileNavigation
    extends StatelessWidget {
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
    return NavigationBar(
      selectedIndex:
      selectedIndex >= items.length
          ? 0
          : selectedIndex,
      onDestinationSelected:
      onSelected,
      labelBehavior:
      NavigationDestinationLabelBehavior
          .alwaysShow,
      destinations: items
          .map(
            (item) =>
            NavigationDestination(
              icon: Icon(
                item.icon,
              ),
              selectedIcon: Icon(
                item.selectedIcon,
              ),
              label: item.label,
            ),
      )
          .toList(),
    );
  }
}

// ============================================================
// BUSINESS AVATAR
// ============================================================

class _BusinessAvatar
    extends StatelessWidget {
  const _BusinessAvatar({
    required this.logoUrl,
    required this.size,
  });

  final String? logoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasLogo =
        logoUrl != null &&
            logoUrl!.trim().isNotEmpty;

    if (hasLogo) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(
            size * 0.22,
          ),
          child: Image.network(
            logoUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (
                context,
                error,
                stackTrace,
                ) {
              return Container(
                width: size,
                height: size,
                alignment:
                Alignment.center,
                child: Icon(
                  Icons
                      .storefront_rounded,
                  size: size * 0.55,
                  color:
                  AppColors.primary,
                ),
              );
            },
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Icon(
          Icons.storefront_rounded,
          size: size * 0.55,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ============================================================
// NAVIGATION ITEM
// ============================================================

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