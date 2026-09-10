import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/landing_response.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_notifier.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_state.dart';

import 'package:scanaura_frontend/features/activity/loyalty/presentation/pages/customer_loyalty_page.dart';

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

  // ============================================================
  // SHARE
  // ============================================================

  Future<void> _sharePage() async {
    final currentUrl = Uri.base.toString();

    final landing =
        ref.read(publicNotifierProvider).landing;

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
        ClipboardData(
          text: shareText,
        ),
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

  // ============================================================
  // EXTERNAL LINKS
  // ============================================================

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

  // ============================================================
  // BUSINESS TYPE
  // ============================================================

  String _businessTypeLabel(String value) {
    switch (value.trim().toUpperCase()) {
      case 'FOOD':
        return 'Food';

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

      case 'SERVICES':
        return 'Services';

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      publicNotifierProvider,
    );

    if (state.status == PublicStatus.loading) {
      return _buildLoading();
    }

    if (state.status == PublicStatus.error &&
        state.landing == null) {
      return _buildError(
        context,
        state,
      );
    }

    final landing = state.landing;

    if (landing == null) {
      return _buildUnavailable();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF00674F),
          onRefresh: () async {
            await ref
                .read(
              publicNotifierProvider.notifier,
            )
                .refreshLanding();
          },
          child: LayoutBuilder(
            builder: (
                context,
                constraints,
                ) {
              final width = constraints.maxWidth;

              final horizontalPadding =
              width < 360
                  ? 16.0
                  : width < 600
                  ? 20.0
                  : 24.0;

              final contentMaxWidth =
              width >= 1000
                  ? 760.0
                  : width >= 700
                  ? 660.0
                  : 560.0;

              return SingleChildScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  18,
                  horizontalPadding,
                  32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: contentMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        _buildBusinessIdentity(
                          context,
                          landing,
                        ),
                        const SizedBox(height: 22),
                        _buildActionButtons(
                          context,
                          landing,
                        ),
                        const SizedBox(height: 22),
                        _buildSocialSection(
                          context,
                          landing,
                        ),
                        const SizedBox(height: 20),
                        _buildBusinessTypeInfo(
                          context,
                          landing,
                        ),
                        const SizedBox(height: 30),
                        _buildFooter(context),
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
  // BUSINESS IDENTITY CARD
  // ============================================================

  Widget _buildBusinessIdentity(
      BuildContext context,
      LandingResponse landing,
      ) {
    final theme = Theme.of(context);

    final businessName =
    landing.businessName.trim().isNotEmpty
        ? landing.businessName.trim()
        : 'Business';

    final businessType = _businessTypeLabel(
      landing.businessType,
    );

    final city = landing.city?.trim() ?? '';

    final hasLogo =
        landing.logoUrl != null &&
            landing.logoUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        22,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 30,
            offset: Offset(0, 12),
            color: Color(0x0C0F172A),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 4,
                left: 8,
                right: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7F3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD3EDE4),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: hasLogo
                        ? Image.network(
                      landing.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, _, _) =>
                      const _DefaultBusinessIcon(),
                    )
                        : const _DefaultBusinessIcon(),
                  ),

                  const SizedBox(height: 17),

                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 520,
                    ),
                    child: Text(
                      businessName,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style:
                      theme.textTheme.headlineMedium
                          ?.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                        height: 1.12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 11),

                  Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment:
                    WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.storefront_rounded,
                        label: businessType,
                      ),
                      if (city.isNotEmpty)
                        _InfoChip(
                          icon:
                          Icons.location_on_outlined,
                          label: city,
                        ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4FAF8),
                      borderRadius:
                      BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE1F0EB),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_2_rounded,
                          size: 18,
                          color: Color(0xFF00674F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Digital business page',
                          textAlign: TextAlign.center,
                          style:
                          theme.textTheme.bodySmall
                              ?.copyWith(
                            color:
                            const Color(0xFF475569),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _sharePage,
                borderRadius:
                BorderRadius.circular(15),
                child: Ink(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius:
                    BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: const Icon(
                    Icons.share_rounded,
                    size: 20,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGO FALLBACK
  // ============================================================

  Widget _buildLogo(
      BuildContext context,
      String? logoUrl,
      ) {
    final width =
        MediaQuery.sizeOf(context).width;

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
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.storefront_outlined,
          size: size * 0.42,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        logoUrl,
        fit: BoxFit.cover,
        errorBuilder:
            (_, _, _) =>
        const _DefaultBusinessIcon(),
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
    final isFood =
        landing.businessType
            .trim()
            .toUpperCase() ==
            'FOOD' ||
            landing.businessType
                .trim()
                .toUpperCase() ==
                'RESTAURANT' ||
            landing.businessType
                .trim()
                .toUpperCase() ==
                'CAFE';

    final hasPayment =
        landing.paymentEnabled == true;

    final hasReview =
        landing.googleReviewEnabled == true &&
            landing.googleReviewUrl != null &&
            landing.googleReviewUrl!
                .trim()
                .isNotEmpty;

    final hasLoyalty =
        landing.loyaltyEnabled == true;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Text(
          'Explore & connect',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Everything you need, right here.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),

        const SizedBox(height: 14),

        // ========================================================
        // MENU
        // ========================================================

        _buildActionTile(
          context,
          icon: isFood
              ? Icons.restaurant_menu_rounded
              : Icons.visibility_rounded,
          title: isFood
              ? 'View Menu'
              : 'View Offerings',
          subtitle: isFood
              ? 'Browse the latest menu and items'
              : 'Explore products and services',
          backgroundColor:
          const Color(0xFF00674F),
          foregroundColor: Colors.white,
          onPressed:
          landing.menuAvailable == true
              ? widget.onOpenMenu
              : null,
          filled: true,
        ),

        // ========================================================
        // LOYALTY
        // ========================================================

        if (hasLoyalty) ...[
          const SizedBox(height: 10),

          _buildActionTile(
            context,
            icon: Icons.stars_rounded,
            title: 'Loyalty',
            subtitle:
            'Earn points when you visit',
            backgroundColor:
            const Color(0xFFF2FBF8),
            foregroundColor:
            const Color(0xFF00674F),
            borderColor:
            const Color(0xFFCDE9DF),
            onPressed: () {
              _showLoyaltyComingSoon(
                context,
                landing,
              );
            },
          ),
        ],

        // ========================================================
        // PAYMENT
        // ========================================================

        if (hasPayment) ...[
          const SizedBox(height: 10),

          _buildActionTile(
            context,
            icon:
            Icons.account_balance_wallet_rounded,
            title: 'Pay via UPI',
            subtitle:
            'Quick and convenient digital payment',
            backgroundColor:
            const Color(0xFFEAF7F3),
            foregroundColor:
            const Color(0xFF00674F),
            borderColor:
            const Color(0xFFB9DDD1),
            onPressed: widget.onOpenPayment,
          ),
        ],

        // ========================================================
        // GOOGLE REVIEW
        // ========================================================

        if (hasReview) ...[
          const SizedBox(height: 10),

          _buildActionTile(
            context,
            icon: Icons.star_rounded,
            title: 'Review Us',
            subtitle:
            'Share your experience on Google',
            backgroundColor:
            const Color(0xFFF6F8FF),
            foregroundColor:
            const Color(0xFF4285F4),
            borderColor:
            const Color(0xFFD8E3FF),
            onPressed: () =>
                _openExternalLink(
                  landing.googleReviewUrl!,
                ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // ACTION TILE
  // ============================================================

  Widget _buildActionTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color backgroundColor,
        required Color foregroundColor,
        required VoidCallback? onPressed,
        Color? borderColor,
        bool filled = false,
      }) {
    final enabled = onPressed != null;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius:
        BorderRadius.circular(18),
        child: Ink(
          height: 68,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius:
            BorderRadius.circular(18),
            border: borderColor != null
                ? Border.all(
              color: borderColor,
            )
                : null,
            boxShadow: filled
                ? const [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 7),
                color: Color(0x1800674F),
              ),
            ]
                : null,
          ),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: filled
                        ? const Color(0x1AFFFFFF)
                        : Colors.white,
                    borderRadius:
                    BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: foregroundColor,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foregroundColor,
                          fontSize: 15.5,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color: filled
                              ? const Color(
                            0xE6FFFFFF,
                          )
                              : const Color(
                            0xFF64748B,
                          ),
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 15,
                  color: foregroundColor.withValues(
                    alpha: filled
                        ? 0.9
                        : 0.65,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOYALTY MESSAGE
  // ============================================================

  void _showLoyaltyComingSoon(
      BuildContext context,
      LandingResponse landing,
      ) {
    final businessName =
    landing.businessName.trim().isNotEmpty
        ? landing.businessName.trim()
        : 'this business';

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              8,
              24,
              28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF7F3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    size: 32,
                    color: Color(0xFF00674F),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Loyalty',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '$businessName offers a loyalty program. '
                      'Enter your name and mobile number to '
                      'access your loyalty account, earn points '
                      'and use available rewards.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              CustomerLoyaltyPage(
                                businessId:
                                landing.businessId,
                                businessName:
                                businessName,
                              ),
                        ),
                      );
                    },
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SOCIAL
  // ============================================================

  Widget _buildSocialSection(
      BuildContext context,
      LandingResponse landing,
      ) {
    final socials =
    <_SocialLinkItem>[];

    final hasInstagram =
        landing.instagramEnabled == true &&
            landing.instagramUrl != null &&
            landing.instagramUrl!
                .trim()
                .isNotEmpty;

    final hasFacebook =
        landing.facebookEnabled == true &&
            landing.facebookUrl != null &&
            landing.facebookUrl!
                .trim()
                .isNotEmpty;

    final hasYoutube =
        landing.youtubeEnabled == true &&
            landing.youtubeUrl != null &&
            landing.youtubeUrl!
                .trim()
                .isNotEmpty;

    if (hasInstagram) {
      socials.add(
        _SocialLinkItem(
          label: 'Instagram',
          icon: Icons.camera_alt_rounded,
          color: const Color(0xFFE1306C),
          backgroundColor:
          const Color(0xFFFFF1F5),
          borderColor:
          const Color(0xFFF7CBDC),
          url: landing.instagramUrl!,
        ),
      );
    }

    if (hasFacebook) {
      socials.add(
        _SocialLinkItem(
          label: 'Facebook',
          icon: Icons.facebook_rounded,
          color: const Color(0xFF1877F2),
          backgroundColor:
          const Color(0xFFF6F9FF),
          borderColor:
          const Color(0xFFCFE0FF),
          url: landing.facebookUrl!,
        ),
      );
    }

    if (hasYoutube) {
      socials.add(
        _SocialLinkItem(
          label: 'YouTube',
          icon:
          Icons.play_circle_outline_rounded,
          color: const Color(0xFFFF0000),
          backgroundColor:
          const Color(0xFFFFF8F8),
          borderColor:
          const Color(0xFFFFD0D0),
          url: landing.youtubeUrl!,
        ),
      );
    }

    if (socials.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Connect',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Follow and stay connected.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 13),

        LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final compact =
                constraints.maxWidth < 420;

            return GridView.builder(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemCount: socials.length,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                compact ? 1 : 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 56,
              ),
              itemBuilder:
                  (context, index) {
                return _buildSocialTile(
                  context,
                  socials[index],
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // SOCIAL TILE
  // ============================================================

  Widget _buildSocialTile(
      BuildContext context,
      _SocialLinkItem social,
      ) {
    return Material(
      color: social.backgroundColor,
      borderRadius:
      BorderRadius.circular(16),
      child: InkWell(
        onTap: () =>
            _openExternalLink(
              social.url,
            ),
        borderRadius:
        BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: social.backgroundColor,
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color: social.borderColor,
            ),
          ),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 13,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration:
                  BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(11),
                  ),
                  child: Icon(
                    social.icon,
                    size: 19,
                    color: social.color,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Text(
                    social.label,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      color: social.color,
                      fontSize: 13.5,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),

                Icon(
                  Icons.arrow_outward_rounded,
                  size: 16,
                  color: social.color.withValues(
                    alpha: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUSINESS INFO
  // ============================================================

  Widget _buildBusinessTypeInfo(
      BuildContext context,
      LandingResponse landing,
      ) {
    final theme = Theme.of(context);

    final terminology =
    _terminologyFor(
      landing.businessType,
    );

    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme
                  .colorScheme
                  .primaryContainer,
              borderRadius:
              BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 19,
              color: theme
                  .colorScheme
                  .primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              terminology.description,
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                height: 1.45,
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
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
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
            fontWeight: FontWeight.w600,
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

  // ============================================================
  // UNAVAILABLE
  // ============================================================

  Widget _buildUnavailable() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                    Icons.storefront_outlined,
                    size: 56,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Business information is unavailable.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Please try again in a moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context)
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
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      PublicState state,
      ) {
    if (state.isBusinessUnavailable) {
      return _buildMaintenancePage(
        context,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                    Icons.error_outline,
                    size: 52,
                    color: Theme.of(context)
                        .colorScheme
                        .error,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Unable to load business',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    state.errorMessage ??
                        'Unable to load business.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
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
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: const Text(
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

  // ============================================================
  // MAINTENANCE
  // ============================================================

  Widget _buildMaintenancePage(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Scaffold(
      backgroundColor:
      theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 460,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
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
                      size: 38,
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Business page unavailable',
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'This business\'s ScanAura page is '
                        'currently under maintenance. '
                        'Please check back later.',
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                      height: 1.5,
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Powered by ScanAura',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                      fontWeight:
                      FontWeight.w600,
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
  switch (businessType.trim().toUpperCase()) {
    case 'FOOD':
    case 'RESTAURANT':
    case 'CAFE':
      return const _BusinessTerminology(
        collectionTitle: 'Menu',
        itemTitle: 'Item',
        description:
        'Explore the latest menu and available items.',
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
        collectionTitle: 'Catalog',
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

// ============================================================
// SOCIAL MODEL
// ============================================================

class _SocialLinkItem {
  const _SocialLinkItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.url,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final String url;
}

// ============================================================
// INFO CHIP
// ============================================================

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
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
            color: theme
                .colorScheme
                .onSurfaceVariant,
          ),

          const SizedBox(width: 6),

          Text(
            label,
            style: TextStyle(
              color: theme
                  .colorScheme
                  .onSurfaceVariant,
              fontSize: 12.5,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DEFAULT BUSINESS ICON
// ============================================================

class _DefaultBusinessIcon
    extends StatelessWidget {
  const _DefaultBusinessIcon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.storefront_outlined,
        size: 42,
        color: Color(0xFF00674F),
      ),
    );
  }
}