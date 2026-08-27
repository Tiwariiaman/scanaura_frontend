import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../data/models/landing_response.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_notifier.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_state.dart';

class PublicLandingScreen
    extends ConsumerStatefulWidget {
  const PublicLandingScreen({
    super.key,
    required this.qrCode,
    required this.onOpenMenu,
    required this.onOpenPayment,
  });

  final String qrCode;
  final VoidCallback onOpenMenu;
  final VoidCallback onOpenPayment;

  @override
  ConsumerState<PublicLandingScreen> createState() =>
      _PublicLandingScreenState();
}

class _PublicLandingScreenState
    extends ConsumerState<PublicLandingScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(
        publicNotifierProvider.notifier,
      )
          .loadLanding(
        widget.qrCode,
      );
    });
  }

  // ============================================================
  // SHARE
  // ============================================================

  Future<void> _sharePage() async {
    final currentUrl =
    Uri.base.toString();

    final state =
    ref.read(
      publicNotifierProvider,
    );

    final landing =
        state.landing;

    final businessName =
    landing?.businessName
        .trim()
        .isNotEmpty ==
        true
        ? landing!.businessName.trim()
        : 'this business';

    final terminology =
    _terminologyFor(
      landing?.businessType ?? '',
    );

    final shareText =
        'Check out $businessName on ScanAura.\n\n'
        'Explore their digital '
        '${terminology.collectionTitle.toLowerCase()} '
        'and offerings:\n'
        '$currentUrl';

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          title:
          'Check out $businessName',
        ),
      );
    } catch (_) {
      await Clipboard.setData(
        ClipboardData(
          text: shareText,
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          behavior:
          SnackBarBehavior.floating,
          content: Text(
            'Share message copied to clipboard.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUSINESS TYPE LABEL
  // ============================================================

  String _businessTypeLabel(
      String value,
      ) {
    switch (
    value.trim().toUpperCase()) {
      case 'FOOD':
        return 'Food';

      case 'RETAIL':
        return 'Retail';

      case 'ECOMMERCE':
        return 'E-commerce';

      case 'SERVICES':
        return 'Services';

      case 'PERSONAL_BRAND':
        return 'Personal Brand';

      case 'OTHER':
        return 'Other';

      default:
        return value.trim().isEmpty
            ? 'Business'
            : value
            .trim()
            .replaceAll('_', ' ');
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final state =
    ref.watch(
      publicNotifierProvider,
    );

    if (state.status ==
        PublicStatus.loading) {
      return _buildLoading();
    }

    if (state.status ==
        PublicStatus.error &&
        state.landing == null) {
      return _buildError(
        context,
        state,
      );
    }

    final landing =
        state.landing;

    if (landing == null) {
      return _buildUnavailable();
    }

    return Scaffold(
      backgroundColor:
      Theme.of(context)
          .colorScheme
          .surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(
              publicNotifierProvider
                  .notifier,
            )
                .refreshLanding();
          },
          child: LayoutBuilder(
            builder: (
                context,
                constraints,
                ) {
              final width =
                  constraints.maxWidth;

              final horizontalPadding =
              width < 360
                  ? 16.0
                  : width < 600
                  ? 20.0
                  : 24.0;

              final contentMaxWidth =
              width >= 900
                  ? 620.0
                  : 560.0;

              return SingleChildScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding:
                EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  28,
                ),
                child: Center(
                  child:
                  ConstrainedBox(
                    constraints:
                    BoxConstraints(
                      maxWidth:
                      contentMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,
                      children: [
                        _buildTopBar(),

                        SizedBox(
                          height:
                          width < 400
                              ? 16
                              : 24,
                        ),

                        _buildBusinessIdentity(
                          context,
                          landing,
                        ),

                        SizedBox(
                          height:
                          width < 400
                              ? 20
                              : 24,
                        ),

                        _buildActionButtons(
                          context,
                          landing,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        _buildBusinessTypeInfo(
                          context,
                          landing,
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        _buildFooter(
                          context,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UNAVAILABLE
  // ============================================================

  Widget _buildUnavailable() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child:
          SingleChildScrollView(
            padding:
            const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .storefront_outlined,
                    size: 56,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .onSurfaceVariant,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(
                    'Business information is unavailable.',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    'Please try again in a moment.',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child:
          CircularProgressIndicator(),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.end,
      children: [
        IconButton(
          tooltip: 'Share',
          onPressed: _sharePage,
          icon: const Icon(
            Icons.share_outlined,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUSINESS IDENTITY
  // ============================================================

  Widget _buildBusinessIdentity(
      BuildContext context,
      LandingResponse landing,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      children: [
        _buildLogo(
          context,
          landing.logoUrl,
        ),

        const SizedBox(
          height: 18,
        ),

        Text(
          landing.businessName,
          textAlign:
          TextAlign.center,
          maxLines: 3,
          overflow:
          TextOverflow.ellipsis,
          style: theme
              .textTheme
              .headlineMedium
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
            letterSpacing: -0.4,
            height: 1.15,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        Wrap(
          alignment:
          WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon:
              Icons.storefront_outlined,
              label:
              _businessTypeLabel(
                landing.businessType,
              ),
            ),

            if (landing.city
                ?.trim()
                .isNotEmpty ==
                true)
              _InfoChip(
                icon:
                Icons.location_on_outlined,
                label:
                landing.city!.trim(),
              ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo(
      BuildContext context,
      String? logoUrl,
      ) {
    final theme =
    Theme.of(context);

    final width =
        MediaQuery.sizeOf(context)
            .width;

    final size =
    width < 360
        ? 92.0
        : width < 600
        ? 104.0
        : 112.0;

    if (logoUrl == null ||
        logoUrl.trim().isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration:
        BoxDecoration(
          color: theme
              .colorScheme
              .surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons
              .storefront_outlined,
          size: size * 0.42,
          color: theme
              .colorScheme
              .onSurfaceVariant,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration:
      BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme
              .colorScheme
              .outlineVariant,
          width: 1.5,
        ),
      ),
      clipBehavior:
      Clip.antiAlias,
      child: Image.network(
        logoUrl,
        fit: BoxFit.cover,
        errorBuilder: (
            _,
            _,
            _,
            ) {
          return Container(
            color: theme
                .colorScheme
                .surfaceContainerHighest,
            child: Icon(
              Icons
                  .storefront_outlined,
              size: size * 0.42,
              color: theme
                  .colorScheme
                  .onSurfaceVariant,
            ),
          );
        },
        loadingBuilder: (
            context,
            child,
            loadingProgress,
            ) {
          if (loadingProgress ==
              null) {
            return child;
          }

          return Center(
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              value:
              loadingProgress
                  .expectedTotalBytes !=
                  null
                  ? loadingProgress
                  .cumulativeBytesLoaded /
                  loadingProgress
                      .expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _buildActionButtons(
      BuildContext context,
      LandingResponse landing,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 54,
          child:
          FilledButton.icon(
            onPressed:
            landing.menuAvailable
                ? widget
                .onOpenMenu
                : null,
            icon: const Icon(
              Icons
                  .visibility_outlined,
            ),
            label: const Text(
              'View',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        SizedBox(
          height: 54,
          child:
          OutlinedButton.icon(
            onPressed:
            landing
                .paymentEnabled
                ? widget
                .onOpenPayment
                : null,
            icon: const Icon(
              Icons
                  .account_balance_wallet_outlined,
            ),
            label: Text(
              landing
                  .paymentEnabled
                  ? 'Pay via UPI'
                  : 'Payment Unavailable',
              style:
              const TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUSINESS INFO
  // ============================================================

  Widget _buildBusinessTypeInfo(
      BuildContext context,
      LandingResponse landing,
      ) {
    final theme =
    Theme.of(context);

    final terminology =
    _terminologyFor(
      landing.businessType,
    );

    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration:
      BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .info_outline,
            color: theme
                .colorScheme
                .primary,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              terminology
                  .description,
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter(
      BuildContext context,
      ) {
    return Column(
      children: [
        Text(
          'Powered by ScanAura',
          textAlign:
          TextAlign.center,
          style: TextStyle(
            color: Theme.of(
              context,
            )
                .colorScheme
                .onSurfaceVariant,
            fontWeight:
            FontWeight.w600,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        TextButton(
          onPressed: () {
            context.go(
              '/register',
            );
          },
          child: const Text(
            'Register your business',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      PublicState state,
      ) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child:
          SingleChildScrollView(
            padding:
            const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .error_outline,
                    size: 52,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .error,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(
                    'Unable to load business',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    state.errorMessage ??
                        'Unable to load business.',
                    textAlign:
                    TextAlign.center,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    child:
                    FilledButton.icon(
                      onPressed: () {
                        ref
                            .read(
                          publicNotifierProvider
                              .notifier,
                        )
                            .loadLanding(
                          widget.qrCode,
                        );
                      },
                      icon:
                      const Icon(
                        Icons
                            .refresh_rounded,
                      ),
                      label:
                      const Text(
                        'Retry',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BUSINESS TERMINOLOGY
// ============================================================

class _BusinessTerminology {
  const _BusinessTerminology({
    required this.collectionTitle,
    required this.itemTitle,
    required this.description,
  });

  final String collectionTitle;
  final String itemTitle;
  final String description;
}

_BusinessTerminology _terminologyFor(
    String businessType,
    ) {
  switch (
  businessType.trim().toUpperCase()) {
    case 'FOOD':
      return const _BusinessTerminology(
        collectionTitle: 'Menu',
        itemTitle: 'Item',
        description:
        'Explore the latest menu and available items.',
      );

    case 'SERVICES':
      return const _BusinessTerminology(
        collectionTitle: 'Services',
        itemTitle: 'Service',
        description:
        'Explore available services and offerings.',
      );

    case 'RETAIL':
    case 'ECOMMERCE':
      return const _BusinessTerminology(
        collectionTitle: 'Catalog',
        itemTitle: 'Product',
        description:
        'Browse available products and offerings.',
      );

    case 'PERSONAL_BRAND':
      return const _BusinessTerminology(
        collectionTitle: 'Catalog',
        itemTitle: 'Item',
        description:
        'Explore products, services and offerings.',
      );

    case 'OTHER':
    default:
      return const _BusinessTerminology(
        collectionTitle: 'Catalog',
        itemTitle: 'Item',
        description:
        'Explore products, services and offerings.',
      );
  }
}

// ============================================================
// INFO CHIP
// ============================================================

class _InfoChip
    extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration:
      BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
          ),

          const SizedBox(
            width: 6,
          ),

          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}