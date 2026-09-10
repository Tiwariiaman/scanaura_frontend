import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _AppShellState extends ConsumerState<AppShell> {
  // ============================================================
  // DESKTOP / TABLET NAVIGATION
  // ============================================================

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
      label: 'Activity',
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome_rounded,
      route: '/activity',
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

  // ============================================================
  // SELECTED NAVIGATION
  // ============================================================

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

  // ============================================================
  // LOYALTY SCANNER
  // ============================================================

  void _openLoyaltyScanner() {
    context.go('/activity/loyalty/scan');
  }

  // ============================================================
  // LOGOUT
  // ============================================================

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

  // ============================================================
  // SUPPORT
  // ============================================================

  Future<void> _openScanAuraSupport() async {
    const phone = '917056222557';

    const message =
        'Hi ScanAura Support, I need help with my business account.';

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Unable to open WhatsApp.',
              ),
              behavior:
              SnackBarBehavior.floating,
            ),
          );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Unable to open WhatsApp.',
              ),
              behavior:
              SnackBarBehavior.floating,
            ),
          );
      }
    }
  }

  // ============================================================
  // CONTACT US
  // ============================================================

  void _openContactUs() {
    context.go('/contact-us');
  }

  // ============================================================
  // BUILD
  // ============================================================

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

        // ========================================================
        // MOBILE
        // < 600
        // ========================================================

        if (width < 600) {
          return Scaffold(
            appBar: _MobileHeader(
              logoUrl:
              business?.logoUrl,
              onContactUs:
              _openContactUs,
              onScanLoyalty:
              _openLoyaltyScanner,
              onLogout:
              _logout,
            ),

            body: SafeArea(
              top: false,
              child: widget.child,
            ),

            bottomNavigationBar:
            _MobileNavigation(
              selectedIndex:
              selectedIndex,
              onSelected:
                  (route) {
                context.go(route);
              },
            ),
          );
        }

        // ========================================================
        // TABLET
        // 600 - 999
        // ========================================================

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
                  onSelected:
                      (index) {
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
                        onContactUs:
                        _openContactUs,
                        onScanLoyalty:
                        _openLoyaltyScanner,
                        onLogout:
                        _logout,
                      ),

                      Expanded(
                        child:
                        widget.child,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            floatingActionButton:
            FloatingActionButton.extended(
              onPressed:
              _openScanAuraSupport,
              backgroundColor:
              const Color(0xFF00674F),
              foregroundColor:
              Colors.white,
              icon: const Icon(
                Icons.message_rounded,
              ),
              label: const Text(
                'Support',
                style: TextStyle(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            floatingActionButtonLocation:
            FloatingActionButtonLocation
                .endFloat,
          );
        }

        // ========================================================
        // DESKTOP
        // >= 1000
        // ========================================================

        return Scaffold(
          body: Row(
            children: [
              _DesktopNavigation(
                items: _items,
                selectedIndex:
                selectedIndex,
                logoUrl:
                business?.logoUrl,
                onSelected:
                    (index) {
                  _navigate(
                    context,
                    index,
                  );
                },
                onLogout:
                _logout,
              ),

              Expanded(
                child: Column(
                  children: [
                    _DesktopHeader(
                      logoUrl:
                      business?.logoUrl,
                      onLogout:
                      _logout,
                      onContactUs:
                      _openContactUs,
                      onScanLoyalty:
                      _openLoyaltyScanner,
                    ),

                    Expanded(
                      child:
                      widget.child,
                    ),
                  ],
                ),
              ),
            ],
          ),

          floatingActionButton:
          FloatingActionButton.extended(
            onPressed:
            _openScanAuraSupport,
            backgroundColor:
            const Color(0xFF00674F),
            foregroundColor:
            Colors.white,
            icon: const Icon(
              Icons.message_rounded,
            ),
            label: const Text(
              'Support',
              style: TextStyle(
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),

          floatingActionButtonLocation:
          FloatingActionButtonLocation
              .endFloat,
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
      decoration:
      const BoxDecoration(
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
            // BRAND
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
                itemCount:
                items.length,
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
                          onSelected(
                            index,
                          ),
                      selected:
                      selected,
                      selectedTileColor:
                      AppColors
                          .primaryLight,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
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
                        style:
                        TextStyle(
                          fontWeight:
                          selected
                              ? FontWeight
                              .w600
                              : FontWeight
                              .w400,
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
              const EdgeInsets.all(
                16,
              ),
              child: Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(
                  12,
                ),
                decoration:
                BoxDecoration(
                  color: AppColors
                      .primaryLight,
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
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
                            TextOverflow
                                .ellipsis,
                            style:
                            TextStyle(
                              fontWeight:
                              FontWeight
                                  .w700,
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
                        onPressed:
                        onLogout,
                        icon:
                        const Icon(
                          Icons
                              .logout_rounded,
                          size: 18,
                        ),
                        label:
                        const Text(
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
      decoration:
      const BoxDecoration(
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

            Expanded(
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                itemCount:
                items.length,
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
                        color:
                        Colors.transparent,
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
                          child:
                          Container(
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

            Padding(
              padding:
              const EdgeInsets.only(
                bottom: 16,
              ),
              child:
              _BusinessAvatar(
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
    required this.onContactUs,
    required this.onScanLoyalty,
    required this.onLogout,
  });

  final String? logoUrl;
  final VoidCallback onContactUs;
  final VoidCallback onScanLoyalty;
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
            width: 10,
          ),

          // ======================================================
          // LOYALTY SCANNER
          // ======================================================

          IconButton(
            tooltip: 'Scan loyalty QR',
            onPressed:
            onScanLoyalty,
            icon: const Icon(
              Icons
                  .qr_code_scanner_rounded,
            ),
          ),

          const SizedBox(
            width: 2,
          ),

          IconButton(
            tooltip: 'Contact Us',
            onPressed:
            onContactUs,
            icon: const Icon(
              Icons
                  .support_agent_rounded,
            ),
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
    required this.onContactUs,
    required this.onScanLoyalty,
    required this.onLogout,
  });

  final String? logoUrl;
  final VoidCallback onContactUs;
  final VoidCallback onScanLoyalty;
  final VoidCallback onLogout;

  @override
  Size get preferredSize =>
      const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading:
      false,
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
        // ======================================================
        // QUICK LOYALTY SCANNER
        // ======================================================

        IconButton(
          tooltip: 'Scan loyalty QR',
          onPressed:
          onScanLoyalty,
          icon: const Icon(
            Icons
                .qr_code_scanner_rounded,
          ),
        ),

        const SizedBox(
          width: 2,
        ),

        // ======================================================
        // SUPPORT / CONTACT
        // ======================================================

        IconButton(
          tooltip: 'Contact Us',
          onPressed:
          onContactUs,
          icon: const Icon(
            Icons
                .support_agent_rounded,
          ),
        ),

        const SizedBox(
          width: 2,
        ),

        // ======================================================
        // LOGOUT
        // ======================================================

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
//
// Dashboard | Business | CATALOG | Activity | Subscription
//
// Catalog is intentionally the prominent center action.
// QR is intentionally hidden from this five-slot mobile layout.
// ============================================================

class _MobileNavigation
    extends StatelessWidget {
  const _MobileNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    final isCatalogSelected =
        selectedIndex == 2;

    final isDashboardSelected =
        selectedIndex == 0;

    final isBusinessSelected =
        selectedIndex == 1;

    final isActivitySelected =
        selectedIndex == 3;

    final isSubscriptionSelected =
        selectedIndex == 5;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 82,
        child: Stack(
          clipBehavior:
          Clip.none,
          alignment:
          Alignment.topCenter,
          children: [
            // ======================================================
            // BAR
            // ======================================================

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 68,
                decoration:
                BoxDecoration(
                  color:
                  colors.surface,
                  border: Border(
                    top: BorderSide(
                      color: colors
                          .outlineVariant,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(
                        alpha: 0.06,
                      ),
                      blurRadius: 18,
                      offset:
                      const Offset(
                        0,
                        -5,
                      ),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ==================================================
                    // LEFT SIDE
                    // ==================================================

                    Expanded(
                      child:
                      _MobileNavItem(
                        icon: Icons
                            .dashboard_outlined,
                        selectedIcon:
                        Icons
                            .dashboard_rounded,
                        label:
                        'Dashboard',
                        selected:
                        isDashboardSelected,
                        onTap: () =>
                            onSelected(
                              '/dashboard',
                            ),
                      ),
                    ),

                    Expanded(
                      child:
                      _MobileNavItem(
                        icon: Icons
                            .storefront_outlined,
                        selectedIcon:
                        Icons
                            .storefront_rounded,
                        label: 'Business',
                        selected:
                        isBusinessSelected,
                        onTap: () =>
                            onSelected(
                              '/business',
                            ),
                      ),
                    ),

                    // ==================================================
                    // CENTER SPACE
                    // ==================================================

                    const SizedBox(
                      width: 76,
                    ),

                    // ==================================================
                    // RIGHT SIDE
                    // ==================================================

                    Expanded(
                      child:
                      _MobileNavItem(
                        icon: Icons
                            .auto_awesome_outlined,
                        selectedIcon:
                        Icons
                            .auto_awesome_rounded,
                        label: 'Activity',
                        selected:
                        isActivitySelected,
                        onTap: () =>
                            onSelected(
                              '/activity',
                            ),
                      ),
                    ),

                    Expanded(
                      child:
                      _MobileNavItem(
                        icon: Icons
                            .credit_card_outlined,
                        selectedIcon:
                        Icons
                            .credit_card_rounded,
                        label:
                        'Subscription',
                        selected:
                        isSubscriptionSelected,
                        onTap: () =>
                            onSelected(
                              '/subscription',
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ======================================================
            // FLOATING CATALOG BUTTON
            // ======================================================

            Positioned(
              top: -8,
              child: GestureDetector(
                onTap: () =>
                    onSelected(
                      '/menu',
                    ),
                child: AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 180,
                  ),
                  width: 62,
                  height: 62,
                  decoration:
                  BoxDecoration(
                    color: isCatalogSelected
                        ? colors.primary
                        : colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.surface,
                      width: 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(
                          alpha: 0.14,
                        ),
                        blurRadius: 18,
                        offset:
                        const Offset(
                          0,
                          7,
                        ),
                      ),
                    ],
                  ),
                  child: Icon(
                    isCatalogSelected
                        ? Icons
                        .inventory_2_rounded
                        : Icons
                        .inventory_2_outlined,
                    size: 29,
                    color: isCatalogSelected
                        ? colors
                        .onPrimary
                        : colors.primary,
                  ),
                ),
              ),
            ),

            // ======================================================
            // CATALOG LABEL
            // ======================================================

            Positioned(
              top: 57,
              child: Text(
                'Catalog',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                  isCatalogSelected
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color:
                  isCatalogSelected
                      ? colors.primary
                      : colors
                      .onSurfaceVariant,
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
// MOBILE NAV ITEM
// ============================================================

class _MobileNavItem
    extends StatelessWidget {
  const _MobileNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 68,
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 160,
                ),
                width: 42,
                height: 30,
                decoration:
                BoxDecoration(
                  color: selected
                      ? colors
                      .primaryContainer
                      : Colors.transparent,
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
                child: Icon(
                  selected
                      ? selectedIcon
                      : icon,
                  size: 21,
                  color: selected
                      ? colors.primary
                      : colors
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(
                height: 2,
              ),

              Text(
                label,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: selected
                      ? colors.primary
                      : colors
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
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
                  size:
                  size * 0.55,
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