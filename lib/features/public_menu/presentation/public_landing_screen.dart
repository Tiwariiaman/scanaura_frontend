import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_notifier.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_state.dart';
import 'package:share_plus/share_plus.dart';

import '../data/models/landing_response.dart';


class PublicLandingScreen extends ConsumerStatefulWidget {
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
          .read(publicNotifierProvider.notifier)
          .loadLanding(widget.qrCode);
    });
  }

  Future<void> _sharePage() async {
    final currentUrl = Uri.base.toString();

    final state =
    ref.read(publicNotifierProvider);

    final landing = state.landing;

    final businessName =
    landing?.businessName.trim().isNotEmpty ==
        true
        ? landing!.businessName.trim()
        : 'this business';

    final businessType =
    landing?.businessType.trim().isNotEmpty ==
        true
        ? landing!.businessType.trim()
        : 'business';

    final shareText =
        'Check out $businessName on ScanAura.\n\n'
        'Explore their digital $businessType page, '
        'menu and offerings:\n'
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
          content: Text(
            'Share message copied to clipboard.',
          ),
        ),
      );
    }
  }

  String _businessTypeLabel(
      String value,
      ) {
    final normalized =
    value.trim().toUpperCase();

    switch (normalized) {
      case 'RESTAURANT':
        return 'Restaurant';

      case 'CAFE':
        return 'Cafe';

      case 'SALON':
        return 'Salon';

      case 'RETAIL':
      case 'RETAIL_SHOP':
        return 'Retail';

      case 'ECOMMERCE':
      case 'E_COMMERCE':
        return 'E-commerce';

      default:
        if (value.trim().isEmpty) {
          return 'Business';
        }

        return value
            .trim()
            .replaceAll('_', ' ');
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final state =
    ref.watch(publicNotifierProvider);

    if (state.status ==
        PublicStatus.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status ==
        PublicStatus.error &&
        state.landing == null) {
      return _buildError(
        context,
        state,
      );
    }

    final landing = state.landing;

    if (landing == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Business information is unavailable.',
          ),
        ),
      );
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
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 560,
              ),
              child: Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  28,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(),

                    const SizedBox(height: 24),

                    _buildBusinessIdentity(
                      context,
                      landing,
                    ),

                    const SizedBox(height: 24),

                    _buildActionButtons(
                      context,
                      landing,
                    ),

                    const SizedBox(height: 20),

                    _buildBusinessTypeInfo(
                      context,
                      landing,
                    ),

                    const SizedBox(height: 36),

                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildBusinessIdentity(
      BuildContext context,
      LandingResponse landing,
      ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildLogo(
          context,
          landing.logoUrl,
        ),

        const SizedBox(height: 20),

        Text(
          landing.businessName,
          textAlign: TextAlign.center,
          style: theme
              .textTheme
              .headlineMedium
              ?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 10),

        Wrap(
          alignment:
          WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Icons.storefront_outlined,
              label: _businessTypeLabel(
                landing.businessType,
              ),
            ),
            if (landing.city
                ?.trim()
                .isNotEmpty ==
                true)
              _InfoChip(
                icon: Icons.location_on_outlined,
                label:
                landing.city!.trim(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogo(
      BuildContext context,
      String? logoUrl,
      ) {
    final theme = Theme.of(context);

    if (logoUrl == null ||
        logoUrl.trim().isEmpty) {
      return Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          color: theme
              .colorScheme
              .surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.storefront_outlined,
          size: 48,
        ),
      );
    }

    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
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
        errorBuilder:
            (_, _, _) {
          return Container(
            color: theme
                .colorScheme
                .surfaceContainerHighest,
            child: const Icon(
              Icons.storefront_outlined,
              size: 48,
            ),
          );
        },
        loadingBuilder:
            (
            context,
            child,
            loadingProgress,
            ) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context,
      LandingResponse landing,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed:
          landing.menuAvailable
              ? widget.onOpenMenu
              : null,
          icon: const Icon(
            Icons.restaurant_menu_outlined,
          ),
          label: const Padding(
            padding:
            EdgeInsets.symmetric(
              vertical: 13,
            ),
            child: Text(
              'View Menu',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed:
          landing.paymentEnabled
              ? widget.onOpenPayment
              : null,
          icon: const Icon(
            Icons.account_balance_wallet_outlined,
          ),
          label: Padding(
            padding:
            const EdgeInsets.symmetric(
              vertical: 13,
            ),
            child: Text(
              landing.paymentEnabled
                  ? 'Pay via UPI'
                  : 'Payment Unavailable',
              style: const TextStyle(
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

  Widget _buildBusinessTypeInfo(
      BuildContext context,
      LandingResponse landing,
      ) {
    final theme = Theme.of(context);

    String label;

    switch (
    landing.businessType
        .trim()
        .toUpperCase()) {
      case 'RESTAURANT':
      case 'CAFE':
        label =
        'View the latest menu and discover available items.';
        break;

      case 'SALON':
        label =
        'View available services and offerings.';
        break;

      case 'RETAIL':
      case 'RETAIL_SHOP':
        label =
        'Browse available products and items.';
        break;

      case 'ECOMMERCE':
      case 'E_COMMERCE':
        label =
        'Browse the available product catalog.';
        break;

      default:
        label =
        'Explore products, services and offerings.';
    }

    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
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
            Icons.info_outline,
            color:
            theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
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

  Widget _buildFooter(
      BuildContext context,
      ) {
    return Column(
      children: [
        Text(
          'Powered by ScanAura',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
            fontWeight:
            FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        TextButton(
          onPressed: () {
            context.go('/register');
          },
          child: const Text(
            'Register your business',
          ),
        ),
      ],
    );
  }

  Widget _buildError(
      BuildContext context,
      PublicState state,
      ) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),

              const SizedBox(height: 16),

              Text(
                state.errorMessage ??
                    'Unable to load business.',
                textAlign:
                TextAlign.center,
              ),

              const SizedBox(height: 16),

              FilledButton(
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
                child:
                const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
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
    final theme = Theme.of(context);

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
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
          const SizedBox(width: 6),
          Text(
            label,
            style:
            const TextStyle(
              fontWeight:
              FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}