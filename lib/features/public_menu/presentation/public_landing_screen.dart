import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../activity/loyalty/presentation/pages/customer_loyalty_page.dart';
import '../data/models/landing_response.dart';
import 'providers/public_notifier.dart';
import 'providers/public_state.dart';
import 'theme/public_theme.dart';
import 'theme/public_theme_resolver.dart';

class PublicLandingScreen extends ConsumerStatefulWidget {
  const PublicLandingScreen({
    super.key,
    required this.qrCode,
    required this.onOpenMenu,
    required this.onOpenPayment,
  });

  final String qrCode;
  final VoidCallback onOpenMenu;

  // Kept for compatibility with existing routing/integration.
  // Payment is intentionally hidden from the customer-facing UI.
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

    Future.microtask(
      () => ref.read(publicNotifierProvider.notifier).loadLanding(widget.qrCode),
    );
  }

  Future<void> _sharePage() async {
    final currentUrl = Uri.base.toString();

    final landing = ref.read(publicNotifierProvider).landing;

    final businessName =
    landing?.businessName.trim().isNotEmpty == true
        ? landing!.businessName.trim()
        : 'this business';

    final terminology = _terminologyFor(
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
          title: 'Check out $businessName',
        ),
      );
    } catch (_) {
      await Clipboard.setData(
        ClipboardData(text: shareText),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Share message copied to clipboard.',
          ),
        ),
      );
    }
  }

  Future<void> _openExternalLink(String url) async {
    final normalized = url.trim();

    if (normalized.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(normalized);

    if (uri == null ||
        !uri.hasScheme ||
        (!uri.isScheme('http') &&
            !uri.isScheme('https'))) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Unable to open this link.',
          ),
        ),
      );

      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Unable to open this link.',
          ),
        ),
      );
    }
  }

  String _businessTypeLabel(String value) {
    switch (value.trim().toUpperCase()) {
      case 'FOOD':
        return 'Food';
      case 'RESTAURANT':
        return 'Restaurant';
      case 'CAFE':
        return 'Cafe';
      case 'BAKERY':
        return 'Bakery';
      case 'RETAIL':
      case 'RETAIL_SHOP':
        return 'Retail';
      case 'ECOMMERCE':
      case 'E_COMMERCE':
        return 'E-commerce';
      case 'SERVICES':
        return 'Services';
      case 'SALON':
        return 'Salon';
      case 'PERSONAL_BRAND':
        return 'Personal Brand';
      case 'OTHER':
        return 'Other';
      default:
        return value.trim().isEmpty
            ? 'Business'
            : value.trim().replaceAll('_', ' ');
    }
  }

  _BusinessTerminology _terminologyFor(String value) {
    switch (value.trim().toUpperCase()) {
      case 'FOOD':
      case 'RESTAURANT':
      case 'CAFE':
      case 'BAKERY':
        return const _BusinessTerminology(
          collectionTitle: 'Menu',
          itemTitle: 'Item',
          description:
          'Explore the menu and discover what is available.',
        );

      case 'SERVICES':
      case 'SALON':
        return const _BusinessTerminology(
          collectionTitle: 'Services',
          itemTitle: 'Service',
          description:
          'Explore available services and offerings.',
        );

      case 'RETAIL':
      case 'RETAIL_SHOP':
      case 'ECOMMERCE':
      case 'E_COMMERCE':
        return const _BusinessTerminology(
          collectionTitle: 'Catalogue',
          itemTitle: 'Product',
          description:
          'Browse available products and offerings.',
        );

      case 'PERSONAL_BRAND':
        return const _BusinessTerminology(
          collectionTitle: 'Offerings',
          itemTitle: 'Item',
          description:
          'Explore products, services and offerings.',
        );

      case 'OTHER':
      default:
        return const _BusinessTerminology(
          collectionTitle: 'Offerings',
          itemTitle: 'Item',
          description:
          'Explore products, services and offerings.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publicNotifierProvider);

    if (state.status == PublicStatus.loading &&
        state.landing == null) {
      return const _PublicLoadingPage();
    }

    if (state.status == PublicStatus.error &&
        state.landing == null) {
      return _PublicErrorPage(
        message: state.isBusinessUnavailable
            ? 'This business page is unavailable right now.'
            : 'We could not open this business page.',
        onRetry: () {
          ref
              .read(publicNotifierProvider.notifier)
              .loadLanding(widget.qrCode);
        },
      );
    }

    final landing = state.landing;

    if (landing == null) {
      return _PublicErrorPage(
        message: 'This business page is unavailable.',
        onRetry: () {
          ref
              .read(publicNotifierProvider.notifier)
              .loadLanding(widget.qrCode);
        },
      );
    }

    final publicTheme = PublicThemeResolver.resolve(
      businessName: landing.businessName,
      businessType: landing.businessType,
      brandColor: landing.brandColor,
    );

    return Theme(
      data: publicTheme.materialTheme(context),
      child: Scaffold(
        backgroundColor: publicTheme.background,
        body: SafeArea(
          child: _LandingContent(
            landing: landing,
            theme: publicTheme,
            terminology: _terminologyFor(
              landing.businessType,
            ),
            businessTypeLabel: _businessTypeLabel(
              landing.businessType,
            ),
            onShare: _sharePage,
            onOpenMenu: widget.onOpenMenu,
            onOpenPayment: widget.onOpenPayment,
            onOpenExternalLink: _openExternalLink,
          ),
        ),
      ),
    );
  }
}

class _LandingContent extends StatelessWidget {
  const _LandingContent({
    required this.landing,
    required this.theme,
    required this.terminology,
    required this.businessTypeLabel,
    required this.onShare,
    required this.onOpenMenu,
    required this.onOpenPayment,
    required this.onOpenExternalLink,
  });

  final LandingResponse landing;
  final PublicTheme theme;
  final _BusinessTerminology terminology;
  final String businessTypeLabel;
  final VoidCallback onShare;
  final VoidCallback onOpenMenu;
  final VoidCallback onOpenPayment;
  final Future<void> Function(String url) onOpenExternalLink;

  String get businessName {
    final value = landing.businessName.trim();
    return value.isEmpty ? 'Business' : value;
  }

  String get city => landing.city?.trim() ?? '';

  bool get hasLogo =>
      landing.logoUrl != null &&
          landing.logoUrl!.trim().isNotEmpty;

  // Payment remains part of the surrounding architecture but is
  // intentionally disabled/hidden on the customer-facing landing page.
  bool get hasPayment => false;

  bool get hasLoyalty => landing.loyaltyEnabled == true;

  bool get hasReview =>
      landing.googleReviewEnabled == true &&
          landing.googleReviewUrl != null &&
          landing.googleReviewUrl!.trim().isNotEmpty;

  bool get hasInstagram =>
      landing.instagramEnabled == true &&
          landing.instagramUrl != null &&
          landing.instagramUrl!.trim().isNotEmpty;

  bool get hasFacebook =>
      landing.facebookEnabled == true &&
          landing.facebookUrl != null &&
          landing.facebookUrl!.trim().isNotEmpty;

  bool get hasYoutube =>
      landing.youtubeEnabled == true &&
          landing.youtubeUrl != null &&
          landing.youtubeUrl!.trim().isNotEmpty;

  bool get hasSocials =>
      hasInstagram || hasFacebook || hasYoutube;

  bool get isFood {
    const foodTypes = {
      'FOOD',
      'RESTAURANT',
      'CAFE',
      'BAKERY',
    };

    return foodTypes.contains(
      landing.businessType.trim().toUpperCase(),
    );
  }

  String get primaryActionLabel {
    if (isFood) {
      return 'Open Menu';
    }

    switch (landing.businessType.trim().toUpperCase()) {
      case 'SERVICES':
      case 'SALON':
        return 'Explore Services';

      case 'ECOMMERCE':
      case 'E_COMMERCE':
        return 'Explore Products';

      case 'RETAIL':
      case 'RETAIL_SHOP':
        return 'Explore Catalogue';

      case 'PERSONAL_BRAND':
        return 'Explore Offerings';

      default:
        return 'Explore';
    }
  }

  String get primaryDescription {
    if (isFood) {
      return 'Take a look at the menu and discover something you will love.';
    }

    return terminology.description;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final horizontalPadding = width < 360
            ? 16.0
            : width < 600
            ? 20.0
            : width < 1000
            ? 28.0
            : 36.0;

        final maxWidth = width >= 1200
            ? 860.0
            : width >= 900
            ? 780.0
            : 620.0;

        return RefreshIndicator(
          color: theme.primary,
          onRefresh: () async {
            // Refresh is intentionally kept compatible with the
            // existing public provider architecture.
            await Future<void>.delayed(
              const Duration(milliseconds: 100),
            );
          },
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              14,
              horizontalPadding,
              30,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    _buildHero(context),
                    const SizedBox(height: 18),
                    _buildExploreCard(context),

                    // Payment is intentionally not rendered.
                    if (hasLoyalty) ...[
                      const SizedBox(height: 16),
                      _buildExperienceCard(context),
                    ],

                    if (hasReview) ...[
                      const SizedBox(height: 16),
                      _buildReviewCard(context),
                    ],

                    if (hasSocials) ...[
                      const SizedBox(height: 24),
                      _buildSocialSection(context),
                    ],

                    const SizedBox(height: 28),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHero(BuildContext context) {
    return _GlassCard(
      theme: theme,
      padding: const EdgeInsets.fromLTRB(
        22,
        18,
        22,
        24,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -65,
            child: _GlowOrb(
              color: theme.primary.withValues(
                alpha: 0.12,
              ),
              size: 170,
            ),
          ),
          Positioned(
            bottom: -90,
            left: -80,
            child: _GlowOrb(
              color: theme.accent.withValues(
                alpha: 0.09,
              ),
              size: 180,
            ),
          ),
          Column(
            children: [
              // Share is now INSIDE the hero card.
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: onShare,
                  tooltip: 'Share',
                  icon: Icon(
                    Icons.share,
                    color: theme.primary,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: 2),

              Text(
                businessTypeLabel.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.7,
                ),
              ),

              if (city.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  city,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textTertiary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              _BusinessLogo(
                logoUrl: hasLogo
                    ? landing.logoUrl
                    : null,
                businessName: businessName,
                theme: theme,
              ),

              const SizedBox(height: 18),

              Text(
                businessName,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 30,
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                ),
              ),

              const SizedBox(height: 12),

              if (city.isNotEmpty)
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.textTertiary,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        city,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                  BorderRadius.circular(30),
                  border: Border.all(
                    color: theme.primary.withValues(
                      alpha: 0.14,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: theme.primary,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Your digital experience',
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExploreCard(BuildContext context) {
    return _GlassCard(
      theme: theme,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Explore what we have for you',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 21,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            primaryDescription,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: landing.menuAvailable
                  ? onOpenMenu
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                disabledBackgroundColor:
                theme.primary.withValues(
                  alpha: 0.35,
                ),
                disabledForegroundColor:
                theme.onPrimary.withValues(
                  alpha: 0.75,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(17),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(
                    primaryActionLabel,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(BuildContext context) {
    return _GlassCard(
      theme: theme,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Enjoy more with us',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 21,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Discover more ways to enjoy your experience with this business.',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),

          // Loyalty is the only currently visible action.
          // Future options can be added beside it without
          // changing the structure of this card.
          if (hasLoyalty)
            _ExperienceAction(
              icon: Icons.loyalty_rounded,
              label: 'Loyalty',
              color: theme.primary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        CustomerLoyaltyPage(
                          businessId:
                          landing.businessId,
                          businessName:
                          businessName,
                          businessType: landing.businessType,
                          brandColor: landing.brandColor,
                        ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context) {
    return _GlassCard(
      theme: theme,
      padding: const EdgeInsets.all(22),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.rate_review_outlined,
              color: theme.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Enjoyed your experience?',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We would love to hear from you.',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Please review us on Google.',
                  style: TextStyle(
                    color: theme.primary,
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Leave a review',
            onPressed: () {
              onOpenExternalLink(
                landing.googleReviewUrl!,
              );
            },
            style: IconButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: theme.onPrimary,
            ),
            icon: const Icon(
              Icons.arrow_forward_rounded,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    final socials = <_SocialItem>[];

    if (hasInstagram) {
      socials.add(
        _SocialItem(
          label: 'Instagram',
          icon: Icons.camera_alt_rounded,
          url: landing.instagramUrl!,
        ),
      );
    }

    if (hasFacebook) {
      socials.add(
        _SocialItem(
          label: 'Facebook',
          icon: Icons.facebook_rounded,
          url: landing.facebookUrl!,
        ),
      );
    }

    if (hasYoutube) {
      socials.add(
        _SocialItem(
          label: 'YouTube',
          icon: Icons.play_arrow_rounded,
          url: landing.youtubeUrl!,
        ),
      );
    }

    if (socials.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Text(
          'Connect with us',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textTertiary,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: socials.map((social) {
            return Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 7,
              ),
              child: _SocialDot(
                item: social,
                theme: theme,
                onTap: () {
                  onOpenExternalLink(
                    social.url,
                  );
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          'Powered by ScanAura',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textTertiary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextButton(
          onPressed: () {
            context.go('/login');
          },
          style: TextButton.styleFrom(
            foregroundColor: theme.primary,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
          ),
          child: const Text(
            'Register your business',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.theme,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final PublicTheme theme;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.glassSurface,
        borderRadius:
        BorderRadius.circular(28),
        border: Border.all(
          color: theme.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(
              alpha: 0.055,
            ),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primary.withValues(
                          alpha: 0.035,
                        ),
                        Colors.transparent,
                        theme.accent.withValues(
                          alpha: 0.025,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(16),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.08,
            ),
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(
                alpha: 0.13,
              ),
            ),
          ),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _BusinessLogo extends StatelessWidget {
  const _BusinessLogo({
    required this.logoUrl,
    required this.businessName,
    required this.theme,
  });

  final String? logoUrl;
  final String businessName;
  final PublicTheme theme;

  String get initials {
    final parts = businessName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) {
      return 'B';
    }

    return parts
        .map(
          (part) => part.substring(0, 1),
    )
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasLogo =
        logoUrl != null &&
            logoUrl!.trim().isNotEmpty;

    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary.withValues(
              alpha: 0.14,
            ),
            theme.primary.withValues(
              alpha: 0.05,
            ),
          ],
        ),
        border: Border.all(
          color: theme.primary.withValues(
            alpha: 0.16,
          ),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(
              alpha: 0.10,
            ),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: hasLogo
          ? Image.network(
        logoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return _fallback();
        },
      )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: theme.primary,
          fontSize: 31,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _ExperienceAction extends StatelessWidget {
  const _ExperienceAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(17),
        child: Ink(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.07,
            ),
            borderRadius:
            BorderRadius.circular(17),
            border: Border.all(
              color: color.withValues(
                alpha: 0.13,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 19,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialDot extends StatelessWidget {
  const _SocialDot({
    required this.item,
    required this.theme,
    required this.onTap,
  });

  final _SocialItem item;
  final PublicTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Ink(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primary.withValues(
                    alpha: 0.07,
                  ),
                  border: Border.all(
                    color: theme.primary.withValues(
                      alpha: 0.12,
                    ),
                  ),
                ),
                child: Icon(
                  item.icon,
                  size: 19,
                  color: theme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PublicLoadingPage extends StatelessWidget {
  const _PublicLoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _PublicErrorPage extends StatelessWidget {
  const _PublicErrorPage({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 440,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color:
                      colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 38,
                      color: colors
                          .onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Unable to open this page',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                      colors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: const Text(
                        'Try again',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w800,
                        ),
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

class _SocialItem {
  const _SocialItem({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final IconData icon;
  final String url;
}
